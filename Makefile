.PHONY: install uninstall test clean help

help:
	@echo "Serial Tool - Makefile"
	@echo ""
	@echo "可用命令:"
	@echo "  make install    - 安装 serial 到 ~/.local/bin"
	@echo "  make uninstall  - 卸载 serial"
	@echo "  make test       - 运行测试"
	@echo "  make clean      - 清理临时文件"
	@echo "  make help       - 显示此帮助"

install:
	@./install.sh

uninstall:
	@./uninstall.sh

test:
	@echo "运行测试..."
	@bash -n bin/serial && echo "✓ 语法检查通过"
	@command -v shellcheck >/dev/null 2>&1 && shellcheck bin/serial || echo "提示: 安装 shellcheck 可进行更详细的检查"

clean:
	@echo "清理临时文件..."
	@find . -name "*.tmp" -delete
	@find . -name "*.bak" -delete
	@find . -name "*~" -delete
	@echo "✓ 清理完成"
