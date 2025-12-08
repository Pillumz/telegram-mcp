# telegram-mcp Setup Instructions

## Overview
This is a Track A MCP server setup - keeping source code compatible with upstream, only adding standardized wrapper files.

## Current Status
✅ Source code copied from /root/projects/telegram-mcp
✅ Makefile created with MODULE=main, PORT=9085
✅ Systemd service file created (telegram-mcp.service)
✅ .env file configured with MCP_HOST=127.0.0.1 and MCP_PORT=9085
⏳ Git repository needs initialization
⏳ Dependencies need installation (uv sync)
⏳ Server startup needs testing

## Manual Steps Required

### 1. Initialize Git Repository
```fish
cd /opt/mcp/telegram-mcp
git init
git add .
git commit -m "Initial commit: Import telegram-mcp source code"
git checkout -b systemd-migration
```

### 2. Install Dependencies
```fish
cd /opt/mcp/telegram-mcp
uv sync
```

This will:
- Create a `.venv` directory with Python virtual environment
- Install all dependencies from `pyproject.toml` and `uv.lock`
- Make the project ready to run

### 3. Test Server Startup
```fish
cd /opt/mcp/telegram-mcp
uv run python main.py
```

Expected output:
```
Starting Telegram client...
Telegram client started. Running server on http://127.0.0.1:9085...
HTTP file endpoints (under /mcp/a32d6902afd081019743b7bdc72f5e811c9c14b5c9e39b63cc59fab4e5ce4ae4):
  - GET  /mcp/.../files/download?chat_id=...&message_id=...
  - POST /mcp/.../files/send?chat_id=...&filename=...&caption=...
```

Press Ctrl+C to stop the test.

### 4. Install and Start Systemd Service (When Ready)
```fish
cd /opt/mcp/telegram-mcp
make service-install
make service-start
make service-logs  # Watch logs
```

Or manually:
```fish
sudo cp telegram-mcp.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable telegram-mcp
sudo systemctl start telegram-mcp
journalctl -u telegram-mcp -f
```

## Configuration

### Port Configuration
- **Temporary port**: 9085 (during migration)
- **Final port**: 8085 (after migration complete)
- Configured in `.env` file as `MCP_PORT`

### Bind Address
- Configured to bind to `127.0.0.1` only (accessed via Caddy reverse proxy)
- Set in `.env` file as `MCP_HOST`

## File Structure
```
/opt/mcp/telegram-mcp/
├── .env                      # Environment variables (port, host, API keys)
├── .env.example             # Example environment file
├── .gitignore               # Git ignore patterns
├── main.py                  # Main MCP server implementation
├── Makefile                 # Build and service management commands
├── telegram-mcp.service     # Systemd service definition
├── pyproject.toml           # Python project configuration
├── uv.lock                  # Locked dependencies
├── requirements.txt         # Alternative requirements format
├── README.md                # Original project README
├── session_string_generator.py  # Utility for generating Telegram session strings
├── test_validation.py       # Validation tests
└── SETUP_INSTRUCTIONS.md    # This file
```

## How It Works

### Server Operation
1. Server reads configuration from `.env` file
2. Loads Telegram session (string or file-based)
3. Starts Telethon client
4. Creates FastMCP server with SSE transport
5. Adds custom HTTP file transfer endpoints
6. Runs uvicorn server on configured host:port

### No Command-Line Arguments
Unlike the template, this server doesn't accept `http --port PORT` arguments.
Configuration is entirely via environment variables in `.env`.

## Makefile Targets
- `make install` - Run uv sync to install dependencies
- `make run` - Run the server (uses .env port config)
- `make dev` - Same as run (for consistency)
- `make test` - Run pytest tests
- `make clean` - Remove .venv and cache directories
- `make service-install` - Install systemd service
- `make service-start` - Start systemd service
- `make service-stop` - Stop systemd service
- `make service-restart` - Restart systemd service
- `make service-logs` - View service logs

## Troubleshooting

### Database Lock Error
If you see "database is locked", ensure no other instance is running:
```fish
ps aux | grep main.py
# Kill any running instances
systemctl stop telegram-mcp
docker stop telegram-mcp  # If old Docker container exists
```

### Import Errors
If dependencies are missing:
```fish
cd /opt/mcp/telegram-mcp
rm -rf .venv
uv sync
```

### Session Errors
The .env file contains a TELEGRAM_SESSION_STRING. If authentication fails:
1. Check that TELEGRAM_API_ID and TELEGRAM_API_HASH are correct
2. Regenerate session string using `session_string_generator.py` if needed
3. Ensure only one of TELEGRAM_SESSION_STRING or TELEGRAM_SESSION_NAME is active

## Next Steps After Setup

1. Test that server starts and responds
2. Update Caddy configuration to proxy to new port 9085
3. Test through Caddy reverse proxy
4. When stable, change port from 9085 to 8085
5. Stop old Docker container
6. Update Caddy to proxy to port 8085
7. Commit changes to git
8. Create systemd-migration branch for tracking

## Migration Strategy

This is part of migrating from Docker to systemd:
- **Old setup**: Docker container on port 8080
- **New setup**: Systemd service on port 9085 (temp) → 8085 (final)
- **Track A**: Keep upstream source compatible, only add wrapper files
