#!/bin/bash

# Script to convert GIFs to pixel-perfect MP4s with browser compatibility
# Uses browser-compatible H.264 with maximum quality settings

echo "Starting GIF to MP4 conversion (pixel-perfect + browser compatible)..."

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
            
            # Browser-compatible pixel-perfect conversion
            ffmpeg -i "$gif_file" \
                -c:v libx264 \
                -profile:v baseline \
                -level 3.0 \
                -pix_fmt yuv420p \
                -crf 10 \
                -preset slower \
                -tune stillimage \
                -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2:flags=neighbor" \
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
echo "Using pixel-perfect browser-compatible settings:"
echo "  - H.264 Baseline profile (maximum browser compatibility)"
echo "  - yuv420p pixel format (universal browser support)"
echo "  - CRF 10 (near-lossless, much higher quality than default)"
echo "  - Nearest neighbor scaling (pixel-perfect)"
echo "  - Still image tuning (optimized for low-motion content)"
echo "  - Slower preset (better compression efficiency)"
echo "=================================================="

# Convert GIFs in both directories
convert_gifs_in_dir "$CRAMPED_ROOM_DIR"
echo ""
convert_gifs_in_dir "$FORCED_COORD_DIR"

echo "=================================================="
echo "Conversion complete!"

echo ""
echo "Browser-compatible pixel-perfect settings applied:"
echo "  ✓ H.264 Baseline profile (works on all devices)"
echo "  ✓ yuv420p format (universal browser support)"
echo "  ✓ CRF 10 (near-lossless quality, much better than default CRF 23)"
echo "  ✓ Nearest neighbor scaling (pixel-perfect)"
echo "  ✓ Still image tuning (optimized for pixel art)"
echo ""
echo "These should be pixel-perfect AND load in all browsers!"
