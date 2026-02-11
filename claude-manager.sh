#!/bin/bash

# Claude 进程管理工具
# 功能：列出、查看、关闭 Claude 进程

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 获取所有 claude 进程
get_claude_processes() {
    ps aux | grep -i 'claude' | grep -v grep | grep -v 'claude-code-acp' | grep -v 'context7-mcp'
}

# 获取进程的工作目录
get_cwd() {
    local pid=$1
    lsof -p "$pid" 2>/dev/null | grep ' cwd ' | awk '{print $9}' || echo "(unknown)"
}

# 获取进程的父进程和终端信息
get_process_info() {
    local pid=$1
    local tty=$(ps -p "$pid" -o tty= | tr -d ' ')
    local ppid=$(ps -p "$pid" -o ppid= | tr -d ' ')
    local command=$(ps -p "$pid" -o command=)

    # 获取父进程名称
    local parent_name=""
    if [[ -n "$ppid" ]] && [[ "$ppid" != "1" ]]; then
        parent_name=$(ps -p "$ppid" -o comm= 2>/dev/null || echo "")
    fi

    echo "$tty|$ppid|$parent_name"
}

# 列出所有 Claude 进程
list_processes() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}           ${GREEN}Claude 进程管理器${NC}                           ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}\n"

    local processes=$(get_claude_processes)

    if [[ -z "$processes" ]]; then
        echo -e "${YELLOW}没有找到 Claude 进程${NC}"
        return
    fi

    # 表头
    printf "${BLUE}%-6s %-8s %-8s %-20s %-50s %-10s${NC}\n" "PID" "TTY" "PPID" "Parent" "工作目录" "运行时间"
    echo -e "${BLUE}$(printf '=%.0s' {1..150})${NC}"

    local count=0
    echo "$processes" | while read -r line; do
        local pid=$(echo "$line" | awk '{print $2}')
        local tty=$(echo "$line" | awk '{print $3}')
        local ppid=$(ps -p "$pid" -o ppid= | tr -d ' ')
        local parent=$(ps -p "$ppid" -o comm= 2>/dev/null || echo "unknown")
        local cwd=$(get_cwd "$pid")
        local time=$(echo "$line" | awk '{print $10}')
        local elapsed=$(ps -p "$pid" -o etime= | tr -d ' ')

        # 截断目录名
        if [[ ${#cwd} -gt 45 ]]; then
            cwd="...${cwd: -42}"
        fi

        # 高亮重复的工程目录
        if [[ "$cwd" == *"MyApplication"* ]]; then
            printf "${RED}%-6s %-8s %-8s %-20s %-50s %-10s${NC}\n" "$pid" "$tty" "$ppid" "$parent" "$cwd" "$elapsed"
        elif [[ "$cwd" == *"~"* ]] || [[ "$cwd" == *"/Users/a0000"$ ]]; then
            printf "${YELLOW}%-6s %-8s %-8s %-20s %-50s %-10s${NC}\n" "$pid" "$tty" "$ppid" "$parent" "$cwd" "$elapsed"
        else
            printf "${GREEN}%-6s %-8s %-8s %-20s %-50s %-10s${NC}\n" "$pid" "$tty" "$ppid" "$parent" "$cwd" "$elapsed"
        fi

        ((count++))
    done

    echo -e "\n${CYAN}提示:${NC}"
    echo -e "  ${RED}红色${NC}: 重复工程 (建议关闭其中一个)"
    echo -e "  ${YELLOW}黄色${NC}: 在 home 目录运行 (可能需要检查)"
    echo -e "  ${GREEN}绿色${NC}: 正常"
}

# 杀掉指定进程
kill_process() {
    local pid=$1
    local cwd=$(get_cwd "$pid")

    echo -e "${YELLOW}即将关闭进程 $pid (在 $cwd)${NC}"
    echo -e "${RED}确定要关闭吗? (y/N)${NC}"

    read -r confirm
    if [[ "$confirm" == "y" ]] || [[ "$confirm" == "Y" ]]; then
        kill "$pid"
        echo -e "${GREEN}进程 $pid 已关闭${NC}"
    else
        echo -e "${YELLOW}已取消${NC}"
    fi
}

# 杀掉所有重复的进程
kill_duplicates() {
    echo -e "${CYAN}检测重复的 Claude 进程...${NC}\n"

    declare -A dir_pids
    declare -a dup_pids

    # 收集所有进程的工作目录和PID
    get_claude_processes | while read -r line; do
        local pid=$(echo "$line" | awk '{print $2}')
        local cwd=$(get_cwd "$pid")

        if [[ "$cwd" != "(unknown)" ]]; then
            # 检查是否重复
            local existing=$(echo "$dir_pids[$cwd]" 2>/dev/null || echo "")
            if [[ -n "$existing" ]]; then
                echo -e "${YELLOW}发现重复:${NC} $cwd"
                echo -e "  进程: $existing, $pid"
                dup_pids+=("$pid")
            else
                dir_pids[$cwd]=$pid
            fi
        fi
    done

    if [[ ${#dup_pids[@]} -eq 0 ]]; then
        echo -e "${GREEN}没有发现重复的进程${NC}"
        return
    fi

    echo -e "\n${YELLOW}建议关闭的重复进程: ${dup_pids[*]}${NC}"
    echo -e "${RED}是否关闭? (y/N)${NC}"

    read -r confirm
    if [[ "$confirm" == "y" ]] || [[ "$confirm" == "Y" ]]; then
        for pid in "${dup_pids[@]}"; do
            kill "$pid" 2>/dev/null && echo -e "${GREEN}✓ 已关闭 $pid${NC}"
        done
    fi
}

# 杀掉所有 Claude 进程（慎用）
kill_all() {
    echo -e "${RED}警告: 这将关闭所有 Claude 进程!${NC}"
    echo -e "${YELLOW}确定要继续吗? (输入 YES 确认):${NC}"

    read -r confirm
    if [[ "$confirm" != "YES" ]]; then
        echo -e "${YELLOW}已取消${NC}"
        return
    fi

    local count=0
    get_claude_processes | while read -r line; do
        local pid=$(echo "$line" | awk '{print $2}')
        kill "$pid" 2>/dev/null && ((count++))
    done

    echo -e "${GREEN}已关闭 $count 个 Claude 进程${NC}"
}

# 显示帮助
show_help() {
    cat << EOF
${CYAN}Claude 进程管理器${NC}

用法:
  $0 [命令]

命令:
  ${GREEN}list${NC}, ${GREEN}ls${NC}           列出所有 Claude 进程
  ${GREEN}kill${NC} <pid>         关闭指定进程
  ${GREEN}kill-dup${NC}          关闭重复的进程
  ${GREEN}kill-all${NC}          关闭所有进程 (慎用)
  ${GREEN}watch${NC}              持续监控进程状态
  ${GREEN}help${NC}              显示此帮助信息

示例:
  $0 ls                  # 查看所有进程
  $0 kill 46316          # 关闭指定PID
  $0 kill-dup            # 清理重复进程
  $0 watch               # 实时监控

EOF
}

# 实时监控
watch_mode() {
    while true; do
        clear
        list_processes
        echo -e "\n${CYAN}按 Ctrl+C 退出 (每5秒刷新)${NC}"
        sleep 5
    done
}

# 主函数
main() {
    case "${1:-ls}" in
        list|ls)
            list_processes
            ;;
        kill)
            if [[ -z "${2:-}" ]]; then
                echo -e "${RED}错误: 需要指定 PID${NC}"
                echo "用法: $0 kill <pid>"
                exit 1
            fi
            kill_process "$2"
            ;;
        kill-dup)
            kill_duplicates
            ;;
        kill-all)
            kill_all
            ;;
        watch)
            watch_mode
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}未知命令: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
