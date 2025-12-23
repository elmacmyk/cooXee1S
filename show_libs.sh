#!/bin/bash

if [ -z "$1" ]; then
    echo "用法: $0 <PID>"
    echo "示例: $0 9891"
    exit 1
fi

PID=$1

# 保存原始输出头
lsof -p $PID 2>/dev/null | head -1 | awk '{
    printf "%-10s %5s %-8s %3s %20s %15s %12s %10s %s\n", 
    $1, $2, $3, $4, $5, "SIZE_FORMAT", $7, $8, $9
}'

# 处理每一行数据
lsof -p $PID 2>/dev/null | tail -n +2 | awk '
{
    size = $7
    
    # 格式化大小
    if (size ~ /[0-9]+/) {
        if (size < 1024) {
            size_fmt = sprintf("%10dB", size)
        } else if (size < 1024*1024) {
            size_fmt = sprintf("%9.1fKB", size/1024)
        } else if (size < 1024*1024*1024) {
            size_fmt = sprintf("%9.1fMB", size/(1024*1024))
        } else {
            size_fmt = sprintf("%9.1fGB", size/(1024*1024*1024))
        }
    } else {
        size_fmt = size
    }
    
    # 输出原始行，将 SIZE/OFF 替换为格式化版本
    printf "%-10s %5s %-8s %3s %20s %15s %12s %10s", $1, $2, $3, $4, $5, $6, size_fmt, $8
    for (i = 9; i <= NF; i++) printf " %s", $i
    printf "\n"
}'
