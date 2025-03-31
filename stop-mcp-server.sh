#!/bin/bash

# Change to the project directory
cd "$(dirname "$0")"

# Try to read PID from file
if [ -f .mcp_server.pid ]; then
  PID=$(cat .mcp_server.pid)
  echo "Found MCP server PID: $PID"
  
  # Check if process is still running
  if ps -p $PID > /dev/null; then
    echo "Stopping Supabase MCP server (PID: $PID)..."
    kill $PID
    rm .mcp_server.pid
    echo "Server stopped."
  else
    echo "Process with PID $PID is not running."
    rm .mcp_server.pid
  fi
else
  # If no PID file, try to find and kill by process name
  echo "No PID file found. Trying to find process by name..."
  PID=$(pgrep -f "supabase-mcp-server")
  if [ -n "$PID" ]; then
    echo "Found Supabase MCP server process (PID: $PID)"
    echo "Stopping Supabase MCP server..."
    kill $PID
    echo "Server stopped."
  else
    echo "No running Supabase MCP server found."
  fi
fi 