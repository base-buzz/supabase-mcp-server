#!/bin/bash

# Change to the project directory
cd "$(dirname "$0")"

# Set environment variables from .env.local if it exists
if [ -f .env.local ]; then
  echo "Loading environment variables from .env.local"
  set -a
  source .env.local
  set +a
fi

# Update MCP configuration with environment variables
if [ -f ./update-mcp-config.sh ]; then
  echo "Updating MCP configuration..."
  ./update-mcp-config.sh
else
  echo "Warning: update-mcp-config.sh not found. MCP configuration may not be updated."
fi

# Check if Python 3.12 virtual environment exists, create if not
if [ ! -d "venv-py312" ]; then
  echo "Creating Python 3.12 virtual environment..."
  python3.12 -m venv venv-py312
  source venv-py312/bin/activate
  pip install --upgrade pip
  uv pip install .
else
  source venv-py312/bin/activate
fi

# Find the MCP server executable
MCP_SERVER_PATH=$(which supabase-mcp-server)
if [ -z "$MCP_SERVER_PATH" ]; then
  echo "supabase-mcp-server not found. Checking in virtual environment..."
  MCP_SERVER_PATH="$PWD/venv-py312/bin/supabase-mcp-server"
  if [ ! -f "$MCP_SERVER_PATH" ]; then
    echo "Error: supabase-mcp-server not found. Please install it first."
    exit 1
  fi
fi

# Create directory for local bin if it doesn't exist
mkdir -p ~/.local/bin

# Create a symlink to the server executable if it doesn't exist
SYMLINK_PATH="/Users/based/.local/bin/supabase-mcp-server"
if [ ! -L "$SYMLINK_PATH" ] || [ ! -e "$SYMLINK_PATH" ]; then
  echo "Creating symlink to server executable at $SYMLINK_PATH"
  ln -sf "$MCP_SERVER_PATH" "$SYMLINK_PATH"
  echo "Symlink created"
fi

# Ensure .env.local is copied to the global config directory
GLOBAL_CONFIG_DIR="$HOME/.config/supabase-mcp"
mkdir -p "$GLOBAL_CONFIG_DIR"
if [ -f .env.local ]; then
  echo "Copying .env.local to $GLOBAL_CONFIG_DIR/.env"
  cp .env.local "$GLOBAL_CONFIG_DIR/.env"
  echo "Environment configuration copied to global location"
fi

# Check if the server is already running
if pgrep -f "supabase-mcp-server" > /dev/null; then
  echo "Supabase MCP server is already running."
  echo "To stop it, run: pkill -f 'supabase-mcp-server'"
  exit 0
fi

# Start the server in the background
echo "Starting Supabase MCP server in the background..."
nohup "$MCP_SERVER_PATH" > mcp_server.log 2>&1 &

# Save the PID to a file
echo $! > .mcp_server.pid
echo "Supabase MCP server started with PID: $!"
echo "Logs are being written to: $PWD/mcp_server.log"
echo "To stop the server, run: ./stop-mcp-server.sh"
 