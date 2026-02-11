# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个用于管理 Claude Code 进程的 Bash 命令行工具。当开发者在多个 VS Code 窗口或终端中同时运行多个 Claude 实例时，该工具可以：
- 列出所有正在运行的 Claude 进程及其工作目录
- 检测并标识重复进程（在同一工程目录运行的多个实例）
- 提供便捷的进程关闭操作

## 常用命令

```bash
# 列出所有 Claude 进程
./claude-manager.sh ls

# 关闭指定 PID 的进程
./claude-manager.sh kill <pid>

# 自动检测并关闭重复进程
./claude-manager.sh kill-dup

# 实时监控进程状态（每 5 秒刷新）
./claude-manager.sh watch

# 查看帮助
./claude-manager.sh help
```

## 架构说明

### 核心设计原则

1. **进程发现机制**：使用 `ps aux | grep -i 'claude'` 查找进程，排除了 `claude-code-acp` 和 `context7-mcp` 等相关进程（第 18 行）

2. **工作目录获取**：通过 `lsof -p <pid> | grep ' cwd '` 获取进程的当前工作目录，这是判断进程是否重复的关键

3. **颜色编码系统**：
   - 红色：重复工程（硬编码检测 "MyApplication"，第 76 行）
   - 黄色：在 home 目录运行（检测路径以 `~` 结尾或 `/Users/a0000`）
   - 绿色：正常进程

4. **安全确认机制**：所有 `kill` 操作都需要用户确认，`kill-all` 甚至需要输入完整的 "YES"

### 需要注意的实现细节

- **Bash 严格模式**：脚本使用 `set -euo pipefail` 确保错误时退出
- **变量作用域**：`kill_duplicates` 函数中使用关联数组 `declare -A` 和普通数组 `declare -a`，注意在子 shell 中（while read）数组修改不会传递到父 shell，这是该函数的一个已知限制
- **路径截断**：工作目录超过 45 字符时会截断显示为 `...` + 最后 42 个字符
- **可移植性**：设计为在 macOS 和 Linux 上运行，依赖标准 Unix 工具（`ps`, `lsof`, `kill`）

### 扩展建议

修改硬编码的项目检测逻辑时，需要更新 `list_processes` 函数中的检测条件（第 76-82 行）。目前重复检测是硬编码的，如果需要动态检测真正的重复，需要重构这部分逻辑。
