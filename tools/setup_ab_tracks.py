#!/usr/bin/env python3
"""
Set up A/B audio testing for Momi's Adventure.
Copies Suno tracks to standardized A/B filenames.
"""

import os
import shutil

# Source directory
MUSIC_DIR = "../assets/audio/music"

# Track mappings: game_name -> (version_a_partial_id, version_b_partial_id)
TRACK_MAPPINGS = {
    "title": ("5c0e1acb", "6677340f"),
    "neighborhood": ("2d5c3656", "2f11527c"),
    "backyard": ("064916c2", "ccc7928b"),
    "combat": ("dbc59bb8", "71337ec0"),  # Shorter one first as A
    "game_over": ("0d234fcb", "7e61d2fb"),  # Short one first as A
    "victory": ("faa4529e", "ee016eee"),
    "pause": ("aea657f9", "f713d0b5"),
}

def find_file_by_id(directory, partial_id):
    """Find a file containing the partial ID in its name."""
    for filename in os.listdir(directory):
        if partial_id in filename and filename.endswith('.wav') and not filename.endswith('.import'):
            return filename
    return None

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    
    print("=" * 60)
    print("Setting up A/B Audio Testing")
    print("=" * 60)
    
    for game_name, (id_a, id_b) in TRACK_MAPPINGS.items():
        print(f"\n[{game_name}]")
        
        # Find source files
        file_a = find_file_by_id(MUSIC_DIR, id_a)
        file_b = find_file_by_id(MUSIC_DIR, id_b)
        
        if file_a:
            dest_a = f"{MUSIC_DIR}/{game_name}_a.wav"
            shutil.copy2(f"{MUSIC_DIR}/{file_a}", dest_a)
            print(f"  A: {file_a[:50]}... -> {game_name}_a.wav")
        else:
            print(f"  A: NOT FOUND (id: {id_a})")
        
        if file_b:
            dest_b = f"{MUSIC_DIR}/{game_name}_b.wav"
            shutil.copy2(f"{MUSIC_DIR}/{file_b}", dest_b)
            print(f"  B: {file_b[:50]}... -> {game_name}_b.wav")
        else:
            print(f"  B: NOT FOUND (id: {id_b})")
        
        # Also copy A as the default (no suffix)
        if file_a:
            dest_default = f"{MUSIC_DIR}/{game_name}.wav"
            # Don't overwrite if it's our placeholder
            if os.path.getsize(f"{MUSIC_DIR}/{file_a}") > 200000:  # Suno files are big
                shutil.copy2(f"{MUSIC_DIR}/{file_a}", dest_default)
                print(f"  Default: {game_name}.wav (copy of A)")
    
    print("\n" + "=" * 60)
    print("Done! A/B tracks ready.")
    print("=" * 60)
    print("\nIn-game controls:")
    print("  F2 = Toggle between A/B versions")
    print("  UI shows current track and version")

if __name__ == "__main__":
    main()
