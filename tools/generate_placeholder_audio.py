#!/usr/bin/env python3
"""
Generate placeholder audio files for Momi's Adventure.
Creates simple sine wave tones for music and short blips for SFX.
These are meant to be replaced with real audio (e.g., from Suno AI).
"""

import os
import struct
import math

# Output directories
MUSIC_DIR = "../assets/audio/music"
SFX_DIR = "../assets/audio/sfx"

# Audio parameters
SAMPLE_RATE = 44100
BITS_PER_SAMPLE = 16
NUM_CHANNELS = 1


def generate_sine_wave(frequency, duration, volume=0.5, fade_in=0.05, fade_out=0.1):
    """Generate a sine wave at the given frequency."""
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Basic sine wave
        value = math.sin(2 * math.pi * frequency * t)
        
        # Apply fade in
        if t < fade_in:
            value *= t / fade_in
        
        # Apply fade out
        time_from_end = duration - t
        if time_from_end < fade_out:
            value *= time_from_end / fade_out
        
        # Scale to 16-bit range
        sample = int(value * volume * 32767)
        samples.append(max(-32768, min(32767, sample)))
    
    return samples


def generate_chord(frequencies, duration, volume=0.3):
    """Generate a chord (multiple frequencies)."""
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        value = 0
        for freq in frequencies:
            value += math.sin(2 * math.pi * freq * t)
        value /= len(frequencies)
        
        # Fade in/out
        fade = 0.1
        if t < fade:
            value *= t / fade
        if duration - t < fade:
            value *= (duration - t) / fade
        
        sample = int(value * volume * 32767)
        samples.append(max(-32768, min(32767, sample)))
    
    return samples


def generate_arpeggio(frequencies, duration, volume=0.4):
    """Generate an arpeggio (notes played in sequence)."""
    samples = []
    note_duration = duration / len(frequencies)
    
    for freq in frequencies:
        note_samples = generate_sine_wave(freq, note_duration, volume, 0.02, 0.05)
        samples.extend(note_samples)
    
    return samples


def generate_sweep(start_freq, end_freq, duration, volume=0.5):
    """Generate a frequency sweep (for swoosh sounds)."""
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        progress = t / duration
        freq = start_freq + (end_freq - start_freq) * progress
        value = math.sin(2 * math.pi * freq * t)
        
        # Envelope
        envelope = math.sin(math.pi * progress)  # Bell curve
        sample = int(value * envelope * volume * 32767)
        samples.append(max(-32768, min(32767, sample)))
    
    return samples


def generate_noise_burst(duration, volume=0.3):
    """Generate a short noise burst (for impact sounds)."""
    import random
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Random noise
        value = random.uniform(-1, 1)
        
        # Sharp attack, quick decay
        envelope = math.exp(-t * 20)
        sample = int(value * envelope * volume * 32767)
        samples.append(max(-32768, min(32767, sample)))
    
    return samples


def generate_descending(start_freq, end_freq, duration, volume=0.4):
    """Generate descending tone (for death/sad sounds)."""
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        progress = t / duration
        freq = start_freq - (start_freq - end_freq) * progress
        value = math.sin(2 * math.pi * freq * t)
        
        # Fade out
        envelope = 1 - progress
        sample = int(value * envelope * volume * 32767)
        samples.append(max(-32768, min(32767, sample)))
    
    return samples


def generate_click(duration=0.05, volume=0.5):
    """Generate a short click sound."""
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        freq = 1000
        value = math.sin(2 * math.pi * freq * t)
        envelope = math.exp(-t * 50)
        sample = int(value * envelope * volume * 32767)
        samples.append(max(-32768, min(32767, sample)))
    
    return samples


def write_wav(filename, samples):
    """Write samples to a WAV file."""
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    
    num_samples = len(samples)
    data_size = num_samples * 2  # 16-bit = 2 bytes per sample
    file_size = 36 + data_size
    
    with open(filename, 'wb') as f:
        # RIFF header
        f.write(b'RIFF')
        f.write(struct.pack('<I', file_size))
        f.write(b'WAVE')
        
        # fmt chunk
        f.write(b'fmt ')
        f.write(struct.pack('<I', 16))  # Chunk size
        f.write(struct.pack('<H', 1))   # Audio format (PCM)
        f.write(struct.pack('<H', NUM_CHANNELS))
        f.write(struct.pack('<I', SAMPLE_RATE))
        f.write(struct.pack('<I', SAMPLE_RATE * NUM_CHANNELS * 2))  # Byte rate
        f.write(struct.pack('<H', NUM_CHANNELS * 2))  # Block align
        f.write(struct.pack('<H', BITS_PER_SAMPLE))
        
        # data chunk
        f.write(b'data')
        f.write(struct.pack('<I', data_size))
        for sample in samples:
            f.write(struct.pack('<h', sample))
    
    print(f"  Created: {filename} ({num_samples} samples, {num_samples/SAMPLE_RATE:.2f}s)")


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    
    print("=" * 60)
    print("Generating Placeholder Audio for Momi's Adventure")
    print("=" * 60)
    
    # Musical frequencies (Hz)
    C4 = 261.63
    D4 = 293.66
    E4 = 329.63
    F4 = 349.23
    G4 = 392.00
    A4 = 440.00
    B4 = 493.88
    C5 = 523.25
    
    # =========================================================================
    # MUSIC TRACKS
    # =========================================================================
    print("\n[Music Tracks]")
    
    # Title - Heroic C major chord
    samples = generate_chord([C4, E4, G4, C5], 2.0, 0.3)
    write_wav(f"{MUSIC_DIR}/title.wav", samples)
    
    # Neighborhood - Happy G major arpeggio
    samples = generate_arpeggio([G4, B4, D4*2, G4*2, D4*2, B4], 2.0, 0.35)
    write_wav(f"{MUSIC_DIR}/neighborhood.wav", samples)
    
    # Backyard - Tense A minor chord
    samples = generate_chord([A4*0.5, C4, E4, A4], 2.0, 0.25)
    write_wav(f"{MUSIC_DIR}/backyard.wav", samples)
    
    # Game Over - Sad descending
    samples = generate_descending(C5, C4*0.5, 2.0, 0.3)
    write_wav(f"{MUSIC_DIR}/game_over.wav", samples)
    
    # Victory - Happy ascending arpeggio
    samples = generate_arpeggio([C4, E4, G4, C5, E4*2, G4*2], 1.5, 0.4)
    write_wav(f"{MUSIC_DIR}/victory.wav", samples)
    
    # Pause - Soft ambient tone
    samples = generate_sine_wave(220, 2.0, 0.15, 0.5, 0.5)
    write_wav(f"{MUSIC_DIR}/pause.wav", samples)
    
    # Combat - Intense pulsing
    combat_samples = []
    for _ in range(4):
        combat_samples.extend(generate_chord([E4*0.5, B4*0.5, E4], 0.5, 0.35))
    write_wav(f"{MUSIC_DIR}/combat.wav", combat_samples)
    
    # =========================================================================
    # SOUND EFFECTS
    # =========================================================================
    print("\n[Sound Effects]")
    
    # Attack - Swoosh
    samples = generate_sweep(800, 200, 0.15, 0.5)
    write_wav(f"{SFX_DIR}/attack.wav", samples)
    
    # Hit - Impact
    samples = generate_noise_burst(0.1, 0.6)
    write_wav(f"{SFX_DIR}/hit.wav", samples)
    
    # Player Hurt - Low thud
    samples = generate_sweep(200, 80, 0.2, 0.5)
    write_wav(f"{SFX_DIR}/player_hurt.wav", samples)
    
    # Enemy Hurt - Mid thud  
    samples = generate_sweep(400, 150, 0.15, 0.5)
    write_wav(f"{SFX_DIR}/enemy_hurt.wav", samples)
    
    # Enemy Death - Descending tone
    samples = generate_descending(600, 100, 0.4, 0.5)
    write_wav(f"{SFX_DIR}/enemy_death.wav", samples)
    
    # Player Death - Low descending
    samples = generate_descending(300, 50, 0.5, 0.5)
    write_wav(f"{SFX_DIR}/player_death.wav", samples)
    
    # Dodge - Whoosh
    samples = generate_sweep(400, 800, 0.2, 0.4)
    write_wav(f"{SFX_DIR}/dodge.wav", samples)
    
    # Menu Select - Click
    samples = generate_click(0.08, 0.6)
    write_wav(f"{SFX_DIR}/menu_select.wav", samples)
    
    # Menu Navigate - Soft click
    samples = generate_click(0.05, 0.4)
    write_wav(f"{SFX_DIR}/menu_navigate.wav", samples)
    
    # Zone Transition - Sweep up
    samples = generate_sweep(200, 600, 0.5, 0.4)
    write_wav(f"{SFX_DIR}/zone_transition.wav", samples)
    
    # Health Pickup - Happy ding
    samples = generate_arpeggio([C5, E4*2, G4*2], 0.3, 0.5)
    write_wav(f"{SFX_DIR}/health_pickup.wav", samples)
    
    print("\n" + "=" * 60)
    print("Done! All placeholder audio files created.")
    print("=" * 60)
    print("\nTo upgrade to real audio:")
    print("1. Generate music using prompts in SUNO_PROMPTS.md")
    print("2. Convert MP3 to OGG (see assets/audio/AUDIO_README.md)")
    print("3. Replace the .wav files with your .ogg files")
    print("4. Update paths in autoloads/audio_manager.gd")


if __name__ == "__main__":
    main()
