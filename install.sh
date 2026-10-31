#!/bin/bash
#
# Copyright 2026 jiaqi
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Serial Tool 安装脚本

set -e

INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/serial"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Serial Tool 安装程序"
echo "===================="
echo ""

# 检查依赖
echo "检查依赖..."
if ! command -v tio &> /dev/null; then
    echo "错误: 未安装 tio"
    echo "请运行: sudo apt install tio"
    exit 1
fi
echo "✓ tio 已安装"

# 创建目录
echo ""
echo "创建目录..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"
echo "✓ 目录创建完成"

# 安装脚本
echo ""
echo "安装脚本..."
cp "$SCRIPT_DIR/bin/serial" "$INSTALL_DIR/serial"
chmod +x "$INSTALL_DIR/serial"
echo "✓ 脚本已安装到 $INSTALL_DIR/serial"

# 检查 PATH
echo ""
echo "检查 PATH..."
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "警告: $INSTALL_DIR 不在 PATH 中"
    echo "请添加以下内容到 ~/.bashrc:"
    echo ""
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    echo ""
    read -p "是否自动添加? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> ~/.bashrc
        echo "✓ 已添加到 ~/.bashrc，请运行: source ~/.bashrc"
    fi
else
    echo "✓ PATH 配置正确"
fi

# 配置文件
echo ""
echo "配置文件..."
if [ ! -f "$CONFIG_DIR/devices.conf" ]; then
    touch "$CONFIG_DIR/devices.conf"
    echo "✓ 创建空配置文件: $CONFIG_DIR/devices.conf"
else
    echo "✓ 配置文件已存在: $CONFIG_DIR/devices.conf"
fi

if [ ! -f "$CONFIG_DIR/auto-rules.conf" ]; then
    touch "$CONFIG_DIR/auto-rules.conf"
    echo "✓ 创建空规则文件: $CONFIG_DIR/auto-rules.conf"
else
    echo "✓ 规则文件已存在: $CONFIG_DIR/auto-rules.conf"
fi

# 复制示例配置
echo ""
read -p "是否复制示例配置文件? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cp "$SCRIPT_DIR/config/devices.conf.example" "$CONFIG_DIR/devices.conf.example"
    cp "$SCRIPT_DIR/config/auto-rules.conf.example" "$CONFIG_DIR/auto-rules.conf.example"
    echo "✓ 示例配置已复制:"
    echo "  - $CONFIG_DIR/devices.conf.example"
    echo "  - $CONFIG_DIR/auto-rules.conf.example"
fi

# 完成
echo ""
echo "===================="
echo "安装完成！"
echo ""
echo "快速开始:"
echo "  serial detect           # 扫描设备"
echo "  serial detect --auto    # 自动配置"
echo "  serial list             # 查看设备"
echo "  serial                  # 查看帮助"
echo ""
echo "文档: $SCRIPT_DIR/README.md"
echo "配置: $CONFIG_DIR/"
