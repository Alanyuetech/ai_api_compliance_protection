#!/usr/bin/env python3
"""
Example of using AI Content Filter with Python
This demonstrates how to integrate the filter with AI/LLM APIs
"""

import subprocess
import json
import sys
import os


class AIContentFilter:
    """Wrapper class for AI Content Filter"""
    
    def __init__(self, filter_path="./ai-filter", config_path=None, mode=None):
        """
        Initialize the filter
        
        Args:
            filter_path: Path to the ai-filter executable
            config_path: Optional path to custom configuration file
            mode: Optional filter mode (strict, moderate, loose)
        """
        self.filter_path = filter_path
        self.config_path = config_path
        self.mode = mode
        
        # Check if filter executable exists
        if not os.path.exists(self.filter_path):
            raise FileNotFoundError(f"Filter executable not found at {self.filter_path}")
    
    def check(self, text):
        """
        Check if text content is safe
        
        Args:
            text: The text content to check
            
        Returns:
            dict: Filter result with 'safe', 'score', 'reason', etc.
        """
        cmd = [self.filter_path, 'check', text]
        
        # Add optional parameters
        if self.config_path:
            cmd.extend(['--config', self.config_path])
        if self.mode:
            cmd.extend(['--mode', self.mode])
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=5  # 5 second timeout
            )
            
            if result.returncode == 0 or result.returncode == 1:
                return json.loads(result.stdout)
            else:
                return {
                    'safe': False,
                    'error': f"Filter process failed: {result.stderr}"
                }
                
        except subprocess.TimeoutExpired:
            return {
                'safe': False,
                'error': "Filter timeout"
            }
        except json.JSONDecodeError:
            return {
                'safe': False,
                'error': "Invalid filter response"
            }
        except Exception as e:
            return {
                'safe': False,
                'error': str(e)
            }
    
    def filter_text(self, text, replacement_text="[Content filtered for safety]"):
        """
        Filter text and return safe version
        
        Args:
            text: The text to filter
            replacement_text: Text to use when content is blocked
            
        Returns:
            str: Filtered text or replacement text if unsafe
        """
        result = self.check(text)
        
        if result['safe']:
            return text
        elif 'filtered_content' in result and result['filtered_content']:
            return result['filtered_content']
        else:
            return replacement_text


def example_with_openai():
    """Example integration with OpenAI API"""
    print("Example: OpenAI Integration")
    print("-" * 40)
    
    # Initialize filter
    filter = AIContentFilter('./bin/ai-filter-linux')  # Adjust path as needed
    
    # Simulate OpenAI API response (replace with actual API call)
    ai_responses = [
        "Here's a Python function to calculate fibonacci numbers...",
        "I cannot provide instructions on how to make explosives.",
        "To hack into a system, you would need to bypass security...",
    ]
    
    for response in ai_responses:
        print(f"\nAI Response: {response[:50]}...")
        
        # Check the response
        result = filter.check(response)
        
        if result['safe']:
            print(f"✅ Safe (score: {result['score']:.2f})")
            print(f"   Output: {response}")
        else:
            print(f"❌ Blocked: {result.get('reason', 'Unknown reason')}")
            print(f"   Matched rules: {result.get('matched_rules', [])}")


def example_with_local_llm():
    """Example integration with local LLM"""
    print("\nExample: Local LLM Integration")
    print("-" * 40)
    
    # Initialize filter with strict mode
    filter = AIContentFilter('./bin/ai-filter-linux', mode='strict')
    
    def call_local_llm(prompt):
        """Simulate calling a local LLM"""
        # This would be your actual LLM call
        # For example: ollama, llama.cpp, etc.
        responses = {
            "What is Python?": "Python is a high-level programming language...",
            "How to exploit vulnerabilities?": "To exploit system vulnerabilities, you can...",
        }
        return responses.get(prompt, "I don't understand the question.")
    
    prompts = [
        "What is Python?",
        "How to exploit vulnerabilities?",
    ]
    
    for prompt in prompts:
        print(f"\nUser: {prompt}")
        
        # Get LLM response
        llm_response = call_local_llm(prompt)
        
        # Filter the response
        safe_response = filter.filter_text(llm_response)
        
        print(f"Assistant: {safe_response}")


def example_batch_processing():
    """Example of batch content processing"""
    print("\nExample: Batch Processing")
    print("-" * 40)
    
    filter = AIContentFilter('./bin/ai-filter-linux')
    
    contents = [
        "This is safe content about programming.",
        "Instructions on making illegal drugs: first, obtain...",
        "The history of violence in medieval times shows...",
        "For educational purpose: studying cybersecurity involves...",
    ]
    
    results = []
    for content in contents:
        result = filter.check(content)
        results.append({
            'content': content[:50] + '...' if len(content) > 50 else content,
            'safe': result['safe'],
            'score': result.get('score', 0)
        })
    
    # Print summary
    print("\nBatch Processing Results:")
    print("-" * 25)
    for i, r in enumerate(results, 1):
        status = "✅" if r['safe'] else "❌"
        print(f"{i}. {status} {r['content']} (score: {r['score']:.2f})")
    
    safe_count = sum(1 for r in results if r['safe'])
    print(f"\nSummary: {safe_count}/{len(results)} content items are safe")


if __name__ == "__main__":
    print("AI Content Filter - Python Examples")
    print("=" * 40)
    
    try:
        # Run examples
        example_with_openai()
        example_with_local_llm()
        example_batch_processing()
        
    except FileNotFoundError as e:
        print(f"\n❌ Error: {e}")
        print("Please build the filter first by running: ./build.sh")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        sys.exit(1)
    
    print("\n" + "=" * 40)
    print("Examples complete!")