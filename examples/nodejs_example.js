#!/usr/bin/env node

/**
 * Example of using AI Content Filter with Node.js
 * This demonstrates how to integrate the filter with AI/LLM APIs
 */

const { execSync, spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

class AIContentFilter {
    constructor(filterPath = './ai-filter', config = {}) {
        this.filterPath = filterPath;
        this.configPath = config.configPath || null;
        this.mode = config.mode || null;
        
        // Check if filter exists
        if (!fs.existsSync(this.filterPath)) {
            throw new Error(`Filter executable not found at ${this.filterPath}`);
        }
    }
    
    /**
     * Check if content is safe
     * @param {string} text - Text to check
     * @returns {Object} Filter result
     */
    check(text) {
        const args = ['check', text];
        
        if (this.configPath) {
            args.push('--config', this.configPath);
        }
        if (this.mode) {
            args.push('--mode', this.mode);
        }
        
        try {
            const result = execSync(`${this.filterPath} ${args.map(a => `"${a}"`).join(' ')}`, {
                encoding: 'utf8',
                stdio: ['pipe', 'pipe', 'ignore']
            });
            
            return JSON.parse(result);
        } catch (error) {
            // If exit code is 1, it means content was blocked (still parse the output)
            if (error.status === 1 && error.stdout) {
                return JSON.parse(error.stdout);
            }
            
            return {
                safe: false,
                error: error.message
            };
        }
    }
    
    /**
     * Filter text and return safe version
     * @param {string} text - Text to filter
     * @param {string} replacement - Replacement for unsafe content
     * @returns {string} Filtered text
     */
    filterText(text, replacement = '[Content filtered for safety]') {
        const result = this.check(text);
        
        if (result.safe) {
            return text;
        } else if (result.filtered_content) {
            return result.filtered_content;
        } else {
            return replacement;
        }
    }
    
    /**
     * Check content asynchronously
     * @param {string} text - Text to check
     * @returns {Promise<Object>} Filter result
     */
    async checkAsync(text) {
        return new Promise((resolve, reject) => {
            const args = ['check', text];
            
            if (this.configPath) {
                args.push('--config', this.configPath);
            }
            if (this.mode) {
                args.push('--mode', this.mode);
            }
            
            const process = spawn(this.filterPath, args);
            let stdout = '';
            let stderr = '';
            
            process.stdout.on('data', (data) => {
                stdout += data.toString();
            });
            
            process.stderr.on('data', (data) => {
                stderr += data.toString();
            });
            
            process.on('close', (code) => {
                try {
                    const result = JSON.parse(stdout);
                    resolve(result);
                } catch (error) {
                    reject(new Error(`Failed to parse filter output: ${error.message}`));
                }
            });
            
            process.on('error', (error) => {
                reject(error);
            });
        });
    }
}

// Example: Integration with OpenAI-style API
async function exampleWithOpenAI() {
    console.log('Example: OpenAI-style API Integration');
    console.log('-'.repeat(40));
    
    const filter = new AIContentFilter('./bin/ai-filter-linux');
    
    // Simulate API responses (replace with actual API calls)
    const responses = [
        { role: 'assistant', content: 'Here is how to sort an array in JavaScript...' },
        { role: 'assistant', content: 'To create malware, you would need to...' },
        { role: 'assistant', content: 'The best way to learn programming is through practice.' }
    ];
    
    for (const response of responses) {
        console.log(`\nAI Response: ${response.content.substring(0, 50)}...`);
        
        const result = await filter.checkAsync(response.content);
        
        if (result.safe) {
            console.log(`✅ Safe (score: ${result.score.toFixed(2)})`);
            console.log(`   Output: ${response.content}`);
        } else {
            console.log(`❌ Blocked: ${result.reason || 'Unknown reason'}`);
            console.log(`   Matched rules: ${result.matched_rules.join(', ')}`);
        }
    }
}

// Example: Real-time chat filtering
async function exampleChatFilter() {
    console.log('\nExample: Real-time Chat Filter');
    console.log('-'.repeat(40));
    
    const filter = new AIContentFilter('./bin/ai-filter-linux', { mode: 'moderate' });
    
    // Simulate a chat conversation
    const messages = [
        { user: 'How do I create a REST API?' },
        { assistant: 'To create a REST API, you can use Express.js...' },
        { user: 'Can you help me hack into a system?' },
        { assistant: 'I can help you understand system security for defensive purposes...' },
        { user: 'Tell me about machine learning' },
        { assistant: 'Machine learning is a subset of AI that enables systems to learn...' }
    ];
    
    for (const msg of messages) {
        if (msg.user) {
            console.log(`\nUser: ${msg.user}`);
        } else {
            const filtered = filter.filterText(msg.assistant);
            console.log(`Assistant: ${filtered}`);
        }
    }
}

// Example: Batch content moderation
async function exampleBatchModeration() {
    console.log('\nExample: Batch Content Moderation');
    console.log('-'.repeat(40));
    
    const filter = new AIContentFilter('./bin/ai-filter-linux');
    
    const contents = [
        'This is a helpful tutorial on web development.',
        'Instructions for making illegal substances: first...',
        'The historical context of violence in literature...',
        'How to bypass security filters and gain unauthorized access...',
        'Best practices for secure coding in JavaScript.'
    ];
    
    const results = await Promise.all(
        contents.map(async (content) => {
            const result = await filter.checkAsync(content);
            return {
                content: content.substring(0, 50) + (content.length > 50 ? '...' : ''),
                safe: result.safe,
                score: result.score || 0
            };
        })
    );
    
    console.log('\nBatch Processing Results:');
    console.log('-'.repeat(25));
    results.forEach((r, i) => {
        const status = r.safe ? '✅' : '❌';
        console.log(`${i + 1}. ${status} ${r.content} (score: ${r.score.toFixed(2)})`);
    });
    
    const safeCount = results.filter(r => r.safe).length;
    console.log(`\nSummary: ${safeCount}/${results.length} content items are safe`);
}

// Example: Custom configuration
function exampleWithCustomConfig() {
    console.log('\nExample: Custom Configuration');
    console.log('-'.repeat(40));
    
    // Create a temporary custom config
    const customConfig = {
        mode: 'strict',
        rules: {
            keywords: {
                banned: ['company_secret', 'confidential'],
                warning: ['internal', 'private']
            },
            patterns: [
                {
                    pattern: 'PROJECT-[A-Z]{3}-\\d{3}',
                    name: 'project_code',
                    severity: 0.9,
                    action: 'block'
                }
            ],
            whitelist: {
                contexts: ['test environment', 'example code']
            }
        }
    };
    
    // Save custom config temporarily
    const configPath = './temp-config.yaml';
    fs.writeFileSync(configPath, require('js-yaml').dump(customConfig));
    
    const filter = new AIContentFilter('./bin/ai-filter-linux', { configPath });
    
    const tests = [
        'This is normal content.',
        'The company_secret project details are...',
        'PROJECT-ABC-123 is classified.',
        'In test environment: PROJECT-XYZ-456 is safe to discuss.'
    ];
    
    tests.forEach(text => {
        const result = filter.check(text);
        const status = result.safe ? '✅ Safe' : '❌ Blocked';
        console.log(`${status}: "${text.substring(0, 50)}..."`);
    });
    
    // Clean up
    fs.unlinkSync(configPath);
}

// Main execution
async function main() {
    console.log('AI Content Filter - Node.js Examples');
    console.log('='.repeat(40));
    
    try {
        await exampleWithOpenAI();
        await exampleChatFilter();
        await exampleBatchModeration();
        // Note: exampleWithCustomConfig requires js-yaml package
        // Uncomment if js-yaml is installed:
        // exampleWithCustomConfig();
        
    } catch (error) {
        if (error.code === 'ENOENT') {
            console.error('\n❌ Error: Filter executable not found');
            console.error('Please build the filter first by running: ./build.sh');
        } else {
            console.error(`\n❌ Error: ${error.message}`);
        }
        process.exit(1);
    }
    
    console.log('\n' + '='.repeat(40));
    console.log('Examples complete!');
}

// Run examples
main();