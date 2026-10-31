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
# Serial Tool 卸载脚本

INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/serial"

echo "Serial Tool 卸载程序"
echo "===================="
echo ""

read -p "是否删除配置文件? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$CONFIG_DIR"
    echo "✓ 配置文件已删除"
else
    echo "✓ 配置文件保留在 $CONFIG_DIR"
fi

if [ -f "$INSTALL_DIR/serial" ]; then
    rm "$INSTALL_DIR/serial"
    echo "✓ 脚本已删除"
else
    echo "✓ 脚本不存在"
fi

echo ""
echo "卸载完成"
