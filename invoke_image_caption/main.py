#!/usr/bin/env python3
import argparse
from datetime import datetime, timezone
import os
import re
import shutil
import subprocess
import sys
import tempfile

import pillow_heif as pyheif

from PIL import Image
from PIL.ExifTags import TAGS
from PIL import Image, ImageDraw, ImageFont

# Datetime format
DATETIME_FORMAT = "%Y-%m-%d"

# Font for caption
FONT = 'arial.ttf'

# Font size
FONT_SIZE = 20

# Height to font size ratio
HEIGHT_FONT_SIZE_RATIO = 25

# Margin from which to write text
MARGIN = 20

# Video extensions that FFMPEG can operate on
VIDEO_EXTENSIONS = [".mp4", ".avi", ".mov", ".mkv", ".flv"]

# FFMPEG video size regex pattern
FFMPEG_VIDEO_SIZE_PATTERN = "[0-9]+x[0-9]+,"

class CustomFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawTextHelpFormatter):
    pass

def get_image_creation_date(image_path):
    """Get the image's creation date given its image path"""
    if sys.platform.lower() == 'darwin': 
        # Macbook
        creation_time = os.stat(image_path).st_birthtime
    else:
        creation_time = os.path.getctime(image_path)
    utc_time = datetime.fromtimestamp(creation_time, tz=timezone.utc)
    return utc_time.strftime(DATETIME_FORMAT)
    
def heic_to_pil(image_path):
    """Convert .HEIC to .PIL for processing"""
    heif_file = pyheif.open_heif(image_path)
    image = Image.frombytes(
        heif_file.mode, 
        heif_file.size, 
        heif_file.data,
        "raw",
        heif_file.mode,
        heif_file.stride,
    )
    return image

def get_video_frame_height(video_path, ffmpeg_path):
    """Get the height of the frame in video"""
    cmd = [ffmpeg_path, "-i", video_path, "-vf", "showinfo", "-f", "null", "-"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    for line in result.stderr.split("\n"):
        if "Video:" in line:
            m = re.search(FFMPEG_VIDEO_SIZE_PATTERN, line)
            if m:
                video_height = (m[0].split('x'))[0].replace(",", "")
                return int(video_height)

def caption_video(input_video_path, ffmpeg_path, caption, font_size=None):
    """Caption the video given the type of font and optionally size"""
    if os.path.isfile(ffmpeg_path):

        # Get the extension for the video as required for output
        __, video_extn = os.path.splitext(input_video_path)

        # Calculate the x,y coordinates of the text
        height = get_video_frame_height(input_video_path, ffmpeg_path)

        if not font_size:
            font_size = int(height / HEIGHT_FONT_SIZE_RATIO)

        margin = MARGIN
        x = margin
        y = height - font_size - margin

        tmpfile = tempfile.mktemp() + video_extn
        ffmpeg_cmd = [
            "ffmpeg",
            "-i", input_video_path,        # Input video file
            "-vf", f"drawtext=text='{caption}':x={x}:y={y}:fontcolor=white:fontsize={font_size}",
            "-c:v", "libx264",        # Video codec
            "-c:a", "copy",           # Keep audio unchanged
            tmpfile
        ]
        print(f"[*] Executing ffmpeg command: {ffmpeg_cmd}...")
        subprocess.run(ffmpeg_cmd)
        shutil.move(tmpfile, input_video_path)
        return True
    else:
        print(f"[!] Skipping caption for file: {input_video_path} as ffmpeg path: {ffmpeg_path} bin not found")

def caption_image(image_path, caption, font_type, heic_extn, font_size=None):
    """Add a caption to the image given caption's font size and caption text"""
    base_path, img_extn = os.path.splitext(image_path)
    if img_extn.lower() == '.heic':
        img_obj = heic_to_pil(image_path)
        image_path = base_path + heic_extn
    else:
        img_obj = Image.open(image_path)

    if not font_size:
        __, height = img_obj.size
        font_size = int(height / HEIGHT_FONT_SIZE_RATIO)

    return caption_image_obj(img_obj, image_path, caption, font_type, font_size)

def caption_image_obj(image_file_obj, image_path, caption, font_type, font_size):
    """Add caption to the image"""
    #with Image.open(image_file) as img:
    __, height = image_file_obj.size

    draw = ImageDraw.Draw(image_file_obj)

    # Specify the font, size, and color
    font = ImageFont.truetype(font_type, font_size)
    __, __, __, textheight = draw.textbbox((500, 0), text=caption, font=font)
    
    # Calculate the x,y coordinates of the text
    margin = MARGIN
    x = margin
    y = height - textheight - margin

    # Draw the text on the image
    draw.text((x, y), caption, font=font, fill="white")
    print(f"[*] Saving updated image: {image_path}")
    image_file_obj.save(image_path)
    return True


def main():
    parser = argparse.ArgumentParser(description="Add a caption to the image", 
                                    formatter_class=CustomFormatter)
    parser.add_argument("-f", "--file-folder", required=True, 
                        help="Image File / folder with image to caption")
    parser.add_argument("-efe", "--exclude-file-extensions", default=".mp3,.zip,.DS_Store", 
                        help="Comma-separated list of file extensions to exclude")
    parser.add_argument("-c", "--caption", default="", help="Caption to apply")
    parser.add_argument("-cfn", "--caption-file-name", action='store_true', help="Caption with file name instead")
    parser.add_argument("-cfon", "--caption-folder-name", action='store_true', help="Caption with folder's name")
    parser.add_argument("-id", "--include-date", action='store_true', help="Include date read from exif data in caption")
    parser.add_argument("-hae", "--heic-alternate-extension", default=".jpeg", 
                            help="Alternate Exentsion if .heic being used")
    parser.add_argument("-edh", "--exif-date-header", default="DateTimeOriginal", 
                        help="Exif header which contains date")
    parser.add_argument("-ft", "--font-type", default=FONT, help="Local Font file")
    parser.add_argument("-fs", "--font-size", help=f"Font size(eg. {FONT_SIZE}). If unset, defaults to /{HEIGHT_FONT_SIZE_RATIO} of image height")
    parser.add_argument("-ro", "--remove-heic-original", action='store_true', 
                        help="Whether to delete the original .heic image")
    parser.add_argument("-ff", "--ffmpeg-path", default="/usr/local/bin/ffmpeg", 
                        help="Path to local ffmpeg binary. Checked before operating on videos.")
    args = parser.parse_args()
    
    image_files = []

    base_caption = args.caption

    if args.caption_folder_name:
        print("[*] Calculating base caption given args.caption_folder_name is set...")
        parent_folder_name = ""
        if os.path.isfile(args.file_folder):
            parent_folder_name = os.path.basename(os.path.dirname(args.file_folder))    
        elif os.path.isdir(args.file_folder):
            parent_folder_name = os.path.basename(args.file_folder)
        base_caption += " " + parent_folder_name
    
    if os.path.isfile(args.file_folder):
        print(f"[*] Identifying file: {args.file_folder}...")
        image_files.append(args.file_folder)
        
    elif os.path.isdir(args.file_folder):
        print(f"[*] Identifying files to caption from folder: {args.file_folder}...")
        for dirpath, __, filenames in os.walk(args.file_folder):
            for f in filenames:
                fp = os.path.join(dirpath, f)
                image_files.append(fp)

    font_size = None
    if args.font_size:
        print(f"[*] Setting font size: {int(args.font_size)}")
        font_size = int(args.font_size)

    for f in image_files:
        
        __, file_extn = os.path.splitext(f)
        if file_extn not in args.exclude_file_extensions.split(","):

            caption = base_caption

            if args.caption_file_name:
                image_name = os.path.basename(f)
                caption += " " + image_name
            
            if args.include_date:
                creation_date = get_image_creation_date(f)
                caption =  creation_date + " " + caption
            
            try:
                if file_extn in VIDEO_EXTENSIONS:
                    print(f"[*] Captioning video file: {f} with caption: {caption}...")
                    flag_video_captioned = caption_video(f, args.ffmpeg_path, caption, 
                                                        font_size=font_size)
                else:

                    print(f"[*] Captioning image file: {f} with caption: {caption}...")
                    flag_image_captioned = caption_image(f, caption, 
                                                        args.font_type, heic_extn=args.heic_alternate_extension, 
                                                        font_size=font_size)
                    if flag_image_captioned and file_extn.lower() == '.heic' and args.remove_heic_original:
                        print(f"[*] Removing original .heic image file: {f}...")
                        os.remove(f)
            except Exception as e:
                print(f"[!] Error captioning file: {f}. Error: {e.__class__}, {e}")
            
        else:
            print(f"[!] Skipping f: {f}")


if __name__ == "__main__":
    sys.exit(main())
