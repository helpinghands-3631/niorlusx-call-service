import openai, os
from dotenv import load_dotenv

load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")

def transcribe_speech(audio_file):
    with open(audio_file, "rb") as f:
        return openai.Audio.transcribe("whisper-1", f)["text"]

def generate_response(prompt):
    resp = openai.ChatCompletion.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}]
    )
    return resp.choices[0].message.content.strip()

def text_to_speech(text):
    speech = openai.Audio.speech.create(model="tts-1", voice="alloy", input=text)
    speech.stream_to_file("output.mp3")
    return "output.mp3"
