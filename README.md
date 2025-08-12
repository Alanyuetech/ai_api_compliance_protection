# AI Content Filter / AI 内容过滤器

[English](#english) | [中文](#中文)

---

## English

### Overview

AI Content Filter is a lightweight, offline content filtering tool designed to protect applications using AI/LLM APIs from generating inappropriate content. It provides multi-layered filtering including keyword matching, pattern detection, and context analysis.

### Features

- 🚀 **Ultra-fast**: Millisecond-level filtering performance
- 📦 **Lightweight**: Single executable file ~2-3MB
- 🔒 **Offline**: Works completely offline, no internet required
- 🎯 **Flexible**: Customizable filter rules and modes
- 🌍 **Cross-platform**: Works on Windows, Linux, and macOS
- 🔧 **Easy Integration**: Simple command-line interface, works with any programming language

### Project Structure

```
ai_api_compliance_protection/
├── src/                        # Source code (Rust)
│   ├── main.rs                # CLI entry point
│   ├── filter.rs              # Core filtering engine
│   └── config.rs              # Configuration management
├── config/                     # Configuration files
│   └── default_rules.yaml     # Default filter rules (embedded in binary)
├── examples/                   # Integration examples
│   ├── python_example.py      # Python integration example
│   └── nodejs_example.js      # Node.js integration example
├── bin/                        # Compiled binaries (git-ignored)
│   ├── ai-filter-linux        # Linux executable
│   ├── ai-filter-windows.exe  # Windows executable
│   └── ai-filter-macos        # macOS executable (build via GitHub Actions)
├── .github/                    # GitHub specific files
│   └── workflows/             # GitHub Actions workflows
│       ├── release.yml        # Multi-platform release workflow
│       └── build-macos.yml    # macOS build workflow
├── .env.example               # Environment variables template
├── .env                       # Local environment variables (git-ignored)
├── .gitignore                 # Git ignore rules
├── Cargo.toml                 # Rust project configuration
├── Cargo.lock                 # Rust dependencies lock file
├── Dockerfile                 # Docker build configuration
├── Dockerfile.cross           # Cross-platform Docker build
├── filter.example.yaml        # Example custom filter configuration
├── build.sh                   # Simple build script
├── build-all-platforms.sh     # Multi-platform build script
├── build-docker.sh            # Docker-based build script
├── package-release.sh         # Release packaging script
├── upload-release.sh          # GitHub release upload script
├── test.sh                    # Test script
├── LICENSE                    # MIT License
├── README.md                  # This file
└── INSTALL.md                 # Installation guide
```

### Quick Start

#### Download Pre-compiled Binary

Download the latest release for your platform from the [Releases](https://github.com/Alanyuetech/ai_api_compliance_protection/releases) page:

- Windows: `ai-filter-windows.exe`
- Linux: `ai-filter-linux`
- macOS: `ai-filter-macos`

#### Basic Usage

```bash
# Check text directly
./ai-filter check "Text to check for inappropriate content"

# Check from file
./ai-filter file input.txt

# Pipe input
echo "Some text" | ./ai-filter

# Use custom configuration
./ai-filter check "Text to check" --config custom-rules.yaml

# Different filter modes
./ai-filter check "Text" --mode strict   # Strict filtering
./ai-filter check "Text" --mode moderate # Moderate (default)
./ai-filter check "Text" --mode loose    # Loose filtering
```

#### Integration Examples

**Python:**
```python
import subprocess
import json

def check_content(text):
    result = subprocess.run(
        ['./ai-filter', 'check', text],
        capture_output=True,
        text=True
    )
    return json.loads(result.stdout)

# Use with OpenAI API
response = openai.ChatCompletion.create(...)
check_result = check_content(response.choices[0].message.content)

if check_result['safe']:
    print(response.choices[0].message.content)
else:
    print("Content blocked:", check_result['reason'])
```

**Node.js:**
```javascript
const { execSync } = require('child_process');

function checkContent(text) {
    const result = execSync(`./ai-filter check "${text}"`);
    return JSON.parse(result.toString());
}

// Use with AI API
const aiResponse = await callAIAPI(userInput);
const filterResult = checkContent(aiResponse);

if (filterResult.safe) {
    return aiResponse;
} else {
    return "Content has been filtered for safety.";
}
```

**Shell Script:**
```bash
#!/bin/bash
AI_OUTPUT=$(curl -X POST ... )  # Call AI API
FILTER_RESULT=$(echo "$AI_OUTPUT" | ./ai-filter)

if [ $? -eq 0 ]; then
    echo "$AI_OUTPUT"
else
    echo "Content blocked"
fi
```

### Configuration

#### Environment Variables

For development and release management, create a `.env` file (copy from `.env.example`):

```bash
# Copy the template
cp .env.example .env

# Edit .env and add your GitHub token
nano .env
```

Example `.env` file:
```env
# GitHub Personal Access Token (required for releases)
GITHUB_TOKEN=ghp_your_actual_token_here

# Repository information
GITHUB_OWNER=Alanyuetech
GITHUB_REPO=ai_api_compliance_protection

# Version
VERSION=v1.0.0
```

**Important**: Never commit `.env` file to version control. It's already in `.gitignore`.

#### Filter Configuration

Create a `filter.yaml` file in the same directory as the executable for custom rules:

```yaml
mode: moderate  # strict, moderate, or loose

rules:
  keywords:
    banned:
      - "custom_banned_word"
      - "another_banned_word"
    
    warning:
      - "warning_word"
  
  patterns:
    - pattern: "dangerous.*pattern"
      name: "custom_pattern"
      severity: 0.9
      action: block
  
  whitelist:
    contexts:
      - "educational purpose"
      - "medical discussion"
```

See `filter.example.yaml` for a complete configuration example.

### Build from Source

#### Prerequisites

1. Install Rust: https://rustup.rs/
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

2. Clone the repository:
```bash
git clone https://github.com/your-repo/ai-content-filter.git
cd ai-content-filter
```

#### Compile

```bash
# Debug build (faster compilation)
cargo build

# Release build (optimized, smaller size)
cargo build --release

# The executable will be in target/release/ai-content-filter
```

#### Cross-compilation

```bash
# Install cross-compilation targets
rustup target add x86_64-pc-windows-gnu
rustup target add x86_64-apple-darwin

# Compile for Windows (from Linux/Mac)
cargo build --release --target x86_64-pc-windows-gnu

# Compile for macOS (from Linux)
cargo build --release --target x86_64-apple-darwin
```

### Output Format

The filter returns JSON with the following structure:

```json
{
  "safe": true,
  "score": 0.95,
  "filtered_content": null,
  "reason": null,
  "matched_rules": []
}
```

- `safe`: Boolean indicating if content is safe
- `score`: Safety score (0.0-1.0, higher is safer)
- `filtered_content`: Filtered version with inappropriate content replaced (if enabled)
- `reason`: Reason for blocking (if blocked)
- `matched_rules`: List of rules that were triggered

### License

MIT License

---

## 中文

### 概述

AI 内容过滤器是一个轻量级的离线内容过滤工具，专门设计用于保护使用 AI/LLM API 的应用程序，防止生成不当内容。它提供多层过滤，包括关键词匹配、模式检测和上下文分析。

### 特性

- 🚀 **超快速度**：毫秒级过滤性能
- 📦 **轻量级**：单个可执行文件约 2-3MB
- 🔒 **离线工作**：完全离线运行，无需网络
- 🎯 **灵活配置**：可自定义过滤规则和模式
- 🌍 **跨平台**：支持 Windows、Linux 和 macOS
- 🔧 **易于集成**：简单的命令行接口，适用于任何编程语言

### 快速开始

#### 下载预编译版本

从 [Releases](https://github.com/Alanyuetech/ai_api_compliance_protection/releases) 页面下载适合您平台的最新版本：

- Windows: `ai-filter-windows.exe`
- Linux: `ai-filter-linux`
- macOS: `ai-filter-macos`

#### 基本使用

```bash
# 直接检查文本
./ai-filter check "要检查的文本内容"

# 从文件检查
./ai-filter file input.txt

# 管道输入
echo "一些文本" | ./ai-filter

# 使用自定义配置
./ai-filter check "要检查的文本" --config custom-rules.yaml

# 不同的过滤模式
./ai-filter check "文本" --mode strict   # 严格过滤
./ai-filter check "文本" --mode moderate # 适中（默认）
./ai-filter check "文本" --mode loose    # 宽松过滤
```

#### 集成示例

**Python:**
```python
import subprocess
import json

def check_content(text):
    result = subprocess.run(
        ['./ai-filter', 'check', text],
        capture_output=True,
        text=True
    )
    return json.loads(result.stdout)

# 与 OpenAI API 配合使用
response = openai.ChatCompletion.create(...)
check_result = check_content(response.choices[0].message.content)

if check_result['safe']:
    print(response.choices[0].message.content)
else:
    print("内容已被拦截:", check_result['reason'])
```

**Node.js:**
```javascript
const { execSync } = require('child_process');

function checkContent(text) {
    const result = execSync(`./ai-filter check "${text}"`);
    return JSON.parse(result.toString());
}

// 与 AI API 配合使用
const aiResponse = await callAIAPI(userInput);
const filterResult = checkContent(aiResponse);

if (filterResult.safe) {
    return aiResponse;
} else {
    return "内容因安全原因已被过滤。";
}
```

**Shell 脚本:**
```bash
#!/bin/bash
AI_OUTPUT=$(curl -X POST ... )  # 调用 AI API
FILTER_RESULT=$(echo "$AI_OUTPUT" | ./ai-filter)

if [ $? -eq 0 ]; then
    echo "$AI_OUTPUT"
else
    echo "内容已被拦截"
fi
```

### 配置

在可执行文件同目录下创建 `filter.yaml` 文件来自定义规则：

```yaml
mode: moderate  # strict（严格）, moderate（适中）, 或 loose（宽松）

rules:
  keywords:
    banned:
      - "自定义禁用词"
      - "另一个禁用词"
    
    warning:
      - "警告词"
  
  patterns:
    - pattern: "危险.*模式"
      name: "自定义模式"
      severity: 0.9
      action: block
  
  whitelist:
    contexts:
      - "教育目的"
      - "医学讨论"
```

查看 `filter.example.yaml` 获取完整配置示例。

### 从源码构建

#### 前置要求

1. 安装 Rust: https://rustup.rs/
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

2. 克隆仓库：
```bash
git clone https://github.com/your-repo/ai-content-filter.git
cd ai-content-filter
```

#### 编译

```bash
# 调试构建（编译更快）
cargo build

# 发布构建（优化后，体积更小）
cargo build --release

# 可执行文件将在 target/release/ai-content-filter
```

#### 交叉编译

```bash
# 安装交叉编译目标
rustup target add x86_64-pc-windows-gnu
rustup target add x86_64-apple-darwin

# 为 Windows 编译（从 Linux/Mac）
cargo build --release --target x86_64-pc-windows-gnu

# 为 macOS 编译（从 Linux）
cargo build --release --target x86_64-apple-darwin
```

### 输出格式

过滤器返回以下结构的 JSON：

```json
{
  "safe": true,
  "score": 0.95,
  "filtered_content": null,
  "reason": null,
  "matched_rules": []
}
```

- `safe`: 布尔值，表示内容是否安全
- `score`: 安全分数（0.0-1.0，越高越安全）
- `filtered_content`: 过滤后的版本，不当内容被替换（如果启用）
- `reason`: 拦截原因（如果被拦截）
- `matched_rules`: 触发的规则列表

### 许可证

MIT 许可证
