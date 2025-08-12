use aho_corasick::AhoCorasick;
use regex::Regex;
use serde::{Deserialize, Serialize};
use std::collections::HashSet;

use crate::config::{FilterConfig, FilterMode};

#[derive(Debug, Serialize, Deserialize)]
pub struct FilterResult {
    pub safe: bool,
    pub score: f32,
    pub filtered_content: Option<String>,
    pub reason: Option<String>,
    pub matched_rules: Vec<String>,
}

pub struct ContentFilter {
    config: FilterConfig,
    keyword_matcher: Option<AhoCorasick>,
    patterns: Vec<CompiledPattern>,
    whitelist_patterns: Vec<Regex>,
}

struct CompiledPattern {
    regex: Regex,
    name: String,
    severity: f32,
}

impl ContentFilter {
    pub fn new(config: FilterConfig) -> Self {
        // Build keyword matcher
        let keyword_matcher = if !config.rules.keywords.banned.is_empty() {
            Some(
                AhoCorasick::new(&config.rules.keywords.banned)
                    .expect("Failed to build keyword matcher")
            )
        } else {
            None
        };
        
        // Compile regex patterns
        let mut patterns = Vec::new();
        for pattern_rule in &config.rules.patterns {
            if let Ok(regex) = Regex::new(&pattern_rule.pattern) {
                patterns.push(CompiledPattern {
                    regex,
                    name: pattern_rule.name.clone().unwrap_or_else(|| pattern_rule.pattern.clone()),
                    severity: pattern_rule.severity,
                });
            }
        }
        
        // Compile whitelist patterns
        let mut whitelist_patterns = Vec::new();
        for pattern in &config.rules.whitelist.contexts {
            if let Ok(regex) = Regex::new(pattern) {
                whitelist_patterns.push(regex);
            }
        }
        
        Self {
            config,
            keyword_matcher,
            patterns,
            whitelist_patterns,
        }
    }
    
    pub fn check(&self, text: &str) -> FilterResult {
        let mut matched_rules = Vec::new();
        let mut total_score = 0.0;
        let mut max_severity = 0.0;
        
        // Check if content matches whitelist
        if self.is_whitelisted(text) {
            return FilterResult {
                safe: true,
                score: 1.0,
                filtered_content: None,
                reason: Some("Content matches whitelist".to_string()),
                matched_rules: vec![],
            };
        }
        
        // Check keywords
        if let Some(ref matcher) = self.keyword_matcher {
            let matches: Vec<_> = matcher.find_iter(text).collect();
            if !matches.is_empty() {
                let severity = self.get_keyword_severity(&matches);
                total_score += severity;
                max_severity = max_severity.max(severity);
                
                for m in matches {
                    matched_rules.push(format!("keyword: {}", m.as_str()));
                }
            }
        }
        
        // Check patterns
        for pattern in &self.patterns {
            if pattern.regex.is_match(text) {
                total_score += pattern.severity;
                max_severity = max_severity.max(pattern.severity);
                matched_rules.push(format!("pattern: {}", pattern.name));
            }
        }
        
        // Check warning keywords
        let warning_score = self.check_warning_keywords(text);
        total_score += warning_score * 0.5; // Warning keywords have lower weight
        
        // Check combination patterns
        if self.check_dangerous_combinations(text) {
            total_score += 0.8;
            max_severity = max_severity.max(0.8);
            matched_rules.push("dangerous_combination".to_string());
        }
        
        // Determine if content is safe based on mode
        let threshold = self.get_threshold();
        let safe = max_severity < threshold && total_score < threshold * 2.0;
        
        // Filter content if needed
        let filtered_content = if !safe && self.config.filter_replacement {
            Some(self.filter_text(text, &matched_rules))
        } else {
            None
        };
        
        FilterResult {
            safe,
            score: 1.0 - max_severity.min(1.0),
            filtered_content,
            reason: if !safe {
                Some(self.get_block_reason(&matched_rules))
            } else {
                None
            },
            matched_rules,
        }
    }
    
    fn is_whitelisted(&self, text: &str) -> bool {
        for pattern in &self.whitelist_patterns {
            if pattern.is_match(text) {
                return true;
            }
        }
        false
    }
    
    fn get_keyword_severity(&self, matches: &[aho_corasick::Match]) -> f32 {
        // More matches = higher severity
        let count = matches.len() as f32;
        (count * 0.3).min(1.0)
    }
    
    fn check_warning_keywords(&self, text: &str) -> f32 {
        let mut score = 0.0;
        for keyword in &self.config.rules.keywords.warning {
            if text.contains(keyword) {
                score += 0.2;
            }
        }
        score.min(1.0)
    }
    
    fn check_dangerous_combinations(&self, text: &str) -> bool {
        // Check for dangerous keyword combinations
        let dangerous_combos = vec![
            vec!["how", "make", "bomb"],
            vec!["how", "hack", "system"],
            vec!["ignore", "previous", "instructions"],
            vec!["bypass", "safety", "filter"],
        ];
        
        for combo in dangerous_combos {
            let mut all_found = true;
            for word in combo {
                if !text.to_lowercase().contains(word) {
                    all_found = false;
                    break;
                }
            }
            if all_found {
                return true;
            }
        }
        
        false
    }
    
    fn get_threshold(&self) -> f32 {
        match self.config.mode {
            FilterMode::Strict => 0.3,
            FilterMode::Moderate => 0.6,
            FilterMode::Loose => 0.8,
        }
    }
    
    fn filter_text(&self, text: &str, _matched_rules: &[String]) -> String {
        let mut filtered = text.to_string();
        
        // Replace banned keywords
        if let Some(ref matcher) = self.keyword_matcher {
            for m in matcher.find_iter(text) {
                let replacement = "*".repeat(m.as_str().len());
                filtered = filtered.replace(m.as_str(), &replacement);
            }
        }
        
        filtered
    }
    
    fn get_block_reason(&self, matched_rules: &[String]) -> String {
        if matched_rules.is_empty() {
            "Content violates filter rules".to_string()
        } else {
            format!("Content blocked due to: {}", matched_rules.join(", "))
        }
    }
}