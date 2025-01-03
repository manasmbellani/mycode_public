#!/usr/bin/env python3
import argparse
from PIL import Image
import os
import sys

DESCRIPTION="Combine images into a PDF file"

def main():
    parser = argparse.ArgumentParser(description=DESCRIPTION)
    parser.add_argument("-i", "--input-folder", required=True, 
                        help="Folder with input images")
    parser.add_argument("-o", "--output-file", default="combined_images.pdf", 
                        help="File where to store the output")
    args = parser.parse_args()

    print(f"[*] Checking if path: {args.input_folder} is a directory..." )
    if not os.path.isdir(args.input_folder):
        print(f"[-] Path: {args.input_folder} does not exist")
        return 1

    print(f"[*] Deleting the output file: {args.output_file} if it exists...")
    if os.path.isfile(args.output_file):
        os.remove(args.output_file)

    print(f"[*] Reading paths for various images from folder: {args.input_folder}...")
    images_list = []
    for d, _, files in os.walk(args.input_folder):
        for f in files:
            full_path = os.path.join(d, f)
            images_list.append(full_path)

    print(f"[*] Sorting images list by name...")
    images_list.sort()

    print(f"[*] Converting each image to RGB mode...")
    images = []
    for i in images_list:
        try:
            print(f"[*] Converting image: {i} to RGB...")
            images.append(Image.open(i).convert("RGB"))
        except Exception as e:
            print(f"[!] Error converting file: {i} to RGB... is it an image? Ignoring it when combining. Error: {e.__class__}, {e}")
    
    print(f"[*] Saving the images as a single PDF file: {args.output_file}...")
    #for index, im in enumerate(images[1:]):
    #    print(f"[*] Appending image {index+1} to PDF file: {args.output_file}...")
    images[0].save(args.output_file, save_all=True, append_images=images[1:])

if __name__ == "__main__":
    sys.exit(main())
