#!/data/data/com.termux/files/usr/bin/bash

# ✅ Load env vars
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "❌ .env file not found."
  exit 1
fi

echo "🚀 Starting Niorlusx Flask server..."
pm2 start app.py --interpreter python3 --name niorlusx

# 🌐 Start Ngrok tunnel on port 3000
echo "🔗 Launching Ngrok tunnel..."
pm2 start "ngrok http 3000" --name niorlusx_ngrok

sleep 5

# 🧠 Get public Ngrok URL
NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[0].public_url')

if [[ "$NGROK_URL" == http* ]]; then
  echo "✅ Ngrok is running at: $NGROK_URL"
else
  echo "❌ Failed to get Ngrok URL. Is Ngrok running?"
  exit 1
fi

# 📞 Update Twilio webhook with new Ngrok URL
if [[ -n "$TWILIO_ACCOUNT_SID" && -n "$TWILIO_AUTH_TOKEN" && -n "$TWILIO_PHONE_NUMBER" ]]; then
  echo "📡 Updating Twilio voice webhook..."
  curl -X POST https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/IncomingPhoneNumbers.json \
    --data-urlencode "PhoneNumber=$TWILIO_PHONE_NUMBER" \
    --data-urlencode "VoiceUrl=$NGROK_URL/twilio/webhook" \
    -u "$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN"

  echo "✅ Twilio webhook updated to $NGROK_URL/twilio/webhook"
else
  echo "⚠️ Skipping Twilio webhook update (missing credentials)."
fi

pm2 save
echo "🎉 Niorlusx system running!"


---