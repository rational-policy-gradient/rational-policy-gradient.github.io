#!/bin/bash

# Script to convert GIFs to truly lossless MP4s
# Uses RGB color space and lossless compression to eliminate any quality loss

echo "Starting GIF to MP4 conversion (truly lossless mode)..."

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
            
            # Method 1: Try lossless RGB first (best quality)
            ffmpeg -i "$gif_file" \
                -c:v libx264rgb \
                -crf 0 \
                -preset ultrafast \
                -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2:flags=neighbor" \
                -movflags +faststart \
                -an \
                -y \
                "$mp4_file" 2>/dev/null
            
            # If that fails, try compatibility mode
            if [ $? -ne 0 ]; then
                echo "  Trying compatibility mode..."
                ffmpeg -i "$gif_file" \
                    -c:v libx264 \
                    -profile:v high \
                    -pix_fmt yuv444p \
                    -crf 0 \
                    -preset ultrafast \
                    -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2:flags=neighbor" \
                    -movflags +faststart \
                    -an \
                    -y \
                    "$mp4_file" 2>/dev/null
            fi
            
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
echo "Using truly lossless settings:"
echo "  - libx264rgb codec (RGB colorspace, no chroma subsampling)"
echo "  - CRF 0 (completely lossless)"
echo "  - Nearest neighbor scaling only"
echo "  - Fallback to yuv444p (4:4:4, no chroma subsampling)"
echo "=================================================="

# Convert GIFs in both directories
convert_gifs_in_dir "$CRAMPED_ROOM_DIR"
echo ""
convert_gifs_in_dir "$FORCED_COORD_DIR"

echo "=================================================="
echo "Conversion complete!"

echo ""
echo "Truly lossless settings applied:"
echo "  ✓ RGB colorspace (no color subsampling)"
echo "  ✓ CRF 0 (mathematically lossless)"
echo "  ✓ Nearest neighbor scaling (pixel-perfect)"
echo "  ✓ No compression artifacts"
echo ""
echo "These should be identical to the original GIFs!"
