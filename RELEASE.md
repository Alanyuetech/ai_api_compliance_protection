# Creating a Release / 创建发布版本

## Automatic Release (GitHub Actions) / 自动发布

The easiest way is to use GitHub Actions:

1. Push a version tag to trigger automatic build:
```bash
git tag v1.0.0
git push origin v1.0.0
```

2. Or manually trigger from GitHub Actions page:
   - Go to Actions tab
   - Select "Build and Release" workflow
   - Click "Run workflow"
   - Enter version (e.g., v1.0.0)

## Manual Release / 手动发布

### Step 1: Build Binaries / 构建二进制文件

```bash
# Using Docker (recommended)
./build-all-platforms.sh

# Binaries will be in ./bin/ directory:
# - ai-filter-linux
# - ai-filter-windows.exe
```

### Step 2: Create GitHub Release / 创建 GitHub 发布

1. Go to https://github.com/Alanyuetech/ai_api_compliance_protection/releases
2. Click "Create a new release"
3. Choose a tag (e.g., v1.0.0)
4. Title: "AI Content Filter v1.0.0"
5. Upload binaries from `./bin/` directory
6. Add release notes:

```markdown
## AI Content Filter v1.0.0

### Downloads
- **Linux**: [ai-filter-linux](link)
- **Windows**: [ai-filter-windows.exe](link)
- **macOS**: Build from source or use GitHub Actions

### Installation
1. Download the binary for your platform
2. Make it executable: `chmod +x ai-filter-*` (Linux/macOS)
3. Run: `./ai-filter-* check "test content"`

### Features
- Ultra-fast content filtering
- Offline operation
- Customizable rules
- Cross-platform support
```

7. Click "Publish release"

## Current Pre-built Binaries / 当前预编译版本

Located in `./bin/`:
- `ai-filter-linux` (2.1MB) - Linux x86_64
- `ai-filter-windows.exe` (1.8MB) - Windows x86_64

To upload these to GitHub Release:
1. Create a new release on GitHub
2. Upload these files as release assets
3. Users can then download from the Releases page

## Testing Before Release / 发布前测试

```bash
# Test Linux binary
./bin/ai-filter-linux check "test content"

# Run full test suite
./test.sh
```