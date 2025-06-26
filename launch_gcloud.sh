#!/bin/bash
# Niorlusx Auto Google Cloud Setup & Launch Script

echo "ðŸš€ Starting Niorlusx GCP deployment..."

# Install dependencies
sudo apt update && sudo apt install -y git python3-pip nodejs npm

# Clone the repository
if [ ! -d "niorlusx-call-service" ]; then
  git clone https://github.com/helpinghands-3631/niorlusx-call-service.git
fi

cd niorlusx-call-service

# Install Python requirements
pip3 install -r requirements.txt || pip install flask stripe python-dotenv openai

# Install Node.js dependencies
npm install -g pm2 pnpm
pnpm install || npm install

# Export environment variables
if [ -f ".env" ]; then
  export $(cat .env | xargs)
else
  echo "âš ï¸ .env file not found. Please create one with your API keys and config."
  exit 1
fi

# Start services using PM2
pm2 start app.py --interpreter python3 --name niorlusx-app
pm2 start voice-agent.js --name niorlusx-voice
pm2 start ngrok_wrapper.js --name niorlusx-ngrok

# Save PM2 process list
pm2 save

echo "âœ… Niorlusx is live on GCP instance. PM2 is managing all processes."
echo "Check logs with: pm2 logs"