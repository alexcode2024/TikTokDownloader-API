#!/bin/bash

# 设置脚本：创建虚拟环境并运行项目

set -e  # 遇到错误时退出

echo "========================================="
echo "DouK-Downloader 环境设置脚本"
echo "========================================="

# 检查Python版本
echo "检查Python版本..."

# 首先尝试查找python3.12
PYTHON_CMD=""
if command -v python3.12 &> /dev/null; then
    PYTHON_CMD="python3.12"
    python_version=$(python3.12 --version 2>&1 | awk '{print $2}' | cut -d. -f1,2)
    echo "找到Python 3.12: $python_version"
elif python3 --version 2>&1 | grep -q "3.12"; then
    PYTHON_CMD="python3"
    python_version=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1,2)
    echo "Python版本检查通过: $python_version"
else
    python_version=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1,2)
    required_version="3.12"
    
    echo ""
    echo "❌ 错误: 需要Python 3.12，当前版本: $python_version"
    echo ""
    echo "💡 提示: 可以运行 ./install_python312.sh 自动安装"
    echo ""
    echo "或者手动安装，可以使用以下方法："
    echo ""
    echo "方法1: 使用deadsnakes PPA (Ubuntu/Debian)"
    echo "  sudo apt update"
    echo "  sudo apt install software-properties-common"
    echo "  sudo add-apt-repository ppa:deadsnakes/ppa"
    echo "  sudo apt update"
    echo "  sudo apt install python3.12 python3.12-venv python3.12-dev"
    echo ""
    echo "方法2: 使用pyenv (推荐)"
    echo "  curl https://pyenv.run | bash"
    echo "  # 然后添加到 ~/.bashrc:"
    echo "  export PYENV_ROOT=\"\$HOME/.pyenv\""
    echo "  export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
    echo "  eval \"\$(pyenv init -)\""
    echo "  # 重新加载shell后:"
    echo "  pyenv install 3.12"
    echo "  pyenv local 3.12"
    echo ""
    echo "方法3: 从源码编译安装"
    echo "  # 参考: https://www.python.org/downloads/"
    echo ""
    exit 1
fi

# 设置Python命令变量供后续使用
export PYTHON_CMD=${PYTHON_CMD:-python3}

# 创建虚拟环境
VENV_DIR="venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "创建虚拟环境..."
    $PYTHON_CMD -m venv "$VENV_DIR"
    echo "虚拟环境创建成功！"
else
    echo "虚拟环境已存在，跳过创建步骤"
fi

# 激活虚拟环境
echo "激活虚拟环境..."
source "$VENV_DIR/bin/activate"

# 升级pip
echo "升级pip..."
pip install --upgrade pip

# 安装依赖
echo "安装项目依赖..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    echo "依赖安装完成！"
else
    echo "警告: 未找到requirements.txt文件"
fi

# 运行项目
echo ""
echo "========================================="
if [ "$1" == "api" ]; then
    echo "启动项目 (API模式)..."
else
    echo "启动项目 (UI模式)..."
    echo "提示: 使用 './setup_and_run.sh api' 启动API模式"
fi
echo "========================================="
python main.py "$@"

