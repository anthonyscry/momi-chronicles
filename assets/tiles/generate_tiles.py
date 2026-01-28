#!/usr/bin/env python3
"""Generate a simple tile atlas PNG for Momi's Adventure."""

import struct
import zlib

def create_png(width, height, pixels):
    """Create a PNG file from RGBA pixel data."""
    def png_chunk(chunk_type, data):
        chunk_len = struct.pack('>I', len(data))
        chunk_crc = struct.pack('>I', zlib.crc32(chunk_type + data) & 0xffffffff)
        return chunk_len + chunk_type + data + chunk_crc

    # PNG signature
    signature = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    ihdr = png_chunk(b'IHDR', ihdr_data)
    
    # IDAT chunk (image data)
    raw_data = b''
    for y in range(height):
        raw_data += b'\x00'  # Filter type: None
        for x in range(width):
            idx = (y * width + x) * 4
            raw_data += bytes(pixels[idx:idx+4])
    
    compressed = zlib.compress(raw_data, 9)
    idat = png_chunk(b'IDAT', compressed)
    
    # IEND chunk
    iend = png_chunk(b'IEND', b'')
    
    return signature + ihdr + idat + iend

def main():
    # Create a 128x128 tile atlas (8x8 tiles, each 16x16)
    # This gives us 64 tile slots
    
    tile_size = 16
    atlas_tiles = 8  # 8x8 grid
    width = height = tile_size * atlas_tiles
    
    # Define tile colors (RGBA)
    tiles = {
        # Row 0: Ground types
        (0, 0): (76, 153, 76, 255),      # Grass - green
        (1, 0): (102, 178, 102, 255),    # Grass variant - lighter green
        (2, 0): (194, 178, 128, 255),    # Path/dirt - tan
        (3, 0): (169, 153, 103, 255),    # Path variant - darker tan
        (4, 0): (139, 119, 101, 255),    # Dirt - brown
        (5, 0): (64, 64, 64, 255),       # Asphalt - dark gray
        (6, 0): (80, 80, 80, 255),       # Asphalt variant
        (7, 0): (96, 96, 96, 255),       # Concrete - gray
        
        # Row 1: Walls and obstacles
        (0, 1): (139, 90, 43, 255),      # Wood fence - brown
        (1, 1): (119, 70, 33, 255),      # Wood fence dark
        (2, 1): (160, 160, 160, 255),    # Stone wall - gray
        (3, 1): (140, 140, 140, 255),    # Stone wall dark
        (4, 1): (200, 80, 80, 255),      # Brick - red
        (5, 1): (180, 60, 60, 255),      # Brick dark
        (6, 1): (220, 220, 220, 255),    # White wall
        (7, 1): (200, 200, 200, 255),    # White wall shadow
        
        # Row 2: House parts
        (0, 2): (139, 69, 19, 255),      # Roof - brown
        (1, 2): (160, 82, 45, 255),      # Roof light
        (2, 2): (70, 70, 120, 255),      # Roof blue
        (3, 2): (90, 90, 140, 255),      # Roof blue light
        (4, 2): (101, 67, 33, 255),      # Door - dark brown
        (5, 2): (173, 216, 230, 255),    # Window - light blue
        (6, 2): (245, 245, 220, 255),    # House wall - beige
        (7, 2): (255, 255, 240, 255),    # House wall light
        
        # Row 3: Nature
        (0, 3): (34, 100, 34, 255),      # Tree trunk
        (1, 3): (34, 139, 34, 255),      # Tree leaves - forest green
        (2, 3): (50, 160, 50, 255),      # Bush - green
        (3, 3): (255, 200, 100, 255),    # Flower yellow
        (4, 3): (255, 100, 100, 255),    # Flower red
        (5, 3): (100, 149, 237, 255),    # Water - cornflower blue
        (6, 3): (65, 105, 225, 255),     # Water deep
        (7, 3): (144, 238, 144, 255),    # Light grass
        
        # Row 4: Props
        (0, 4): (128, 128, 128, 255),    # Trash can - gray
        (1, 4): (0, 100, 0, 255),        # Mailbox post
        (2, 4): (70, 130, 180, 255),     # Mailbox - steel blue
        (3, 4): (255, 215, 0, 255),      # Fire hydrant - gold/yellow
        (4, 4): (139, 137, 137, 255),    # Rock
        (5, 4): (169, 169, 169, 255),    # Rock light
        (6, 4): (105, 105, 105, 255),    # Rock dark
        (7, 4): (47, 79, 79, 255),       # Bench
        
        # Row 5: Special tiles
        (0, 5): (255, 0, 255, 255),      # Zone exit marker - magenta
        (1, 5): (0, 255, 255, 255),      # Zone entrance - cyan  
        (2, 5): (255, 255, 0, 255),      # Spawn point - yellow
        (3, 5): (255, 165, 0, 255),      # Enemy spawn - orange
        (4, 5): (0, 0, 0, 0),            # Transparent/empty
        (5, 5): (0, 0, 0, 255),          # Black
        (6, 5): (255, 255, 255, 255),    # White
        (7, 5): (128, 0, 128, 255),      # Purple (debug)
    }
    
    # Create pixel data
    pixels = [0] * (width * height * 4)
    
    # Fill with default (transparent)
    for i in range(0, len(pixels), 4):
        pixels[i] = 0
        pixels[i+1] = 0
        pixels[i+2] = 0
        pixels[i+3] = 0
    
    # Draw each tile
    for (tx, ty), color in tiles.items():
        for py in range(tile_size):
            for px in range(tile_size):
                x = tx * tile_size + px
                y = ty * tile_size + py
                idx = (y * width + x) * 4
                
                # Add slight variation for visual interest
                r, g, b, a = color
                
                # Create a simple border effect (darker edges)
                if px == 0 or py == 0:
                    r = max(0, r - 20)
                    g = max(0, g - 20)
                    b = max(0, b - 20)
                elif px == tile_size - 1 or py == tile_size - 1:
                    r = min(255, r + 10)
                    g = min(255, g + 10)
                    b = min(255, b + 10)
                
                pixels[idx] = r
                pixels[idx + 1] = g
                pixels[idx + 2] = b
                pixels[idx + 3] = a
    
    # Generate PNG
    png_data = create_png(width, height, pixels)
    
    # Save to file
    with open('tile_atlas.png', 'wb') as f:
        f.write(png_data)
    
    print(f"Created tile_atlas.png ({width}x{height}, {len(tiles)} tiles)")

if __name__ == '__main__':
    main()
