use clap::{Parser, Subcommand};
use std::fs;
use std::io::{self, Read};
use std::process;

mod config;
mod filter;

use config::FilterConfig;
use filter::ContentFilter;

#[derive(Parser)]
#[command(name = "ai-filter")]
#[command(about = "AI Content Filter - Protect against inappropriate AI/LLM outputs")]
#[command(version = "1.0.0")]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    /// Check text content for inappropriate material
    Check {
        /// Text to check (if not provided, reads from stdin)
        text: Option<String>,
        
        /// Custom configuration file
        #[arg(short, long)]
        config: Option<String>,
        
        /// Output format (json, text)
        #[arg(short, long, default_value = "json")]
        format: String,
        
        /// Filter mode (strict, moderate, loose)
        #[arg(short, long)]
        mode: Option<String>,
    },
    
    /// Check content from a file
    File {
        /// Path to the file to check
        path: String,
        
        /// Custom configuration file
        #[arg(short, long)]
        config: Option<String>,
        
        /// Output format (json, text)
        #[arg(short, long, default_value = "json")]
        format: String,
    },
    
    /// Show configuration
    Config {
        /// Configuration file to display
        #[arg(short, long)]
        file: Option<String>,
    },
}

fn main() {
    let cli = Cli::parse();
    
    match cli.command {
        Some(Commands::Check { text, config, format, mode }) => {
            let content = if let Some(text) = text {
                text
            } else {
                // Read from stdin
                let mut buffer = String::new();
                if let Err(e) = io::stdin().read_to_string(&mut buffer) {
                    eprintln!("Error reading from stdin: {}", e);
                    process::exit(1);
                }
                buffer
            };
            
            check_content(content, config, format, mode);
        }
        
        Some(Commands::File { path, config, format }) => {
            match fs::read_to_string(&path) {
                Ok(content) => check_content(content, config, format, None),
                Err(e) => {
                    eprintln!("Error reading file {}: {}", path, e);
                    process::exit(1);
                }
            }
        }
        
        Some(Commands::Config { file }) => {
            show_config(file);
        }
        
        None => {
            // Default behavior: read from stdin
            let mut buffer = String::new();
            if let Err(e) = io::stdin().read_to_string(&mut buffer) {
                eprintln!("Error reading from stdin: {}", e);
                process::exit(1);
            }
            check_content(buffer, None, "json".to_string(), None);
        }
    }
}

fn check_content(content: String, config_path: Option<String>, format: String, mode: Option<String>) {
    // Load configuration
    let config = match FilterConfig::load(config_path, mode) {
        Ok(cfg) => cfg,
        Err(e) => {
            eprintln!("Error loading configuration: {}", e);
            process::exit(1);
        }
    };
    
    // Create filter
    let filter = ContentFilter::new(config);
    
    // Check content
    let result = filter.check(&content);
    
    // Output result
    match format.as_str() {
        "json" => {
            println!("{}", serde_json::to_string(&result).unwrap());
        }
        "text" => {
            if result.safe {
                println!("SAFE (score: {:.2})", result.score);
                if let Some(filtered) = result.filtered_content {
                    println!("Filtered content: {}", filtered);
                }
            } else {
                println!("BLOCKED (score: {:.2})", result.score);
                if let Some(reason) = result.reason {
                    println!("Reason: {}", reason);
                }
                if !result.matched_rules.is_empty() {
                    println!("Matched rules: {:?}", result.matched_rules);
                }
            }
        }
        _ => {
            eprintln!("Unknown format: {}", format);
            process::exit(1);
        }
    }
    
    // Exit with appropriate code
    if !result.safe {
        process::exit(1);
    }
}

fn show_config(config_path: Option<String>) {
    let config = match FilterConfig::load(config_path, None) {
        Ok(cfg) => cfg,
        Err(e) => {
            eprintln!("Error loading configuration: {}", e);
            process::exit(1);
        }
    };
    
    println!("{}", serde_yaml::to_string(&config).unwrap());
}