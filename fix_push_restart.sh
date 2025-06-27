#!/data/data/com.termux/files/usr/bin/bash
# 🔧 Auto-fix Git + Restart Niorlusx + Start Ngrok

set -e

echo "🧹 Resolving Git conflict in ngrok_auth_setup.sh..."
FILE="ngrok_auth_setup.sh"
if grep -q "<<<<<<<" "$FILE"; then
  awk '/^<<<<<<< HEAD$/{f=1; next} /^=======$/{f=0; next} /^>>>>>>> /{f=0; next} !f' "$FILE" > "$FILE.tmp"
  mv "$FILE.tmp" "$FILE"
  echo "✅ Conflict removed."
else
  echo "✅ No conflict found in $FILE."
fi

git add "$FILE"
git rebase --continue || { echo "❌ Rebase failed. Fix manually."; exit 1; }

echo "🔐 Saving GitHub credentials..."
git config --global credential.helper store

echo "⬆️ Pushing to GitHub..."
git push origin main || { echo "❌ Push failed."; exit 1; }

echo "♻️ Restarting Niorlusx service via PM2..."
pm2 restart niorlusx || echo "⚠️ PM2 process not found, skipping restart."
pm2 save

echo "🌐 Starting new Ngrok tunnel..."
if ! command -v ngrok >/dev/null 2>&1; then
  echo "❌ ngrok not found in PATH."
  exit 1
fi

# Kill any existing tunnel with same name
pm2 delete niorlusx_tunnel 2>/dev/null || true

# Start new tunnel
pm2 start "ngrok http 3000" --name niorlusx_tunnel
pm2 save

sleep 2
NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url')

echo ""
echo "✅ Niorlusx is live!"
echo "🔗 Ngrok URL: $NGROK_URL"
echo "📞 Use this URL in Twilio or Stripe webhook config."
