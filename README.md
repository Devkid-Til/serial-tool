# Serial Tool

> 基于 tio 的串口设备管理工具

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## 项目简介

Serial Tool 是一个面向嵌入式开发者的串口设备管理脚本，解决多设备场景下的别名管理、自动配置、日志记录等问题。

### 为什么需要这个工具？

在嵌入式开发中，经常遇到：

- 🔌 **多设备混乱**：`/dev/ttyUSB0`、`/dev/ttyUSB1` 编号随插拔顺序变化
- 🏷️ **难以区分**：多个 CH341 设备，无法通过 by-id 区分（序列号相同）
- 📝 **日志分散**：串口日志没有统一管理
- 🔧 **重复配置**：每次插入新设备都要重新查询和配置

**Serial Tool 通过以下方式解决**：

- ✅ 基于 USB 物理位置（by-path）的稳定设备路径
- ✅ 设备别名映射（如 `S100-UART`）
- ✅ 规则模板自动匹配和配置
- ✅ 自动日志记录（带时间戳）
- ✅ 批量设备管理

## 功能特性

- 🎯 **设备管理**：别名、波特率、用途、备注统一管理
- 🔍 **智能检测**：自动识别芯片型号、厂商、序列号
- ⚡ **自动化**：规则模板匹配，新设备插入一键配置
- 📊 **日志记录**：自动保存带时间戳的串口日志
- 🎨 **友好交互**：彩色输出、状态提示、进度显示
- 🔧 **灵活配置**：支持手动配置和自动规则

## 快速开始

### 安装

```bash
# 克隆项目
git clone https://github.com/yourusername/serial-tool.git
cd serial-tool

# 运行安装脚本
./install.sh
```

### 基本使用

```bash
# 扫描并配置设备
serial detect

# 自动应用规则（无需交互）
serial detect --auto

# 连接设备
serial connect S100-UART

# 查看所有设备
serial list
```

### 5 分钟上手示例

```bash
# 1. 检测新设备
$ serial detect

检测到 2 个 USB 串口设备:

[1] ttyUSB0
    by-path: pci-0000:00:1d.0-usb-0:1:1.0-port0
    芯片: CH341
    状态: 未配置

[2] ttyUSB1
    by-path: pci-0000:00:1d.0-usb-0:2.1:1.0-port0
    芯片: CH341
    状态: 未配置

# 2. 添加规则
$ serial rule-add "pci-*-usb-0:1:*" S100-UART 921600 terminal "S100 UART"
$ serial rule-add "pci-*-usb-0:2.1:*" S100-BOOT 921600 log-only "S100 BOOT"

# 3. 自动配置
$ serial detect --auto

自动配置完成: 2 个设备

# 4. 连接使用
$ serial connect S100-UART
连接设备: S100-UART (S100 UART)
设备路径: /dev/serial/by-path/pci-0000:00:1d.0-usb-0:1:1.0-port0
波特率: 921600
日志文件: /tmp/serial-logs/S100-UART-20261031-135000.log
提示: Ctrl-T Q 退出
```

## 文档

- 📖 [完整使用说明](docs/USAGE.md)
- 📚 [配置示例](config/)
- 💡 [使用案例](examples/examples.md)

## 命令速查

| 命令 | 功能 |
|------|------|
| `serial list` | 列出所有配置的设备 |
| `serial detect [--auto]` | 扫描设备（可选自动配置） |
| `serial show <别名>` | 显示设备详情 |
| `serial connect <别名>` | 连接设备（交互模式） |
| `serial log <别名>` | 记录设备日志（后台） |
| `serial monitor [板子]` | tmux 多窗口监控（无参数=所有设备） |
| `serial rules` | 查看自动命名规则 |
| `serial rule-add` | 添加规则 |
| `serial raw <设备>` | 直接连接原始设备 |

完整命令说明请运行 `serial` 查看帮助。

## 项目结构

```
serial-tool/
├── bin/
│   └── serial              # 主脚本
├── config/
│   ├── devices.conf.example     # 设备配置示例
│   └── auto-rules.conf.example  # 规则配置示例
├── docs/                   # 文档目录
│   └── USAGE.md            # 完整使用说明
├── examples/
│   └── examples.md         # 使用示例
├── install.sh              # 安装脚本
├── uninstall.sh            # 卸载脚本
├── LICENSE                 # MIT 许可证
└── README.md               # 本文件
```

## 技术原理

### 为什么使用 by-path？

| 方式 | 稳定性 | 适用场景 |
|------|--------|----------|
| `/dev/ttyUSBx` | ❌ | 临时调试 |
| `/dev/serial/by-id/` | ⚠️ | FTDI（有序列号） |
| `/dev/serial/by-path/` | ✅ | CH341（无序列号）/板载设备 |

CH341/CH340 芯片常无真实序列号，多个设备 by-id 相同。by-path 基于 USB 物理端口位置，只要不换 USB 口就永远稳定。

## 依赖

- [tio](https://github.com/tio/tio) - 现代串口终端工具
- udev - Linux 设备管理

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

[Apache License 2.0](LICENSE)

## 作者

jiaqi

## 致谢

- [tio](https://github.com/tio/tio) - 优秀的串口工具
- Linux udev 文档

## 相关项目

- [tio](https://github.com/tio/tio)
- [picocom](https://github.com/npat-efault/picocom)
- [pyserial](https://github.com/pyserial/pyserial)
