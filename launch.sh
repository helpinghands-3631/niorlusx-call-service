#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 Starting Niorlusx Service..."

# Start your Flask or Node server
pm2 start server.js --name niorlusx

# Start ngrok (assumes PORT 3000)
ngrok http 3000 > /dev/null &

# Show public ngrok URL
sleep 3
curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url'

echo "✅ Niorlusx launched successfully."
