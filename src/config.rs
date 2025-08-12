use serde::{Deserialize, Serialize};
use std::fs;
use std::path::Path;

// Default rules embedded in binary
const DEFAULT_RULES: &str = include_str!("../config/default_rules.yaml");

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum FilterMode {
    Strict,
    Moderate,
    Loose,
}

impl Default for FilterMode {
    fn default() -> Self {
        FilterMode::Moderate
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FilterConfig {
    #[serde(default)]
    pub mode: FilterMode,
    
    #[serde(default)]
    pub filter_replacement: bool,
    
    #[serde(default)]
    pub log_blocked: bool,
    
    pub rules: FilterRules,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FilterRules {
    pub keywords: KeywordRules,
    pub patterns: Vec<PatternRule>,
    pub whitelist: WhitelistRules,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KeywordRules {
    #[serde(default)]
    pub banned: Vec<String>,
    
    #[serde(default)]
    pub warning: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PatternRule {
    pub pattern: String,
    pub name: Option<String>,
    
    #[serde(default = "default_severity")]
    pub severity: f32,
    
    #[serde(default)]
    pub action: PatternAction,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum PatternAction {
    Block,
    Warn,
}

impl Default for PatternAction {
    fn default() -> Self {
        PatternAction::Block
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WhitelistRules {
    #[serde(default)]
    pub contexts: Vec<String>,
    
    #[serde(default)]
    pub domains: Vec<String>,
}

fn default_severity() -> f32 {
    0.8
}

impl FilterConfig {
    pub fn load(custom_path: Option<String>, mode_override: Option<String>) -> Result<Self, Box<dyn std::error::Error>> {
        // Start with default configuration
        let mut config: FilterConfig = serde_yaml::from_str(DEFAULT_RULES)?;
        
        // Check for config file in current directory
        let local_config = Path::new("filter.yaml");
        if local_config.exists() {
            let content = fs::read_to_string(local_config)?;
            let local: FilterConfig = serde_yaml::from_str(&content)?;
            config.merge(local);
        }
        
        // Load custom config if specified
        if let Some(path) = custom_path {
            let content = fs::read_to_string(&path)?;
            let custom: FilterConfig = serde_yaml::from_str(&content)?;
            config.merge(custom);
        }
        
        // Override mode if specified
        if let Some(mode_str) = mode_override {
            config.mode = match mode_str.to_lowercase().as_str() {
                "strict" => FilterMode::Strict,
                "moderate" => FilterMode::Moderate,
                "loose" => FilterMode::Loose,
                _ => config.mode,
            };
        }
        
        Ok(config)
    }
    
    fn merge(&mut self, other: FilterConfig) {
        // Merge mode
        self.mode = other.mode;
        
        // Merge flags
        self.filter_replacement = other.filter_replacement;
        self.log_blocked = other.log_blocked;
        
        // Merge keywords (append, deduplicate)
        self.rules.keywords.banned.extend(other.rules.keywords.banned);
        self.rules.keywords.banned.sort();
        self.rules.keywords.banned.dedup();
        
        self.rules.keywords.warning.extend(other.rules.keywords.warning);
        self.rules.keywords.warning.sort();
        self.rules.keywords.warning.dedup();
        
        // Merge patterns (append)
        self.rules.patterns.extend(other.rules.patterns);
        
        // Merge whitelist
        self.rules.whitelist.contexts.extend(other.rules.whitelist.contexts);
        self.rules.whitelist.contexts.sort();
        self.rules.whitelist.contexts.dedup();
        
        self.rules.whitelist.domains.extend(other.rules.whitelist.domains);
        self.rules.whitelist.domains.sort();
        self.rules.whitelist.domains.dedup();
    }
}