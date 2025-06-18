import openai, os
from dotenv import load_dotenv

load_dotenv()
openai.api_key = os.getenv("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

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
