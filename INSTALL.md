# Installation Guide / 安装指南

## Quick Install (For Users) / 快速安装（用户）

### Download Pre-compiled Binaries / 下载预编译版本

The easiest way is to download pre-compiled binaries. No installation required!

最简单的方法是下载预编译的二进制文件，无需安装任何东西！

1. Go to [Releases](https://github.com/your-repo/releases)
2. Download the appropriate file for your system:
   - Windows: `ai-filter-windows.exe`
   - Linux: `ai-filter-linux`
   - macOS: `ai-filter-macos`
3. Make it executable (Linux/Mac): `chmod +x ai-filter-*`
4. Run it: `./ai-filter check "test content"`

## Build from Source (For Developers) / 从源码构建（开发者）

### Step 1: Install Rust / 第一步：安装 Rust

```bash
# Official installation method / 官方安装方法
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Follow the on-screen instructions / 按照屏幕提示操作
# Restart your terminal or run / 重启终端或运行:
source $HOME/.cargo/env
```

Alternative for Windows / Windows 替代方法:
- Download from: https://rustup.rs/
- Run the installer
- Restart your terminal

### Step 2: Clone and Build / 第二步：克隆并构建

```bash
# Clone the repository / 克隆仓库
git clone https://github.com/your-repo/ai-content-filter.git
cd ai-content-filter

# Build the project / 构建项目
cargo build --release

# Or use the build script / 或使用构建脚本
./build.sh

# The binary will be in / 二进制文件位于:
# - target/release/ai-content-filter (cargo build)
# - bin/ai-filter-[platform] (build.sh)
```

### Step 3: Test Installation / 第三步：测试安装

```bash
# Test the filter / 测试过滤器
./bin/ai-filter-linux check "Hello world"

# Or if you built with cargo / 或如果你用 cargo 构建
./target/release/ai-content-filter check "Hello world"

# Run full test suite / 运行完整测试
./test.sh
```

## Troubleshooting / 故障排除

### Rust Installation Issues / Rust 安装问题

If you encounter issues installing Rust:
如果安装 Rust 时遇到问题：

1. **Permission denied / 权限被拒绝**:
   ```bash
   # Use sudo or run as administrator
   # 使用 sudo 或以管理员身份运行
   sudo curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sudo sh
   ```

2. **Behind proxy / 代理环境**:
   ```bash
   export HTTPS_PROXY=http://your-proxy:port
   export HTTP_PROXY=http://your-proxy:port
   ```

3. **Offline installation / 离线安装**:
   - Download standalone installer from https://forge.rust-lang.org/infra/channel-layout.html
   - 从 https://forge.rust-lang.org/infra/channel-layout.html 下载独立安装程序

### Build Issues / 构建问题

1. **Out of memory / 内存不足**:
   ```bash
   # Build with less parallelism / 减少并行度构建
   cargo build --release -j 1
   ```

2. **Missing dependencies / 缺少依赖**:
   ```bash
   # Update cargo index / 更新 cargo 索引
   cargo update
   ```

3. **Cross-compilation / 交叉编译**:
   ```bash
   # Install target / 安装目标平台
   rustup target add x86_64-pc-windows-gnu
   
   # Build for target / 为目标平台构建
   cargo build --release --target x86_64-pc-windows-gnu
   ```

## System Requirements / 系统要求

### For Running Pre-compiled Binary / 运行预编译版本

- **Minimum / 最低要求**:
  - Any 64-bit OS (Windows 7+, Ubuntu 16.04+, macOS 10.12+)
  - 50MB free disk space
  - 128MB RAM

### For Building from Source / 从源码构建

- **Minimum / 最低要求**:
  - 2GB RAM
  - 1GB free disk space
  - Internet connection (for downloading dependencies)
  - Rust 1.70.0 or later

## Docker Alternative / Docker 替代方案

If you prefer not to install Rust, you can use Docker:
如果您不想安装 Rust，可以使用 Docker：

```dockerfile
# Dockerfile
FROM rust:1.70 as builder
WORKDIR /app
COPY . .
RUN cargo build --release

FROM debian:bullseye-slim
COPY --from=builder /app/target/release/ai-content-filter /usr/local/bin/ai-filter
CMD ["ai-filter"]
```

Build and run:
```bash
docker build -t ai-filter .
docker run --rm ai-filter check "test content"
```

## Support / 支持

If you encounter any issues / 如果遇到任何问题:
- Open an issue on GitHub / 在 GitHub 上提交问题
- Check existing issues / 查看现有问题
- Contact support / 联系支持