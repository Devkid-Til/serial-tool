# Serial Tool 使用示例

## 示例 1：新设备快速配置

```bash
# 1. 插入新的 USB 串口设备
# 2. 扫描检测
serial detect

# 输出示例：
# [1] ttyUSB0
#     by-path: pci-0000:00:1d.0-usb-0:1:1.0-port0
#     芯片: CH341
#     状态: 未配置

# 3. 交互式配置
# 按提示输入：别名、波特率、用途、备注
```

## 示例 2：自动化配置（CI/CD）

```bash
#!/bin/bash
# CI 环境自动配置串口

# 添加规则
serial rule-add "pci-*-usb-0:1:*" CI-BOARD 921600 terminal "CI 测试板"

# 插入设备后自动配置
serial detect --auto

# 验证配置
serial show CI-BOARD
```

## 示例 3：批量管理多个开发板

```bash
# 配置规则文件
cat > ~/.config/serial/auto-rules.conf <<EOF
pci-*-usb-0:1:*|RK3588-UART|1500000|terminal|RK3588 开发板
pci-*-usb-0:2:*|STM32-UART|115200|terminal|STM32 开发板
pci-*-usb-0:3:*|S100-UART|921600|terminal|S100 开发板
pci-*-usb-0:4:*|S100-BOOT|921600|log-only|S100 启动日志
EOF

# 插入所有板子，一条命令配置完成
serial detect --auto

# 查看所有设备
serial list
```

## 示例 4：抓取启动日志

```bash
# 终端 1：连接 BOOT 串口（自动记录日志）
serial connect S100-BOOT

# 终端 2：实时查看日志
serial logs follow

# 事后分析关键信息
grep "U-Boot" /tmp/serial-logs/S100-BOOT-*.log
grep "Kernel panic" /tmp/serial-logs/S100-BOOT-*.log
```

## 示例 5：tmux 多窗口监控（推荐）

### 方式1：使用内置 monitor 命令（推荐）

```bash
# 监控单个板子的所有串口
serial monitor S100
# 自动分屏显示 S100-UART 和 S100-BOOT

# 监控所有已配置的设备
serial monitor
# 自动网格布局显示所有设备
```

**效果**：
```
┌──────────────────┬──────────────────┐
│  S100-UART       │  S100-BOOT       │
│  (交互终端)       │  (启动日志)       │
│                  │                  │
│  root@board:~#   │  U-Boot 2023...  │
│                  │  Starting kern.. │
└──────────────────┴──────────────────┘
```

**tmux 快捷键**：
- `Ctrl+B` → 方向键：切换窗格
- `Ctrl+B` → `z`：当前窗格全屏/恢复
- `Ctrl+B` → `d`：分离会话（后台运行）
- `Ctrl+B` → `[`：滚动查看历史（`q` 退出）

**管理会话**：
```bash
tmux attach -t serial-S100      # 重新附加
tmux kill-session -t serial-S100 # 关闭会话
tmux ls                          # 列出所有会话
```

### 方式2：手动 tmux 脚本（自定义布局）

```bash
#!/bin/bash
# custom-monitor.sh - 自定义多窗口布局

tmux new-session -d -s my-monitor

# 窗口 1: UART 终端
tmux rename-window -t my-monitor:0 'UART'
tmux send-keys -t my-monitor:0 'serial connect S100-UART' C-m

# 窗口 2: 启动日志
tmux new-window -t my-monitor:1 -n 'BOOT'
tmux send-keys -t my-monitor:1 'serial connect S100-BOOT' C-m

# 窗口 3: 日志文件
tmux new-window -t my-monitor:2 -n 'LOGS'
tmux send-keys -t my-monitor:2 'tail -f /tmp/serial-logs/*.log' C-m

# 附加到会话
tmux attach -t my-monitor
```

## 示例 6：临时调试未配置的设备

```bash
# 查找设备路径
ls -l /dev/serial/by-path/

# 直接连接（不保存配置）
serial raw /dev/serial/by-path/pci-0000:00:1d.0-usb-0:5:1.0-port0 115200

# 或者直接用 ttyUSBx
serial raw /dev/ttyUSB2 9600
```

## 示例 7：日志分析和处理

```bash
# 记录 60 秒日志（timeout 自动停止）
timeout 60 serial connect S100-BOOT

# 找到刚才的日志文件
LOG=$(ls -t /tmp/serial-logs/S100-BOOT-*.log | head -1)

# 分析日志
grep -E "(U-Boot|Linux version|Kernel panic)" "$LOG"

# 提取时间戳
awk '{print $1, $2}' "$LOG" | head -20

# 统计错误
grep -c "ERROR" "$LOG"
```

## 示例 8：与其他工具配合

```bash
# 终端 1：连接串口（自动记录日志）
serial connect S100-UART

# 终端 2：用 Python 发送命令
python3 <<EOF
import serial
import time

ser = serial.Serial('/dev/serial/by-path/pci-0000:00:1d.0-usb-0:1:1.0-port0', 921600)
time.sleep(1)
ser.write(b'help\n')
time.sleep(2)
ser.close()
EOF

# 终端 1 按 Ctrl-T Q 退出后，查看日志
serial logs show S100-UART
```
