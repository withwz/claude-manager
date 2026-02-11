# Claude 进程管理器

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/shell-bash-green.svg)](https://github.com/withwz/claude-manager)
[![GitHub stars](https://img.shields.io/github/stars/withwz/claude-manager?style=social)](https://github.com/withwz/claude-manager/stargazers)

一个专门管理 Claude Code 进程的命令行工具，解决多个 VS Code 窗口中运行多个 Claude 导致的资源混乱问题。

---

## 🎯 为什么需要这个工具？

开发时经常遇到：

- 😵 同一个工程在不同终端/VS Code 窗口中运行多个 Claude
- 🧠 忘记关闭之前的进程，导致资源浪费
- 🔍 需要快速定位某个工程对应的进程

**这个工具让进程管理一目了然。**

---

## ✨ 功能特性

| 功能 | 说明 |
|------|------|
| 📋 **进程列表** | 一键查看所有 Claude 进程及其工作目录 |
| 🔍 **重复检测** | 自动识别运行在同一工程的重复进程 |
| 🎯 **智能分类** | 根据运行状态智能着色显示 |
| ⚡ **快速操作** | 一键关闭指定或所有进程 |
| 👀 **实时监控** | 持续刷新进程状态（每5秒） |

### 智能分类说明

- 🔴 **红色**：重复进程（建议关闭其中一个）
- 🟡 **黄色**：在 home 目录运行（可能需要检查）
- 🟢 **绿色**：正常运行

---

## 🚀 快速开始

### 安装

```bash
# 方式1：克隆仓库
git clone https://github.com/withwz/claude-manager.git
cd claude-manager

# 方式2：下载脚本
wget https://raw.githubusercontent.com/withwz/claude-manager/main/claude-manager.sh
chmod +x claude-manager.sh

# （可选）添加到 PATH
sudo mv claude-manager.sh /usr/local/bin/claude-manager
```

### 配置全局命令（推荐）

```bash
# 添加到 ~/.zshrc
echo '' >> ~/.zshrc
echo '# Claude 进程管理器' >> ~/.zshrc
echo 'alias claudekls="bash /path/to/claude-manager.sh ls"' >> ~/.zshrc
echo 'alias claudekill="bash /path/to/claude-manager.sh kill"' >> ~/.zshrc
echo 'alias claudekilldup="bash /path/to/claude-manager.sh kill-dup"' >> ~/.zshrc
echo 'alias claudekillall="bash /path/to/claude-manager.sh kill-all"' >> ~/.zshrc
echo 'alias claudewatch="bash /path/to/claude-manager.sh watch"' >> ~/.zshrc

# 重载配置
source ~/.zshrc
```

### 使用方法

```bash
# 查看所有 Claude 进程
claudekls

# 关闭指定 PID 的进程
claudekill 46316

# 自动关闭重复进程
claudekilldup

# 关闭所有进程（慎用！）
claudekillall

# 实时监控进程状态
claudewatch

# 查看帮助
claude-manager.sh help
```

---

## 📸 输出示例

```
╔═══════════════════════════════════════════════════════════════╗
║           Claude 进程管理器                                   ║
╚═══════════════════════════════════════════════════════════════╝

PID    TTY      PPID     Parent               工作目录                                       运行时间
======================================================================================================================================================
92815  s009     76591    /bin/zsh             /Users/a0000/Desktop/dk/ty/MyApplication           01:51
94415  s009     53091    openclaw-gateway     /Users/a0000/.openclaw/workspace                   00:01
15731  s010     14142    /bin/zsh             ...noh/rnoh_samples/Samples/AutolinkingSample      19:14:43
46316  s002     45495    /bin/zsh             /Users/a0000                                       01-00:42:30

提示:
  🔴 红色: 重复工程 (建议关闭其中一个)
  🟡 黄色: 在 home 目录运行 (可能需要检查)
  🟢 绿色: 正常
```

---

## 🔧 工作原理

1. **进程发现**
   ```bash
   ps aux | grep -i 'claude' | grep -v grep
   ```

2. **获取工作目录**
   ```bash
   lsof -p <PID> | grep cwd
   ```

3. **智能分析**
   - 检测重复的工作目录
   - 标识异常运行位置（如 home 目录）
   - 显示父进程信息和运行时间

4. **安全关闭**
   - 关闭前需要二次确认
   - 避免误操作

---

## 📦 系统要求

| 项目 | 要求 |
|------|------|
| 操作系统 | macOS 或 Linux |
| Shell | bash |
| `ps` 命令 | 系统自带 |
| `lsof` 命令 | macOS 自带，Linux 通常已安装 |

---

## 🤝 License

[MIT](LICENSE) © 2024 武昭

---

## 🌟 Star History

如果这个工具对你有帮助，请给个 ⭐ Star！

[![Star History Chart](https://api.star-history.com/iframe?index=0.0&style=for-the-badge&max=100&mode=weekly&owner=withwz&repo=claude-manager&type=Date)](https://star-history.com/#withwz/claude-manager&Date)
