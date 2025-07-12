from flask import Flask, request
from twilio.twiml.voice_response import VoiceResponse

app = Flask(__name__)

@app.route("/incoming_call", methods=["POST"])
def incoming_call():
    resp = VoiceResponse()
    resp.say("Welcome to Niorlusx. Please hold while we connect you.")
    return str(resp)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
