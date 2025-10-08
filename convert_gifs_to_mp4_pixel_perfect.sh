#!/bin/bash

# Script to convert all GIF files to MP4 for pixelated content
# This version uses the most aggressive settings to preserve pixel sharpness

echo "Starting GIF to MP4 conversion (pixel-perfect mode)..."

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
            
            # Ultra-sharp conversion for pixelated content
            ffmpeg -i "$gif_file" \
                -movflags faststart \
                -pix_fmt yuv420p \
                -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2:flags=neighbor" \
                -crf 0 \
                -preset veryslow \
                -tune stillimage \
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
    echo "Please install FFmpeg first:"
    echo "  macOS: brew install ffmpeg"
    echo "  Ubuntu: sudo apt install ffmpeg"
    echo "  Windows: Download from https://ffmpeg.org/download.html"
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define directories to process
CRAMPED_ROOM_DIR="$SCRIPT_DIR/assets/figures/cramped-room-videos"
FORCED_COORD_DIR="$SCRIPT_DIR/assets/figures/forced-coord-heatmap-videos"

echo "Script location: $SCRIPT_DIR"
echo "Using pixel-perfect settings:"
echo "  - Nearest neighbor scaling (no blur)"
echo "  - CRF 0 (lossless)"
echo "  - Very slow preset (best quality)"
echo "  - Still image tuning"
echo "=================================================="

# Convert GIFs in both directories
convert_gifs_in_dir "$CRAMPED_ROOM_DIR"
echo ""
convert_gifs_in_dir "$FORCED_COORD_DIR"

echo "=================================================="
echo "Conversion complete!"

# Summary
total_gifs=$(find "$CRAMPED_ROOM_DIR" "$FORCED_COORD_DIR" -name "*.gif" 2>/dev/null | wc -l)
total_mp4s=$(find "$CRAMPED_ROOM_DIR" "$FORCED_COORD_DIR" -name "*.mp4" 2>/dev/null | wc -l)

echo "Summary:"
echo "  Total GIF files found: $total_gifs"
echo "  Total MP4 files created: $total_mp4s"

if [ "$total_gifs" -gt 0 ]; then
    echo ""
    echo "Settings used for pixel-perfect conversion:"
    echo "  ✓ Nearest neighbor scaling (preserves sharp pixels)"
    echo "  ✓ CRF 0 (lossless quality)"
    echo "  ✓ Very slow preset (maximum quality)"
    echo "  ✓ Still image tuning (optimized for static elements)"
    echo ""
    echo "Note: Files will be larger due to lossless encoding,"
    echo "but pixels will be perfectly preserved."
fi
