#!/bin/bash

# Change to the project directory
cd "$(dirname "$0")"

# Print header
echo "===== Supabase MCP Server Status ====="

# Check for PID file
if [ -f .mcp_server.pid ]; then
  PID=$(cat .mcp_server.pid)
  echo "PID file exists with PID: $PID"
  
  # Check if process with this PID is running
  if ps -p $PID > /dev/null; then
    echo "✅ Server is RUNNING (PID: $PID)"
    
    # Show process details
    echo
    echo "Process details:"
    ps -p $PID -o pid,ppid,user,%cpu,%mem,start,time,command
    
    # Show recent logs
    echo
    echo "Recent logs (last 5 lines):"
    if [ -f mcp_server.log ]; then
      tail -n 5 mcp_server.log
    else
      echo "No log file found."
    fi
  else
    echo "❌ Server is NOT running (stale PID file)"
    echo "Run ./start-mcp-server.sh to start the server"
  fi
else
  # No PID file, check if process is running by name
  PID=$(pgrep -f "supabase-mcp-server")
  if [ -n "$PID" ]; then
    echo "✅ Server is RUNNING (PID: $PID)"
    echo "Note: No PID file found, but process was detected"
    
    # Show process details
    echo
    echo "Process details:"
    ps -p $PID -o pid,ppid,user,%cpu,%mem,start,time,command
  else
    echo "❌ Server is NOT running"
    echo "Run ./start-mcp-server.sh to start the server"
  fi
fi

# Show Cursor MCP config status
echo
echo "Cursor MCP configuration:"
if [ -f /Users/based/.cursor/mcp.json ]; then
  echo "MCP config file exists at: /Users/based/.cursor/mcp.json"
  echo
  echo "Server command path:"
  grep -A 1 "\"command\":" /Users/based/.cursor/mcp.json
else
  echo "MCP config file not found"
fi

echo
echo "===== Commands ====="
echo "Start server: ./start-mcp-server.sh"
echo "Stop server:  ./stop-mcp-server.sh"
echo "Show status:  ./show-mcp.sh" 