#!/data/data/com.termux/files/usr/bin/bash

# Load env vars
if [ ! -f .env ]; then
  echo "❌ .env file missing."
  exit 1
fi

export $(grep -v '^#' .env | xargs)

# Verify ngrok key
if [ -z "$NGROK_API_KEY" ]; then
  echo "❌ NGROK_API_KEY missing from .env"
  exit 1
fi

# Install Ngrok CLI if not available
if ! command -v ngrok >/dev/null 2>&1; then
  echo "❌ ngrok CLI not found. Make sure it's installed in your PATH."
  exit 1
fi

# Apply Ngrok authtoken
echo "🔐 Applying Ngrok auth token..."
ngrok config add-authtoken "$NGROK_API_KEY" && echo "✅ Ngrok authtoken saved."