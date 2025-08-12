# Project Structure Guide / 项目结构指南

## Directory Structure / 目录结构

```
ai_api_compliance_protection/
│
├── 📂 src/                        # Rust source code / Rust 源代码
│   ├── main.rs                   # CLI entry point / 命令行入口
│   ├── filter.rs                 # Core filtering engine / 核心过滤引擎
│   └── config.rs                 # Configuration management / 配置管理
│
├── 📂 config/                     # Configuration files / 配置文件
│   └── default_rules.yaml        # Default filter rules / 默认过滤规则
│
├── 📂 examples/                   # Integration examples / 集成示例
│   ├── python_example.py         # Python usage example / Python 使用示例
│   └── nodejs_example.js         # Node.js usage example / Node.js 使用示例
│
├── 📂 bin/ (git-ignored)          # Compiled binaries / 编译后的二进制文件
│   ├── ai-filter-linux           # Linux executable / Linux 可执行文件
│   ├── ai-filter-windows.exe     # Windows executable / Windows 可执行文件
│   └── ai-filter-macos           # macOS executable / macOS 可执行文件
│
├── 📂 .github/                    # GitHub configuration / GitHub 配置
│   └── workflows/                # GitHub Actions / GitHub 自动化工作流
│       ├── release.yml           # Full release workflow / 完整发布工作流
│       ├── build-macos.yml       # macOS build workflow / macOS 构建工作流
│       └── build-macos-simple.yml # Simplified macOS workflow / 简化的 macOS 工作流
│
├── 📄 Build Scripts / 构建脚本
│   ├── build.sh                  # Simple Rust build / 简单 Rust 构建
│   ├── build-all-platforms.sh    # Multi-platform build / 多平台构建
│   ├── build-docker.sh           # Docker-based build / Docker 构建
│   └── package-release.sh        # Package for release / 打包发布版本
│
├── 📄 Configuration Files / 配置文件
│   ├── .env (git-ignored)        # Local environment variables / 本地环境变量
│   ├── .env.example              # Environment template / 环境变量模板
│   ├── Cargo.toml                # Rust project config / Rust 项目配置
│   ├── Cargo.lock                # Rust dependencies / Rust 依赖锁定
│   └── filter.example.yaml       # Custom filter example / 自定义过滤示例
│
├── 📄 Docker Files / Docker 文件
│   ├── Dockerfile                # Standard Docker build / 标准 Docker 构建
│   ├── Dockerfile.cross          # Cross-platform build / 跨平台构建
│   └── docker-compose.yml        # Docker Compose config / Docker Compose 配置
│
├── 📄 Documentation / 文档
│   ├── README.md                 # Main documentation / 主文档
│   ├── INSTALL.md                # Installation guide / 安装指南
│   ├── RELEASE.md                # Release process / 发布流程
│   ├── PROJECT_STRUCTURE.md     # This file / 本文件
│   └── LICENSE                   # MIT License / MIT 许可证
│
├── 📄 Scripts / 脚本
│   ├── test.sh                   # Test script / 测试脚本
│   └── upload-release.sh         # Upload to GitHub / 上传到 GitHub
│
└── 📄 Git Files / Git 文件
    ├── .gitignore                # Ignore rules / 忽略规则
    └── .git/                     # Git repository / Git 仓库

```

## File Categories / 文件分类

### 🔧 Core Files (Required) / 核心文件（必需）
- `src/*.rs` - Rust source code / Rust 源代码
- `Cargo.toml` - Project definition / 项目定义
- `config/default_rules.yaml` - Built-in rules / 内置规则

### 📦 Build Outputs (Generated) / 构建输出（生成的）
- `bin/*` - Compiled executables / 编译的可执行文件
- `target/` - Rust build directory / Rust 构建目录

### 🔐 Sensitive Files (Never Commit) / 敏感文件（绝不提交）
- `.env` - Contains GitHub token and secrets / 包含 GitHub token 和密钥
- `*.key`, `*.pem` - Private keys / 私钥文件

### 🚀 Release Files / 发布文件
- `upload-release.sh` - Automated release script / 自动发布脚本
- `package-release.sh` - Package binaries / 打包二进制文件
- `.github/workflows/*` - CI/CD automation / CI/CD 自动化

### 📚 Documentation / 文档
- `README.md` - User guide / 用户指南
- `INSTALL.md` - Build instructions / 构建说明
- `.env.example` - Configuration template / 配置模板

## Important Notes / 重要说明

### Environment Setup / 环境设置
1. Copy `.env.example` to `.env` / 复制 `.env.example` 为 `.env`
2. Add your GitHub token / 添加您的 GitHub token
3. Never commit `.env` file / 绝不提交 `.env` 文件

### Building the Project / 构建项目
```bash
# With Rust installed / 安装 Rust 后
./build.sh

# With Docker (no Rust needed) / 使用 Docker（无需 Rust）
./build-docker.sh

# Multi-platform / 多平台
./build-all-platforms.sh
```

### Creating a Release / 创建发布
```bash
# Set up .env first / 先设置 .env
cp .env.example .env
nano .env  # Add your GitHub token / 添加您的 token

# Upload release / 上传发布
./upload-release.sh
```

### Testing / 测试
```bash
# Run tests / 运行测试
./test.sh

# Test specific content / 测试特定内容
./bin/ai-filter-linux check "test content"
```

## Git-Ignored Files / Git 忽略的文件
- `.env` - Environment variables / 环境变量
- `bin/` - Compiled binaries / 编译的二进制文件
- `target/` - Build artifacts / 构建产物
- `*.tar.gz`, `*.zip` - Package files / 打包文件
- `release-*/` - Temporary release directories / 临时发布目录

## Security Notes / 安全说明
1. **Never commit tokens** / 绝不提交 token
2. **Use .env for secrets** / 使用 .env 存储密钥
3. **Check files before committing** / 提交前检查文件
4. **Keep .gitignore updated** / 保持 .gitignore 更新