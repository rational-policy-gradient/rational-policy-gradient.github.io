#!/bin/bash

# Script to convert GIFs to browser-compatible MP4s
# Uses baseline H.264 profile for maximum browser compatibility

echo "Starting GIF to MP4 conversion (browser-compatible mode)..."

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
            
            # Browser-compatible conversion with pixel preservation
            ffmpeg -i "$gif_file" \
                -c:v libx264 \
                -profile:v baseline \
                -level 3.0 \
                -pix_fmt yuv420p \
                -crf 20 \
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
echo "Using browser-compatible settings:"
echo "  - H.264 Baseline profile (maximum compatibility)"
echo "  - Level 3.0 (widely supported)"
echo "  - Nearest neighbor scaling (sharp pixels)"
echo "  - CRF 20 (high quality)"
echo "  - Fast start for web streaming"
echo "=================================================="

# Convert GIFs in both directories
convert_gifs_in_dir "$CRAMPED_ROOM_DIR"
echo ""
convert_gifs_in_dir "$FORCED_COORD_DIR"

echo "=================================================="
echo "Conversion complete!"

echo ""
echo "Browser compatibility features:"
echo "  ✓ H.264 Baseline profile (works on all devices)"
echo "  ✓ Level 3.0 (supports old devices/browsers)"
echo "  ✓ Fast start enabled (quick loading)"
echo "  ✓ Nearest neighbor scaling (preserves pixels)"
echo "  ✓ No audio track (smaller files)"
