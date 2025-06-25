import { startVoiceAgent } from "openai-agents-js";

startVoiceAgent({
  apiKey: process.env.OPENAI_API_KEY,
  voice: "alloy", // or shimmer, nova, fable, etc.
  onTranscript(transcript) {
    console.log("🗣️ User:", transcript);
  },
  onResponse(response) {
    console.log("🤖 Assistant:", response);
  },
});
