import struct
import zlib

def create_png(width, height, r, g, b):
    # PNG signature
    png_sig = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk
    # Width (4 bytes), Height (4 bytes), Bit depth (1), Color type (1=RGB), Compression (1), Filter (1), Interlace (1)
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    ihdr_chunk = struct.pack('>I', 13) + b'IHDR' + ihdr_data + struct.pack('>I', zlib.crc32(b'IHDR' + ihdr_data) & 0xffffffff)
    
    # IDAT chunk
    # Simple uncompressed-style RGB data (filter byte 0 at start of each row)
    pixel_data = bytearray()
    for _ in range(height):
        pixel_data.append(0) # Filter type 0
        for _ in range(width):
            pixel_data.extend([r, g, b])
    
    compressed_data = zlib.compress(pixel_data)
    idat_chunk = struct.pack('>I', len(compressed_data)) + b'IDAT' + compressed_data + struct.pack('>I', zlib.crc32(b'IDAT' + compressed_data) & 0xffffffff)
    
    # IEND chunk
    iend_chunk = struct.pack('>I', 0) + b'IEND' + struct.pack('>I', zlib.crc32(b'IEND') & 0xffffffff)
    
    return png_sig + ihdr_chunk + idat_chunk + iend_chunk

# Create a simple white 64x64 grid-like texture for levels_grid.png
with open('scenes/levels/levels_grid.png', 'wb') as f:
    f.write(create_png(64, 64, 255, 255, 255))

# Create a simple white/gray 64x64 texture for fog_tex.png
with open('scenes/objects/fog_tex.png', 'wb') as f:
    f.write(create_png(64, 64, 200, 200, 255))

print("Guaranteed valid PNGs created.")
