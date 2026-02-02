print("1. Start")
import os
os.environ['HTTP_PROXY'] = ''
os.environ['HTTPS_PROXY'] = ''
print("2. Environment set")
import sys
print(f"3. Python version: {sys.version}")
print("4. Attempting import google.genai...")
import google.genai as genai
print("5. Successfully imported google.genai")
from google.genai import types
print("6. Successfully imported types")
print("7. Done")
