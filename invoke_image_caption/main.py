#!/usr/bin/env python3
import argparse
import pillow_heif as pyheif
from datetime import datetime, timezone
import os
import sys

from PIL import Image
from PIL.ExifTags import TAGS
from PIL import Image, ImageDraw, ImageFont

# Datetime format
DATETIME_FORMAT = "%Y-%m-%d"

# Font for caption
FONT = 'arial.ttf'

# Font size
FONT_SIZE = 20

# Margin from which to write text
MARGIN = 20

def get_image_creation_date(image_path):
    """Get the image's creation date given its image path"""
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

def caption_image(image_path, caption, font_type, font_size, heic_extn):
    """Add a caption to the image given caption's font size and caption text"""
    base_path, img_extn = os.path.splitext(image_path)
    if img_extn.lower() == '.heic':
        img_obj = heic_to_pil(image_path)
        image_path = base_path + heic_extn
    else:
        img_obj = Image.open(image_path)

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
    parser = argparse.ArgumentParser(description="Add a caption to the image")
    parser.add_argument("-f", "--file-folder", required=True, 
                        help="Image File / folder with image to caption")
    parser.add_argument("-c", "--caption", default="", help="Caption to apply")
    parser.add_argument("-cfn", "--caption-file-name", action='store_true', help="Caption with file name instead")
    parser.add_argument("-cfon", "--caption-folder-name", action='store_true', help="Caption with folder's name")
    parser.add_argument("-id", "--include-date", action='store_true', help="Include date read from exif data in caption")
    parser.add_argument("-hae", "--heic-alternate-extension", default=".jpeg", 
                            help="Alternate Exentsion if .heic being used")
    parser.add_argument("-edh", "--exif-date-header", default="DateTimeOriginal", 
                        help="Exif header which contains date")
    parser.add_argument("-ft", "--font-type", default=FONT, help="Local Font file")
    parser.add_argument("-fs", "--font-size", default=FONT_SIZE,
                        help="Font size")
    parser.add_argument("-ro", "--remove-heic-original", action='store_true', 
                        help="Whether to delete the original .heic image")
    args = parser.parse_args()
    
    image_files = []

    base_caption = args.caption

    if args.include_date:
        print("[*] Including date in caption...")
        base_caption += " " + datetime.now(tz=timezone.utc).strftime(DATETIME_FORMAT)

    if args.caption_folder_name:
        print("[*] Calculating base caption given args.caption_folder_name is set...")
        parent_folder_name = ""
        if os.path.isfile(args.file_folder):
            parent_folder_name = os.path.basename(os.path.dirname(args.file_folder))    
        elif os.path.isdir(args.file_folder):
            parent_folder_name = os.path.basename(args.file_folder)
        base_caption += " " + parent_folder_name
    
    if os.path.isfile(args.file_folder):
        print(f"[*] Identifying image file: {args.file_folder}...")
        image_files.append(args.file_folder)
        
    elif os.path.isdir(args.file_folder):
        print(f"[*] Identifying image files to caption from folder: {args.file_folder}...")
        for dirpath, __, filenames in os.walk(args.file_folder):
            for f in filenames:
                fp = os.path.join(dirpath, f)
                image_files.append(fp)

    for f in image_files:
        caption = base_caption
        if args.caption_file_name:
            image_name = os.path.basename(f)
            caption += " " + image_name
        
        print(f"[*] Captioning image file: {f} with caption: {caption}...")
        flag_image_captioned = caption_image(f, caption, args.font_type, font_size=int(args.font_size), heic_extn=args.heic_alternate_extension)
        __, img_extn = os.path.splitext(f)
        
        if flag_image_captioned and img_extn.lower() == '.heic' and args.remove_heic_original:
            print(f"[*] Removing original .heic image file: {f}...")
            os.remove(f)


if __name__ == "__main__":
    sys.exit(main())
