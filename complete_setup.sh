#!/bin/bash
echo "🚀 AI Call Service - Complete Setup"
echo "=================================="

# Create project structure
mkdir -p ai-call-demo/{backend,frontend}
cd ai-call-demo

echo "📁 Setting up backend..."
cd backend

# Backend files (Flask API)
cat > app.py << 'PYEOF'
from flask import Flask, request, jsonify
from flask_cors import CORS
import json, sqlite3, os
from datetime import datetime

app = Flask(__name__)
CORS(app)

def init_db():
    conn = sqlite3.connect('ai_call_service.db')
    cursor = conn.cursor()
    cursor.execute('''CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT UNIQUE NOT NULL,
        name TEXT, preferences TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)''')
    cursor.execute('''CREATE TABLE IF NOT EXISTS calls (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER, conversation TEXT, duration INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id))''')
    conn.commit()
    conn.close()

init_db()

@app.route('/')
def home():
    return jsonify({'message': 'AI Call Service API', 'version': '1.0', 'status': 'running'})

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    user_message = data.get('message', '')
    ai_reply = f"AI Response: I heard you say '{user_message}'. This is a demo response!"
    return jsonify({'reply': ai_reply, 'timestamp': datetime.now().isoformat()})

@app.route('/call/start', methods=['POST'])
def start_call():
    return jsonify({'message': 'Call started', 'timestamp': datetime.now().isoformat()})

@app.route('/call/end', methods=['POST'])
def end_call():
    return jsonify({'message': 'Call ended', 'timestamp': datetime.now().isoformat()})

if __name__ == '__main__':
    print("🔥 AI Call Service API Running on http://localhost:8000")
    app.run(host='0.0.0.0', port=8000, debug=True)
PYEOF

cd ../frontend

# Frontend files (PWA)
cat > index.html << 'HTMLEOF'
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>🔥 AI Call Service</title><link rel="manifest" href="manifest.json">
<style>*{margin:0;padding:0;box-sizing:border-box}body{font-family:system-ui;background:linear-gradient(135deg,#667eea,#764ba2);min-height:100vh;color:#333}.container{max-width:400px;margin:0 auto;padding:20px}.header{text-align:center;color:white;margin-bottom:30px}.header h1{font-size:2.5em;margin-bottom:10px}.call-interface{background:white;padding:25px;border-radius:15px;margin-bottom:20px;text-align:center}.status{font-size:1.2em;margin-bottom:20px;padding:10px;border-radius:8px;background:#f8f9fa}.btn{padding:12px 20px;border:none;border-radius:25px;font-size:16px;cursor:pointer;margin:5px}.btn-primary{background:#28a745;color:white}.btn-secondary{background:#dc3545;color:white}.conversation{background:white;border-radius:15px;padding:20px;margin-bottom:20px;max-height:300px;overflow-y:auto}.message{margin-bottom:15px;padding:12px;border-radius:18px}.message.user{background:#6366f1;color:white;text-align:right}.message.ai{background:#f1f3f4;color:#333}.input-area{display:flex;gap:10px;background:white;padding:15px;border-radius:15px}.input-area input{flex:1;padding:12px;border:2px solid #e1e5e9;border-radius:25px}.input-area button{padding:12px 20px;background:#6366f1;color:white;border:none;border-radius:25px}</style>
</head><body><div class="container"><div class="header"><h1>🔥 AI Call Service</h1><p>Premium AI conversations</p></div>
<div class="call-interface"><div class="status" id="status">Ready to start</div>
<button id="startCall" class="btn btn-primary">📞 Start Call</button>
<button id="endCall" class="btn btn-secondary" disabled>📴 End Call</button>
<button id="startVoice" class="btn btn-primary" disabled>🎤 Voice</button></div>
<div class="conversation" id="conversation"><div style="text-align:center;color:#666;padding:20px">Welcome! Start a call to begin.</div></div>
<div class="input-area"><input type="text" id="messageInput" placeholder="Type message..." disabled>
<button id="sendBtn" disabled>Send</button></div></div>
<script>
class AICallApp{constructor(){this.isCallActive=false;this.apiUrl='http://localhost:8000';this.init()}
init(){this.startCallBtn=document.getElementById('startCall');this.endCallBtn=document.getElementById('endCall');this.startVoiceBtn=document.getElementById('startVoice');this.statusDiv=document.getElementById('status');this.conversationDiv=document.getElementById('conversation');this.messageInput=document.getElementById('messageInput');this.sendBtn=document.getElementById('sendBtn');this.bindEvents()}
bindEvents(){this.startCallBtn.onclick=()=>this.startCall();this.endCallBtn.onclick=()=>this.endCall();this.startVoiceBtn.onclick=()=>this.startVoice();this.sendBtn.onclick=()=>this.sendMessage();this.messageInput.onkeypress=(e)=>{if(e.key==='Enter')this.sendMessage()}}
startCall(){this.isCallActive=true;this.startCallBtn.disabled=true;this.endCallBtn.disabled=false;this.startVoiceBtn.disabled=false;this.messageInput.disabled=false;this.sendBtn.disabled=false;this.statusDiv.textContent='Call Active';this.conversationDiv.innerHTML='';this.addMessage('Call started! You can now chat.','ai');fetch(this.apiUrl+'/call/start',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({phone_number:'+1234567890'})})}
endCall(){this.isCallActive=false;this.startCallBtn.disabled=false;this.endCallBtn.disabled=true;this.startVoiceBtn.disabled=true;this.messageInput.disabled=true;this.sendBtn.disabled=true;this.statusDiv.textContent='Call Ended';this.addMessage('Call ended. Thank you!','ai');fetch(this.apiUrl+'/call/end',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({phone_number:'+1234567890'})})}
startVoice(){if('webkitSpeechRecognition'in window){const recognition=new webkitSpeechRecognition();recognition.onresult=(event)=>{const transcript=event.results[0][0].transcript;this.addMessage(transcript,'user');this.sendToAI(transcript)};recognition.start()}else{alert('Voice recognition not supported')}}
sendMessage(){const message=this.messageInput.value.trim();if(!message||!this.isCallActive)return;this.addMessage(message,'user');this.messageInput.value='';this.sendToAI(message)}
async sendToAI(message){try{const response=await fetch(this.apiUrl+'/chat',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({message:message,phone_number:'+1234567890'})});const data=await response.json();this.addMessage(data.reply,'ai');if('speechSynthesis'in window){const utterance=new SpeechSynthesisUtterance(data.reply);speechSynthesis.speak(utterance)}}catch(error){this.addMessage('Error connecting to AI','ai')}}
addMessage(text,sender){const messageDiv=document.createElement('div');messageDiv.className=`message ${sender}`;messageDiv.textContent=text;this.conversationDiv.appendChild(messageDiv);this.conversationDiv.scrollTop=this.conversationDiv.scrollHeight}}
new AICallApp();
</script></body></html>
HTMLEOF

cat > manifest.json << 'MANEOF'
{"name":"AI Call Service","short_name":"AI Call","start_url":"/","display":"standalone","background_color":"#667eea","theme_color":"#6366f1","icons":[{"src":"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTkyIiBoZWlnaHQ9IjE5MiIgZmlsbD0iIzYzNjZmMSI+PHJlY3Qgd2lkdGg9IjE5MiIgaGVpZ2h0PSIxOTIiIHJ4PSIyNCIvPjx0ZXh0IHg9Ijk2IiB5PSIxMTAiIGZvbnQtc2l6ZT0iNjAiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGZpbGw9IndoaXRlIj7wn5SLPC90ZXh0Pjwvc3ZnPg==","sizes":"192x192","type":"image/svg+xml"}]}
MANEOF

cat > server.py << 'SERVEOF'
import http.server, socketserver
PORT = 3000
class Handler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()
print(f"🌐 Frontend server: http://localhost:{PORT}")
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    httpd.serve_forever()
SERVEOF

cd ..

# Create run scripts
cat > start_backend.sh << 'STARTEOF'
#!/bin/bash
echo "🔥 Starting AI Call Service Backend..."
cd backend
python app.py
STARTEOF

cat > start_frontend.sh << 'FRONTEOF'
#!/bin/bash
echo "🌐 Starting AI Call Service Frontend..."
cd frontend
python server.py
FRONTEOF

chmod +x start_backend.sh start_frontend.sh

echo "✅ Setup Complete!"
echo "📁 Project created in: ai-call-demo/"
echo ""
echo "🚀 To run the demo:"
echo "1. Terminal 1: ./start_backend.sh"
echo "2. Terminal 2: ./start_frontend.sh"
echo "3. Open browser: http://localhost:3000"
echo ""
echo "📱 Features:"
echo "- Voice recognition #!/bin/bash

# Advanced Termux Setup Script for AI Call Center Backend
# This script automates the setup of a robust environment within Termux
# using proot-distro (Ubuntu) to host the Flask application with Gunicorn and Nginx.

# --- Configuration Variables ---
REPO_URL="https://github.com/helpinghands-3631/call-center-ai"
REPO_DIR="/opt/call-center-ai"
FLASK_APP_DIR="${REPO_DIR}/app"
FLASK_APP_MODULE="app:app" # Assuming your Flask app instance is named 'app' in 'app.py'

# --- Step 1: Update Termux and Install proot-distro ---
echo "[STEP 1/7] Updating Termux and installing proot-distro..."
pkg update -y && pkg upgrade -y
pkg install -y proot-distro

# --- Step 2: Install Ubuntu proot-distro ---
echo "[STEP 2/7] Installing Ubuntu proot-distro..."
proot-distro install ubuntu

# --- Step 3: Set up Ubuntu Environment and Install Dependencies ---
echo "[STEP 3/7] Setting up Ubuntu environment and installing dependencies..."
proot-distro login ubuntu -- <<EOF
apt update -y && apt upgrade -y
apt install -y python3 python3-pip python3-venv nginx git

# --- Step 4: Clone the Repository and Set up Virtual Environment ---
echo "[STEP 4/7] Cloning the repository and setting up virtual environment..."
git clone ${REPO_URL} ${REPO_DIR}
cd ${REPO_DIR}
python3 -m venv venv
source venv/bin/activate
pip install --no-cache-dir -r requirements.txt
pip install gunicorn # Install gunicorn in the venv

# --- Step 5: Configure Gunicorn Systemd Service ---
echo "[STEP 5/7] Configuring Gunicorn Systemd service..."
mkdir -p /etc/systemd/system
cat <<EOT > /etc/systemd/system/call-center-ai.service
[Unit]
Description=Gunicorn instance for Call Center AI
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=${REPO_DIR}
ExecStart=${REPO_DIR}/venv/bin/gunicorn --workers 3 --bind unix:${REPO_DIR}/call-center-ai.sock ${FLASK_APP_MODULE}
Restart=always

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable call-center-ai
systemctl start call-center-ai

# --- Step 6: Configure Nginx as a Reverse Proxy ---
echo "[STEP 6/7] Configuring Nginx as a reverse proxy..."
cat <<EOT > /etc/nginx/sites-available/call-center-ai
server {
    listen 80;
    server_name localhost; # Or your domain/IP if accessible

    location / {
        include proxy_params;
        proxy_pass http://unix:${REPO_DIR}/call-center-ai.sock;
    }
}
EOT

ln -sf /etc/nginx/sites-available/call-center-ai /etc/nginx/sites-enabled/call-center-ai
nginx -t
systemctl restart nginx

# --- Step 7: Environment Variable Setup Instructions ---
echo "[STEP 7/7] Environment Variable Setup Instructions:"
echo "Please create a .env file in ${REPO_DIR} with your API keys and other sensitive information."
echo "Example .env content:"
echo "OPENAI_API_KEY=your_openai_api_key"
echo "STRIPE_SK=your_stripe_secret_key"
echo "TWILIO_SID=your_twilio_sid"
echo "TWILIO_AUTH=your_twilio_auth_token"
echo "TWILIO_PHONE=your_twilio_phone_number"
echo "AWS_ACCESS_KEY_ID=your_aws_access_key_id"
echo "AWS_SECRET_ACCESS_KEY=your_aws_secret_access_key"
echo "
Remember to install python-dotenv in your virtual environment: pip install python-dotenv"
echo "Then, in your Flask app, load environment variables using: from dotenv import load_dotenv; load_dotenv()"

