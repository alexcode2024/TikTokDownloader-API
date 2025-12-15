#!/bin/bash

# 快速运行脚本（假设虚拟环境已创建）
# 用法: ./run.sh [api]
#   - 不带参数: 启动UI模式
#   - 带api参数: 启动API模式

VENV_DIR="venv"

if [ ! -d "$VENV_DIR" ]; then
    echo "错误: 虚拟环境不存在！"
    echo "请先运行: ./setup_and_run.sh"
    exit 1
fi

# 激活虚拟环境并运行
source "$VENV_DIR/bin/activate"

if [ "$1" == "api" ]; then
    echo "启动项目 (API模式)..."
else
    echo "启动项目 (UI模式)..."
    echo "提示: 使用 './run.sh api' 启动API模式"
fi

python main.py "$@"

