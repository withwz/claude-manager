# Claude 进程管理器

一个专门管理 Claude Code 进程的命令行工具，解决多个 VS Code 窗口中运行多个 Claude 导致的资源混乱问题。

## 功能特性

- 📋 **进程列表**：一键查看所有 Claude 进程及其工作目录
- 🔍 **重复检测**：自动识别运行在同一工程的重复进程
- 🎯 **智能分类**：
  - 🔴 红色：重复进程（建议关闭）
  - 🟡 黄色：home 目录运行（可能需要检查）
  - 🟢 绿色：正常运行
- ⚡ **快速操作**：一键关闭指定或所有进程
- 👀 **实时监控**：持续刷新进程状态

## 安装

```bash
# 克隆项目
git clone <your-repo-url>
cd myproject

# 或者直接下载 claude-manager.sh
chmod +x claude-manager.sh
```

## 使用方法

```bash
# 查看所有 Claude 进程
./claude-manager.sh ls

# 关闭指定 PID 的进程
./claude-manager.sh kill 46316

# 自动关闭重复进程
./claude-manager.sh kill-dup

# 关闭所有进程（慎用！）
./claude-manager.sh kill-all

# 实时监控进程状态（每5秒刷新）
./claude-manager.sh watch

# 查看帮助
./claude-manager.sh help
```

## 输出示例

```
╔═══════════════════════════════════════════════════════════════╗
║           Claude 进程管理器                                   ║
╚═══════════════════════════════════════════════════════════════╝

PID    TTY      PPID     Parent               工作目录                                       运行时间
======================================================================================================================================================
92815  s009     76591    /bin/zsh             /Users/a0000/Desktop/dk/ty/MyApplication           01:51
94415  1.9      53091    openclaw-gateway     /Users/a0000/.openclaw/workspace                   00:01
15731  s010     14142    /bin/zsh             ...noh/rnoh_samples/Samples/AutolinkingSample      19:14:43
46316  s002     45495    /bin/zsh             /Users/a0000                                       01-00:42:30

提示:
  红色: 重复工程 (建议关闭其中一个)
  黄色: 在 home 目录运行 (可能需要检查)
  绿色: 正常
```

## 工作原理

1. **进程发现**：使用 `ps` 命令查找所有 Claude 相关进程
2. **工作目录**：通过 `lsof` 获取每个进程的当前工作目录 (cwd)
3. **智能分析**：
   - 检测重复的工作目录
   - 标识异常运行位置（如 home 目录）
   - 显示父进程信息和运行时间
4. **安全关闭**：关闭前需要二次确认，避免误操作

## 为什么需要这个工具？

开发时经常遇到：
- 同一个工程在不同终端/VS Code 窗口中运行多个 Claude
- 忘记关闭之前的进程，导致资源浪费
- 需要快速定位某个工程对应的进程

这个工具让进程管理一目了然。

## 系统要求

- macOS 或 Linux
- bash shell
- `ps` 命令（系统自带）
- `lsof` 命令（macOS 自带，Linux 通常已安装）

## License

MIT
