# FFmpeg Batch Video Resizer and Converter for Windows

Resize videos in bulk with a Windows BAT script powered by FFmpeg. This project helps you resize by width or height, optionally convert output format, and keep original filenames while saving into a separate output folder.

If you are looking for a fast ffmpeg batch resize script, ffmpeg video converter bat file, or a simple Windows video resize automation tool, this project is built for that workflow.

## Features

- Batch resize all videos in the same folder as the script
- Choose resize mode: width or height
- Enter custom pixel size (example: 1920 width or 1080 height)
- Optional output format selection: mp4, mov, mkv, avi, webm
- Leave format empty to keep each file's original extension
- Preserve original video base filename in output
- Keep source files untouched
- Automatic output folder naming by resize mode and size

## How It Works

When you run the script:

1. It asks if you want to resize by width or by height.
2. It asks for the target dimension in pixels.
3. It asks for optional output format.
4. It scans all supported video files in the script folder.
5. It creates an output folder like width_1920 or height_1080.
6. It writes converted videos there using the original base filename.

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
6. Wait for processing to complete.
7. Open the generated output folder.

## Example

If you choose:

- Resize mode: width
- Dimension: 1280
- Output format: empty

The script creates:

- Folder: width_1280
- Outputs: same base filename, original extension

If you choose output format mp4, all outputs in that folder are saved as .mp4.

## Output Naming Behavior

- Source: holiday_clip.mov
- Output folder: height_720
- Output file (keep original format): holiday_clip.mov
- Output file (selected format mp4): holiday_clip.mp4

## FFmpeg Settings Used

The script currently uses:

- Video codec: libx264
- Preset: fast
- CRF: 28
- Audio codec: aac
- Audio bitrate: 128k
- Faststart flag for better streaming playback

You can edit resize.bat if you want a different codec, quality, or bitrate.

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