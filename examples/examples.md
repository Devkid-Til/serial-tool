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
# 后台记录启动日志
serial log S100-BOOT &

# 触发板子重启（通过继电器或手动）
# ...

# 实时查看日志
tail -f /tmp/serial-logs/S100-BOOT-*.log

# 分析关键信息
grep "U-Boot" /tmp/serial-logs/S100-BOOT-*.log
grep "Kernel panic" /tmp/serial-logs/S100-BOOT-*.log
```

## 示例 5：tmux 多窗口监控

```bash
#!/bin/bash
# monitor.sh - 同时监控多个串口

tmux new-session -d -s serial-monitor

# 窗口 1: UART 终端
tmux rename-window -t serial-monitor:0 'UART'
tmux send-keys -t serial-monitor:0 'serial connect S100-UART' C-m

# 窗口 2: 启动日志
tmux new-window -t serial-monitor:1 -n 'BOOT'
tmux send-keys -t serial-monitor:1 'serial connect S100-BOOT' C-m

# 窗口 3: 日志文件
tmux new-window -t serial-monitor:2 -n 'LOGS'
tmux send-keys -t serial-monitor:2 'tail -f /tmp/serial-logs/*.log' C-m

# 附加到会话
tmux attach -t serial-monitor
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
# 抓取特定关键字
serial log S100-BOOT /tmp/boot.log &
LOG_PID=$!

sleep 60  # 记录 60 秒

kill $LOG_PID

# 分析日志
grep -E "(U-Boot|Linux version|Kernel panic)" /tmp/boot.log

# 提取时间戳
awk '{print $1, $2}' /tmp/boot.log | head -20

# 统计错误
grep -c "ERROR" /tmp/boot.log
```

## 示例 8：与其他工具配合

```bash
# 使用 pyserial 发送命令，serial 记录日志
serial log S100-UART /tmp/uart.log &
LOG_PID=$!

# 用 Python 发送命令
python3 <<EOF
import serial
import time

ser = serial.Serial('/dev/serial/by-path/pci-0000:00:1d.0-usb-0:1:1.0-port0', 921600)
time.sleep(1)
ser.write(b'help\n')
time.sleep(2)
ser.close()
EOF

# 停止记录
kill $LOG_PID

# 查看结果
cat /tmp/uart.log
```
