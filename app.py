from flask import Flask, request, Response, jsonify
from twilio.twiml.voice_response import VoiceResponse
from dotenv import load_dotenv
import openai
import os
import logging

# Load environment variables
load_dotenv()

# OpenAI API Key from .env
openai.api_key = os.getenv("OPENAI_API_KEY")

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("Niorlusx")

@app.route("/twilio/webhook", methods=["POST"])
def handle_call():
    caller = request.form.get("From", "Unknown")
    logger.info(f"📞 Incoming call from {caller}")

    response = VoiceResponse()
    response.say("Welcome to the Niorlusx AI line. Generating your voice...", voice="Polly.Joanna", language="en-AU")

    # Generate TTS using OpenAI
    try:
        with open("niorlusx.mp3", "wb") as f:
            result = openai.audio.speech.create(
                model="tts-1",
                voice=os.getenv("VOICE_ID", "nova"),
                input="Hello there. You’ve reached the Niorlusx assistant. What can I do for you?"
            )
            f.write(result.content)
        logger.info("✅ OpenAI TTS voice generated.")
    except Exception as e:
        logger.error(f"❌ OpenAI TTS error: {e}")

    response.record(max_length=90, timeout=5, play_beep=True)
    response.hangup()
    return Response(str(response), mimetype="text/xml")

@app.route("/", methods=["GET"])
def health_check():
    return "✅ Niorlusx AI Flask server is active."

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 3000))
    logger.info(f"🚀 Starting Flask app on port {port}")
    app.run(host="0.0.0.0", port=port)
