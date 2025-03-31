#!/bin/bash

# Change to the project directory
cd "$(dirname "$0")"

echo "Updating MCP configuration with values from .env.local..."

# Check if .env.local exists
if [ ! -f .env.local ]; then
  echo "Error: .env.local file not found!"
  exit 1
fi

# Load environment variables from .env.local
set -a
source .env.local
set +a

# Get project reference from DB_USER if not explicitly set
if [ -z "$SUPABASE_PROJECT_REF" ] && [ -n "$SUPABASE_DB_USER" ]; then
  # Extract project reference from DB_USER (format: postgres.projectref)
  SUPABASE_PROJECT_REF=$(echo $SUPABASE_DB_USER | cut -d'.' -f2)
  echo "Extracted project reference: $SUPABASE_PROJECT_REF"
fi

# Get region from DB_HOST if not explicitly set
if [ -z "$SUPABASE_REGION" ] && [ -n "$SUPABASE_DB_HOST" ]; then
  # Extract region from DB_HOST (format: aws-0-region.pooler.supabase.com)
  SUPABASE_REGION=$(echo $SUPABASE_DB_HOST | cut -d'-' -f3 | cut -d'.' -f1)
  echo "Extracted region: $SUPABASE_REGION"
fi

# Path to the MCP configuration file
MCP_CONFIG_PATH="$HOME/.cursor/mcp.json"

# Create a temporary file with the variables substituted
if [ -f "$MCP_CONFIG_PATH" ]; then
  echo "Updating $MCP_CONFIG_PATH with environment variables..."
  
  # Create a temporary file
  TMP_FILE=$(mktemp)
  
  # Replace placeholders with actual values using envsubst
  # We use cat + envsubst instead of direct file modification to handle the substitution
  cat "$MCP_CONFIG_PATH" | 
  sed "s/\${SUPABASE_PROJECT_REF}/$SUPABASE_PROJECT_REF/g" |
  sed "s/\${SUPABASE_DB_PASSWORD}/$SUPABASE_DB_PASSWORD/g" |
  sed "s/\${SUPABASE_REGION}/$SUPABASE_REGION/g" |
  sed "s/\${SUPABASE_ACCESS_TOKEN}/${SUPABASE_ACCESS_TOKEN:-''}/g" |
  sed "s/\${SUPABASE_SERVICE_ROLE_KEY}/${SUPABASE_SERVICE_ROLE_KEY:-''}/g" > "$TMP_FILE"
  
  # Replace the original file with the modified one
  mv "$TMP_FILE" "$MCP_CONFIG_PATH"
  
  echo "MCP configuration updated successfully!"
else
  echo "Error: MCP configuration file not found at $MCP_CONFIG_PATH"
  exit 1
fi 