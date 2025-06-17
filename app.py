from flask import Flask, request, jsonify
from datetime import datetime
import uuid

app = Flask(__name__)
calls = []

@app.route("/start_call", methods=["POST"])
def start_call():
    data = request.json
    call_id = str(uuid.uuid4())
    calls.append({
        "call_id": call_id,
        "user_id": data.get("user_id"),
        "start_time": datetime.utcnow().isoformat(),
        "status": "active"
    })
    return jsonify({"message": "Call started", "call_id": call_id}), 200

@app.route("/end_call", methods=["POST"])
def end_call():
    data = request.json
    for call in calls:
        if call["call_id"] == data.get("call_id"):
            call["end_time"] = datetime.utcnow().isoformat()
            call["status"] = "ended"
            return jsonify({"message": "Call ended"}), 200
    return jsonify({"error": "Call not found"}), 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
