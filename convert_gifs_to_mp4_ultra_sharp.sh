#!/bin/bash

# Script to convert GIFs to ultra-sharp MP4s for pixelated content
# Uses aggressive settings to preserve pixel sharpness while maintaining browser compatibility

echo "Starting GIF to MP4 conversion (ultra-sharp mode)..."

# Function to convert GIFs in a directory
convert_gifs_in_dir() {
    local dir="$1"
    echo "Processing directory: $dir"
    
    if [ ! -d "$dir" ]; then
        echo "Directory $dir does not exist, skipping..."
        return
    fi
    
    # Count total GIF files
    gif_count=$(find "$dir" -name "*.gif" | wc -l)
    if [ "$gif_count" -eq 0 ]; then
        echo "No GIF files found in $dir"
        return
    fi
    
    echo "Found $gif_count GIF files in $dir"
    
    # Convert each GIF to MP4
    local count=0
    for gif_file in "$dir"/*.gif; do
        if [ -f "$gif_file" ]; then
            count=$((count + 1))
            # Get filename without extension
            base_name=$(basename "$gif_file" .gif)
            mp4_file="$dir/${base_name}.mp4"
            
            echo "[$count/$gif_count] Converting: $(basename "$gif_file") -> ${base_name}.mp4"
            
            # Ultra-sharp conversion optimized for pixelated content
            ffmpeg -i "$gif_file" \
                -c:v libx264 \
                -profile:v baseline \
                -level 3.0 \
                -pix_fmt yuv420p \
                -crf 15 \
                -preset veryslow \
                -tune stillimage \
                -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2:flags=neighbor,format=yuv420p" \
                -x264-params "ref=1:subme=1:me=dia:no-chroma-me:8x8dct=0:partitions=none" \
                -movflags +faststart \
                -an \
                -y \
                "$mp4_file" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                echo "  ✓ Successfully converted to $mp4_file"
                
                # Show file size comparison
                gif_size=$(du -h "$gif_file" | cut -f1)
                mp4_size=$(du -h "$mp4_file" | cut -f1)
                echo "  📊 Size: $gif_size (GIF) -> $mp4_size (MP4)"
            else
                echo "  ✗ Failed to convert $gif_file"
            fi
        fi
    done
}

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: FFmpeg is not installed or not in PATH"
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define directories to process
CRAMPED_ROOM_DIR="$SCRIPT_DIR/assets/figures/cramped-room-videos"
FORCED_COORD_DIR="$SCRIPT_DIR/assets/figures/forced-coord-heatmap-videos"

echo "Script location: $SCRIPT_DIR"
echo "Using ultra-sharp settings for pixelated content:"
echo "  - H.264 Baseline profile (browser compatible)"
echo "  - CRF 15 (very high quality)"
echo "  - Very slow preset (maximum quality)"
echo "  - Still image tuning (optimized for static elements)"
echo "  - Nearest neighbor scaling (no blur)"
echo "  - Disabled subpixel motion estimation (sharper)"
echo "  - Disabled chroma motion estimation (sharper)"
echo "=================================================="

# Convert GIFs in both directories
convert_gifs_in_dir "$CRAMPED_ROOM_DIR"
echo ""
convert_gifs_in_dir "$FORCED_COORD_DIR"

echo "=================================================="
echo "Conversion complete!"

echo ""
echo "Ultra-sharp settings applied:"
echo "  ✓ CRF 15 (very high quality, minimal compression)"
echo "  ✓ Nearest neighbor scaling (preserves hard pixel edges)"
echo "  ✓ Disabled subpixel ME (prevents smoothing)"
echo "  ✓ Still image tuning (optimized for pixel art)"
echo "  ✓ Very slow preset (best compression efficiency)"
echo ""
echo "These files should look much sharper while remaining browser-compatible!"
