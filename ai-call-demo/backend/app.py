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
