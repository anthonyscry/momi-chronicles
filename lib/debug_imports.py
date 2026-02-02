print("Starting...")
import os
print("Imported os")
import sys
print("Imported sys")
import pathlib
print("Imported pathlib")
try:
    from google import genai
    print("Imported genai")
except ImportError:
    print("Failed to import genai")
try:
    from PIL import Image
    print("Imported Pillow")
except ImportError:
    print("Failed to import Pillow")
print("All imports done")
