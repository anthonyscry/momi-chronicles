import os
from google import genai

api_key = os.environ.get("GOOGLE_API_KEY") or os.environ.get("GEMINI_API_KEY")
print(f"API Key found: {bool(api_key)}")

try:
    client = genai.Client(api_key=api_key or "DUMMY")
    print("Client initialized")
    # We can't really list models easily with this client without a real key sometimes,
    # but let's see if we can at least print the models if it works.
except Exception as e:
    print(f"Error: {e}")
