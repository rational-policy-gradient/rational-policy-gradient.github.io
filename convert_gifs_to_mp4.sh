#!/bin/bash

# Script to convert all GIF files to MP4 for the RPG website
# This script converts GIFs in asymm-videos, ring-videos, and circuit-videos directories

echo "Starting GIF to MP4 conversion..."

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
            
            # FFmpeg conversion with settings optimized for pixelated/pixel art content
            ffmpeg -i "$gif_file" \
                -movflags faststart \
                -pix_fmt yuv420p \
                -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2:flags=neighbor" \
                -crf 18 \
                -preset veryslow \
                -tune stillimage \
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
ASYMM_DIR="$SCRIPT_DIR/assets/figures/asymm-videos"
RING_DIR="$SCRIPT_DIR/assets/figures/ring-videos"
CIRCUIT_DIR="$SCRIPT_DIR/assets/figures/circuit-videos"

echo "Script location: $SCRIPT_DIR"
echo "=================================================="

# Convert GIFs in all three directories
convert_gifs_in_dir "$ASYMM_DIR"
echo ""
convert_gifs_in_dir "$RING_DIR"
echo ""
convert_gifs_in_dir "$CIRCUIT_DIR"

echo "=================================================="
echo "Conversion complete!"

# Summary
total_gifs=$(find "$ASYMM_DIR" "$RING_DIR" "$CIRCUIT_DIR" -name "*.gif" 2>/dev/null | wc -l)
total_mp4s=$(find "$ASYMM_DIR" "$RING_DIR" "$CIRCUIT_DIR" -name "*.mp4" 2>/dev/null | wc -l)

echo "Summary:"
echo "  Total GIF files found: $total_gifs"
echo "  Total MP4 files created: $total_mp4s"

if [ "$total_gifs" -gt 0 ]; then
    echo ""
    echo "Next steps:"
    echo "1. Update your HTML files to use .mp4 extensions instead of .gif"
    echo "2. Test the website to ensure videos load correctly"
    echo "3. Consider removing the original .gif files if everything works"
    echo ""
    echo "To update file extensions in HTML, you can use:"
    echo "  sed -i 's/\\.gif/\\.mp4/g' cross-play-grids.html"
    echo "  sed -i 's/\\.gif/\\.mp4/g' index.html"
fi
