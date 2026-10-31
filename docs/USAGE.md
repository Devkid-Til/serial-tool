# Serial - 串口设备管理工具

基于 tio 的串口设备管理脚本，提供设备别名映射、自动配置、日志记录等功能。

## 目录

- [功能特性](#功能特性)
- [安装](#安装)
- [快速开始](#快速开始)
- [命令参考](#命令参考)
  - [设备管理](#设备管理)
  - [规则管理](#规则管理)
  - [连接操作](#连接操作)
- [配置文件](#配置文件)
- [使用场景](#使用场景)
- [高级用法](#高级用法)
- [故障排查](#故障排查)

---

## 功能特性

- ✅ **设备别名管理**：为串口设备配置易记的别名（如 `S100-UART`）
- ✅ **稳定路径**：基于 `/dev/serial/by-path/` 的 USB 物理位置，不受插拔顺序影响
- ✅ **自动识别**：扫描并显示芯片型号、厂商、序列号等信息
- ✅ **规则模板**：预定义规则，新设备插入后自动应用配置
- ✅ **日志记录**：自动记录串口输出，带时间戳
- ✅ **交互/只读模式**：区分交互终端和日志记录设备
- ✅ **批量自动化**：一条命令完成多设备配置

---

## 安装

### 依赖

```bash
sudo apt install tio
```

### 脚本位置

```bash
~/.local/bin/serial
```

### 确保 PATH 包含 `~/.local/bin`

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 快速开始

### 1. 扫描并配置设备

```bash
# 交互式配置
serial detect

# 或使用规则自动配置
serial detect --auto
```

### 2. 连接设备

```bash
# 交互式终端（自动记录日志）
serial connect S100-UART

# 查看已记录的日志
serial logs show S100-BOOT
```

### 3. 查看设备

```bash
serial list
```

---

## 命令参考

### 设备管理

#### `serial list`

列出所有已配置的串口设备及其在线状态。

**输出示例**：
```
已配置的串口设备:
----------------------------------------
别名          波特率  用途       备注
----------------------------------------
S100-UART       921600     terminal     S100 主控 UART 终端 [✓]
S100-BOOT       921600     log-only     S100 启动日志 [✓]
----------------------------------------
[✓] 设备在线  [✗] 设备离线
```

---

#### `serial detect [--auto]`

扫描当前在线的 USB 串口设备。

**不带参数（交互模式）**：
```bash
serial detect
```
- 显示所有检测到的设备
- 询问是否为未配置的设备创建别名
- 交互式输入别名、波特率、用途、备注

**带 `--auto` 参数（自动模式）**：
```bash
serial detect --auto
```
- 扫描设备
- 自动匹配规则文件中的配置
- 批量应用，无需人工干预

**输出示例**：
```
检测到 2 个 USB 串口设备:

[1] ttyUSB0
    by-path: pci-0000:00:1d.0-usb-0:1:1.0-port0
    芯片: CH341
    厂商: 1a86
    型号: USB_Serial
    状态: 已配置为 S100-UART

[2] ttyUSB1
    by-path: pci-0000:00:1d.0-usb-0:2.1:1.0-port0
    芯片: CH341
    厂商: 1a86
    型号: USB_Serial
    状态: 未配置（匹配规则: S100-BOOT）
```

---

#### `serial show <别名>`

显示指定设备的详细信息。

```bash
serial show S100-UART
```

**输出示例**：
```
设备详情:
  别名:     S100-UART
  by-path:  pci-0000:00:1d.0-usb-0:1:1.0-port0
  波特率:   921600
  用途:     terminal
  备注:     S100 主控 UART 终端
  状态:     在线 (/dev/ttyUSB0)
```

---

#### 手动添加设备（编辑配置文件）

设备配置保存在 `~/.config/serial/devices.conf`，格式简单，可直接编辑：

```bash
# 格式: 别名|by-path路径|波特率|用途|备注
echo "S100-UART|pci-0000:00:1d.0-usb-0:1:1.0-port0|921600|terminal|S100 主控 UART 终端" >> ~/.config/serial/devices.conf
```

by-path 路径可通过 `serial detect` 或 `ls /dev/serial/by-path/` 查看。

**适用场景**：CI/CD 自动化、批量部署、版本控制配置。

---

#### `serial update <别名> <字段> <新值>`

更新设备配置。

**可更新字段**：
- `path`：by-path 路径
- `baud`：波特率
- `usage`：用途
- `desc`：备注

**示例**：
```bash
serial update S100-UART baud 115200
serial update S100-UART desc "更新后的描述"
```

---

#### `serial remove <别名>`

删除设备配置。

```bash
serial remove S100-UART
```

---

### 规则管理

规则用于自动匹配新插入的设备，无需手动配置。

#### `serial rules`

查看所有自动命名规则。

**输出示例**：
```
自动命名规则:
----------------------------------------
by-path 模式                           别名          波特率  用途       备注
----------------------------------------
pci-0000:00:1d.0-usb-0:1:*               S100-UART       921600     terminal     S100 主控 UART 终端
pci-0000:00:1d.0-usb-0:2.1:*             S100-BOOT       921600     log-only     S100 启动日志
----------------------------------------
```

---

#### `serial rule-add <by-path模式> <别名> [波特率] [用途] [备注]`

添加自动命名规则。

**参数**：
- `by-path模式`：支持通配符 `*`（如 `pci-*-usb-0:1:*`）
- `别名`：设备的易记名称
- `波特率`：默认 115200
- `用途`：`terminal`（交互式）或 `log-only`（只读日志）
- `备注`：设备描述信息

**示例**：
```bash
# 精确匹配
serial rule-add "pci-0000:00:1d.0-usb-0:1:1.0-port0" S100-UART 921600 terminal "S100 UART"

# 通配符匹配（匹配所有插在 USB 端口 1 的设备）
serial rule-add "pci-*-usb-0:1:*" BOARD-UART 921600 terminal "开发板 UART"
```

---

#### `serial rule-remove <by-path模式>`

删除规则。

```bash
serial rule-remove "pci-0000:00:1d.0-usb-0:1:*"
```

---

### 连接操作

#### `serial connect <别名> [波特率]`

连接设备进行交互式操作。

**功能**：
- 自动启用日志记录（保存到 `/tmp/serial-logs/`）
- 日志文件名：`{别名}-{日期时间}.log`
- 自动去除 ANSI 颜色码
- 每行添加时间戳

**示例**：
```bash
serial connect S100-UART           # 使用配置的波特率
serial connect S100-UART 115200    # 临时覆盖波特率
```

**退出**：按 `Ctrl-T Q`

---

#### `serial logs` - 日志管理

`connect` 会自动记录日志到 `/tmp/serial-logs/`，用 `logs` 命令组管理：

```bash
serial logs list              # 列出所有日志文件
serial logs show S100-BOOT    # 查看该设备最新日志（less）
serial logs follow            # 实时监控所有日志（tail -f）
serial logs clean 7           # 清理 7 天前的日志
```

---

#### `serial raw <设备路径> [波特率]`

直接连接原始设备（不查配置）。

**适用场景**：
- 临时连接未配置的设备
- 测试其他串口工具
- 调试配置问题

**示例**：
```bash
serial raw /dev/ttyUSB0 115200
serial raw /dev/serial/by-id/usb-FTDI_FT232R_USB_UART_A1234567-if00-port0 1500000
```

---

## 配置文件

### 设备配置文件

**路径**：`~/.config/serial/devices.conf`

**格式**：
```
别名|by-path路径|波特率|用途|备注
```

**示例**：
```
S100-UART|pci-0000:00:1d.0-usb-0:1:1.0-port0|921600|terminal|S100 主控 UART 终端
S100-BOOT|pci-0000:00:1d.0-usb-0:2.1:1.0-port0|921600|log-only|S100 启动日志
```

---

### 规则配置文件

**路径**：`~/.config/serial/auto-rules.conf`

**格式**：
```
by-path模式|别名|波特率|用途|备注
```

**示例**：
```
# S100 开发板
pci-0000:00:1d.0-usb-0:1:*|S100-UART|921600|terminal|S100 主控 UART
pci-0000:00:1d.0-usb-0:2.1:*|S100-BOOT|921600|log-only|S100 启动日志

# S200 开发板（通配符匹配）
pci-*-usb-0:3:*|S200-UART|1500000|terminal|S200 UART
```

---

### 日志目录

**默认路径**：`/tmp/serial-logs/`

**日志文件命名规则**：
- 自动命名：`{别名}-YYYYMMDD-HHMMSS.log`
- 原始设备：`raw-{设备名}-YYYYMMDD-HHMMSS.log`

---

## 使用场景

### 场景 1：日常开发调试

```bash
# 连接开发板 UART 终端
serial connect S100-UART

# 板子重启后自动重连（tio 特性）
# 日志自动保存到 /tmp/serial-logs/
```

---

### 场景 2：抓取启动日志

```bash
# 连接 BOOT 串口（自动记录日志）
serial connect S100-BOOT

# 或者在另一个终端实时查看日志
serial logs follow

# 事后查看历史日志
serial logs show S100-BOOT
```

---

### 场景 3：换新板子

```bash
# 1. 插入新板子，运行检测
serial detect

# 2. 查看新设备的 by-path
# 输出示例：pci-0000:00:1d.0-usb-0:3:1.0-port0

# 3. 更新规则
serial rule-add "pci-0000:00:1d.0-usb-0:3:*" S200-UART 1500000 terminal "S200 UART"

# 4. 自动配置
serial detect --auto

# 5. 连接使用
serial connect S200-UART
```

---

### 场景 4：批量管理多个板子

```bash
# 一次性配置所有规则
serial rule-add "pci-*-usb-0:1:*" BOARD1-UART 921600 terminal "板子1 UART"
serial rule-add "pci-*-usb-0:2:*" BOARD2-UART 921600 terminal "板子2 UART"
serial rule-add "pci-*-usb-0:3:*" BOARD3-UART 1500000 terminal "板子3 UART"

# 插入所有板子后，一条命令完成配置
serial detect --auto

# 查看所有设备
serial list
```

---

### 场景 5：临时调试未配置的设备

```bash
# 查找设备路径
ls -l /dev/serial/by-path/

# 直接连接（不保存配置）
serial raw /dev/serial/by-path/pci-0000:00:1d.0-usb-0:5:1.0-port0 115200
```

---

## 高级用法

### 自定义日志目录

修改脚本中的 `DEFAULT_LOG_DIR` 变量：

```bash
# ~/.local/bin/serial
DEFAULT_LOG_DIR="$HOME/logs/serial"
```

---

### 配合 CI/CD 使用

```bash
#!/bin/bash
# CI 脚本：自动抓取板子启动日志

# 配置设备（直接写配置文件）
echo "CI-BOARD|pci-0000:00:1d.0-usb-0:1:1.0-port0|921600|terminal|CI 测试板" >> ~/.config/serial/devices.conf

# 记录日志（前台运行，配合 timeout）
timeout 60 serial connect CI-BOARD

# 触发板子重启（通过其他工具）
# reboot-board.sh

# 分析日志
grep "Kernel panic" /tmp/serial-logs/CI-BOARD-*.log && exit 1
echo "Boot successful"
```

---

### 与 tmux 配合

```bash
# tmux 会话中同时查看多个串口
tmux new-session -d -s serial
tmux split-window -h
tmux select-pane -t 0
tmux send-keys "serial connect S100-UART" C-m
tmux select-pane -t 1
tmux send-keys "serial connect S100-BOOT" C-m
tmux attach -t serial
```

---

## 故障排查

### 问题 1：设备离线（状态显示 ✗）

**原因**：
- USB 线未连接
- 设备被拔出
- by-path 路径已变化（换了 USB 口）

**解决**：
```bash
# 重新扫描设备
serial detect

# 更新设备路径
serial update S100-UART path pci-0000:00:1d.0-usb-0:3:1.0-port0
```

---

### 问题 2：权限不足

**错误信息**：
```
Error: Could not open /dev/ttyUSB0 (Permission denied)
```

**解决**：
```bash
# 将用户添加到 dialout 组
sudo usermod -aG dialout $USER

# 重新登录或执行
newgrp dialout
```

---

### 问题 3：日志文件为空

**原因**：
- 设备未输出数据
- 波特率不匹配
- 日志目录权限问题

**解决**：
```bash
# 检查设备是否在线
serial show S100-UART

# 尝试不同波特率
serial connect S100-UART 115200

# 检查日志目录
ls -ld /tmp/serial-logs/
```

---

### 问题 4：detect 找不到设备

**原因**：
- 设备未识别为 USB 串口
- 驱动未加载

**解决**：
```bash
# 查看所有 ttyUSB 设备
ls -l /dev/ttyUSB*

# 查看 udev 信息
udevadm info -n /dev/ttyUSB0

# 检查驱动
dmesg | grep -i "usb.*serial"
```

---

### 问题 5：规则不生效

**原因**：
- 规则模式不匹配
- 配置文件格式错误

**解决**：
```bash
# 查看规则文件
cat ~/.config/serial/auto-rules.conf

# 手动测试模式匹配
path="pci-0000:00:1d.0-usb-0:1:1.0-port0"
pattern="pci-*-usb-0:1:*"
[[ "$path" == $pattern ]] && echo "匹配" || echo "不匹配"

# 重新添加规则
serial rule-remove "旧模式"
serial rule-add "新模式" ...
```

---

## 技术原理

### by-path vs by-id vs ttyUSBx

| 方式 | 稳定性 | 说明 |
|------|--------|------|
| `/dev/ttyUSB0` | ❌ 不稳定 | 按枚举顺序分配，插拔顺序变化会导致编号漂移 |
| `/dev/serial/by-id/` | ⚠️ 部分稳定 | 基于 VID/PID/序列号，但 CH341 序列号可能相同 |
| `/dev/serial/by-path/` | ✅ 稳定 | 基于 USB 物理位置（端口号），不换口就不变 |

**本工具使用 by-path**，原因：
1. CH341/CH340 芯片常无序列号，by-id 无法区分
2. 板载 USB 转串口的 USB 口固定，by-path 永久稳定
3. 换板子时只需更新规则文件

---

## 相关工具

- **tio**：底层串口工具（本脚本基于此）
- **picocom**：另一款串口工具（功能类似）
- **minicom**：经典串口工具（较老）
- **pyserial**：Python 串口库（适合脚本自动化）

---

## 许可证

MIT License

## 作者

jiaqi

## 版本历史

- **v1.0** (2026-10-31): 初始版本，支持设备管理、规则自动化、日志记录
