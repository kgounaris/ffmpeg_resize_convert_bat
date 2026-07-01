# FFmpeg Batch Video Resizer and Converter for Windows

Resize videos in bulk with a Windows BAT script powered by FFmpeg. This project helps you resize by width or height, optionally convert output format, and keep original filenames while saving into a separate output folder.

If you are looking for a fast ffmpeg batch resize script, ffmpeg video converter bat file, or a simple Windows video resize automation tool, this project is built for that workflow.

## Features

- Batch resize all videos in the same folder as the script
- Choose resize mode: width or height
- Enter custom pixel size (example: 1920 width or 1080 height)
- Optional output format selection: mp4, mov, mkv, avi, webm
- Leave format empty to keep each file's original extension
- Selectable video codec: H.264, H.265, VP9, or AV1
- Selectable output quality: high, balanced, or smaller size (CRF auto-tuned per codec)
- Automatic container/audio fallback when the chosen format is incompatible with the codec
- Preserve original video base filename in output
- Keep source files untouched
- All outputs collected under an exports folder, in subfolders named by resize mode, size, codec, and CRF

## How It Works

When you run the script:

1. It asks if you want to resize by width or by height.
2. It asks for the target dimension in pixels.
3. It asks for optional output format.
4. It asks for the video codec (H.264, H.265, VP9, or AV1).
5. It asks for the output quality (high, balanced, or smaller size).
6. It scans all supported video files in the script folder.
7. It creates an exports folder, then a subfolder like exports/width_1920_h264_crf20 or exports/height_1080_h265_crf28.
8. It writes converted videos there using the original base filename.

The script maintains aspect ratio using FFmpeg scale rules:

- Width mode: scale=TARGET_WIDTH:-2
- Height mode: scale=-2:TARGET_HEIGHT

## Supported Video Formats

### Input Formats

- .mp4
- .mov
- .mkv
- .avi
- .wmv
- .flv
- .webm
- .m4v
- .mpg
- .mpeg
- .ts

### Output Format Options

- mp4
- mov
- mkv
- avi
- webm
- empty input (keep original extension)

## Requirements

- Windows 10 or Windows 11
- FFmpeg installed and available in PATH

Check FFmpeg installation:

```bat
ffmpeg -version
```

If command is not recognized, install FFmpeg and add it to your system PATH.

## Quick Start

1. Put resize.bat in the folder with your videos.
2. Double-click resize.bat.
3. Select width or height.
4. Enter pixel value.
5. Enter output format or press Enter to keep original format.
6. Select video codec (H.264, H.265, VP9, or AV1).
7. Select quality (high, balanced, or smaller size).
8. Wait for processing to complete.
9. Open the generated output folder.

## Example

If you choose:

- Resize mode: width
- Dimension: 1280
- Output format: empty
- Codec: H.264
- Quality: high (CRF 20)

The script creates:

- Folder: exports/width_1280_h264_crf20
- Outputs: same base filename, original extension

If you choose output format mp4, all outputs in that folder are saved as .mp4.

## Output Naming Behavior

- Source: holiday_clip.mov
- Output folder: exports/height_720_h265_crf28
- Output file (keep original format): holiday_clip.mov
- Output file (selected format mp4): holiday_clip.mp4

## Codec and Quality

You pick a video codec and a quality level at runtime. Because CRF scales differ between codecs, each codec maps the quality level to its own CRF value:

| Quality  | H.264 | H.265 | VP9 | AV1 |
|----------|-------|-------|-----|-----|
| High     | 20    | 24    | 31  | 25  |
| Balanced | 23    | 28    | 33  | 30  |
| Smaller  | 28    | 32    | 36  | 35  |

Codec-specific behavior:

- H.264 (libx264): widest compatibility; works in mp4, mov, mkv, avi.
- H.265 (libx265): ~30-50% smaller than H.264; works in mp4, mov, mkv. Adds the `hvc1` tag in mp4/mov for Apple/QuickTime playback.
- VP9 (libvpx-vp9): web codec; written to webm or mkv with Opus audio.
- AV1: smallest files but very slow; written to mkv, mp4, or webm. The script auto-detects the encoder, preferring SVT-AV1 (libsvtav1) and falling back to libaom-av1 if your FFmpeg build does not include SVT-AV1.

If the output format you pick is not compatible with the codec, the script automatically falls back to a safe container for that codec and prints a note. WebM output always uses Opus audio; all other containers use AAC.

## FFmpeg Settings Used

The script uses:

- Video codec: selectable — libx264, libx265, libvpx-vp9, or AV1 (libsvtav1 with libaom-av1 fallback)
- Preset: fast (H.264/H.265), tuned defaults for VP9/AV1
- CRF: selectable at runtime, auto-tuned per codec (see table above)
- Audio codec: aac 128k (libopus 128k for WebM)
- Faststart flag for MP4/MOV streaming playback

You can edit resize.bat if you want different presets, CRF values, or bitrates.

## Troubleshooting

### FFmpeg is not recognized

Install FFmpeg and add its bin folder to PATH, then reopen Command Prompt.

### No files processed

Make sure video files are in the same folder as resize.bat and have supported extensions.

### Invalid dimension error

Enter a whole number greater than 0.

### Invalid format error

Use one of: mp4, mov, mkv, avi, webm, or leave blank.

## Use Cases

- Resize videos for YouTube uploads
- Prepare social media video dimensions
- Batch convert mixed video formats
- Create lighter web-friendly copies
- Standardize video libraries by size

## Why Use This FFmpeg BAT Script

- No complex command memorization
- Works directly from File Explorer
- Good for bulk processing
- Keeps files organized in separate output folders

## Keywords

ffmpeg batch resize, ffmpeg bat script, windows video resize script, ffmpeg resize by width, ffmpeg resize by height, ffmpeg bulk convert videos, ffmpeg convert keep filename, batch video converter windows, ffmpeg automation bat file