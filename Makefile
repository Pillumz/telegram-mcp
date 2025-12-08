.PHONY: install run dev test clean service-install service-start service-stop service-restart service-logs

# Package name (override in each project)
MODULE := main
PORT := 9085

install:
	uv sync

run:
	uv run python $(MODULE).py

dev:
	uv run python $(MODULE).py

stdio:
	@echo "STDIO mode not supported - this server runs in HTTP mode only"

test:
	uv run pytest

clean:
	rm -rf .venv __pycache__ .pytest_cache .ruff_cache

# Systemd service management
service-install:
	sudo cp telegram-mcp.service /etc/systemd/system/
	sudo systemctl daemon-reload
	sudo systemctl enable telegram-mcp

service-start:
	sudo systemctl start telegram-mcp

service-stop:
	sudo systemctl stop telegram-mcp

service-restart:
	sudo systemctl restart telegram-mcp

service-logs:
	journalctl -u telegram-mcp -f
