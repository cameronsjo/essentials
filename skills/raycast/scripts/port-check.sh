#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Check Port
# @raycast.mode fullOutput
# @raycast.packageName Development
# @raycast.icon 🔌
# @raycast.description Check what process is using a port
# @raycast.argument1 { "type": "text", "placeholder": "Port number" }

PORT="$1"

if [[ -z "$PORT" ]]; then
  echo "❌ Please provide a port number"
  exit 1
fi

echo "🔍 Checking port $PORT..."
echo ""

RESULT=$(lsof -i :"$PORT" 2>/dev/null)

if [[ -z "$RESULT" ]]; then
  echo "✅ Port $PORT is available"
else
  echo "$RESULT"
fi
