#!/bin/bash

# 目录同步脚本
# 此脚本用于监控本地目录变化并同步到远程服务器
# 修改为固定参数，每5分钟检测一次，只在有更新时才同步

# 固定配置
LOCAL_DIR="/opt/onedev-data"
REMOTE_USER="root"
REMOTE_HOST="172.16.101.15"
REMOTE_DIR="/data/onedev-data"
SSH_PORT=22
SYNC_INTERVAL=300  # 同步间隔设置为5分钟（300秒）
LOG_FILE="/tmp/sync_directory.log"

# 日志函数
log() {
    local message="$(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "$message"
    echo "$message" >> "$LOG_FILE"
}

# 检查目录是否有更新的函数
check_directory_updated() {
    local dir="$1"
    local last_check_file="/tmp/sync_last_check"
    local current_time=$(date +%s)
    
    # 如果是首次运行，创建检查文件并返回已更新
    if [[ ! -f "$last_check_file" ]]; then
        echo "$current_time" > "$last_check_file"
        return 0  # 0表示有更新
    fi
    
    local last_check_time=$(cat "$last_check_file")
    
    # 查找最近修改的文件
    local latest_change=$(find "$dir" -type f -printf '%T@ %p\n' | sort -nr | head -1 | cut -d' ' -f1)
    
    # 如果没有找到文件，则认为没有更新
    if [[ -z "$latest_change" ]]; then
        return 1  # 1表示没有更新
    fi
    
    # 更新最后检查时间
    echo "$current_time" > "$last_check_file"
    
    # 比较最后修改时间和上次检查时间
    if (( $(echo "$latest_change > $last_check_time" | bc -l) )); then
        log "检测到目录有更新"
        return 0  # 有更新
    else
        log "目录无更新，跳过同步"
        return 1  # 没有更新
    fi
}

# 同步函数
sync_directory() {
    log "开始同步: $LOCAL_DIR -> $REMOTE_HOST:$REMOTE_DIR"
    
    # 使用rsync进行同步
    # -a: 归档模式，保留权限、时间戳等
    # -z: 压缩传输
    # -v: 详细输出
    # --delete: 删除目标目录中有而源目录中没有的文件
    # -e: 指定ssh命令及参数
    
    rsync -avz --delete \
        -e "ssh -p $SSH_PORT" \
        "$LOCAL_DIR/" \
        "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/" 2>&1 | while read line; do
            log "$line"
        done
    
    if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
        log "同步完成"
    else
        log "同步失败，错误码: ${PIPESTATUS[0]}"
    fi
}

# 确保本地目录存在
if [[ ! -d "$LOCAL_DIR" ]]; then
    log "错误: 本地目录 '$LOCAL_DIR' 不存在"
    exit 1
fi

# 检查rsync是否安装
if ! command -v rsync &> /dev/null; then
    log "错误: rsync未安装，请先安装rsync"
    exit 1
fi

# 检查bc是否安装（用于浮点数比较）
if ! command -v bc &> /dev/null; then
    log "错误: bc未安装，请先安装bc"
    exit 1
fi

# 检查SSH连接
log "检查SSH连接..."
ssh -p "$SSH_PORT" "$REMOTE_USER@$REMOTE_HOST" "mkdir -p \"$REMOTE_DIR\"" 2>&1 | while read line; do
    log "$line"
done

if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    log "错误: 无法连接到远程服务器或创建远程目录"
    exit 1
fi

# 初始同步
log "执行初始同步..."
sync_directory

# 定时检测并同步
log "启动定时检测模式，间隔: $SYNC_INTERVAL 秒"
while true; do
    sleep "$SYNC_INTERVAL"
    
    # 检查目录是否有更新
    if check_directory_updated "$LOCAL_DIR"; then
        # 如果有更新，执行同步
        sync_directory
    fi
done