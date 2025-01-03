# invoke_images_to_pdf_combine

Script to combine a set of image files into a PDF from a folder. 

If the folder contains any file that is not an image eg jpg, png, etc. then a warning is shown but the combining process continues.

Images are combined in the PDF in the ascending order of the image file names. So files which come first alphabetically will appear first in combined PDF.

## Setup

```
# To install necessary libraries such as Pillow for Image processing
cd /opt/mycode_public/invoke_images_to_pdf_combine
python3 -m virtualenv venv
source venv/bin/activate
python3 -m pip install -r requirements.txt
deactivate
```

## Usage

To combine images in a folder `/tmp/folder_with_images` to a PDF file `/tmp/output.pdf`, run the following command:
```
cd /opt/mycode_public/invoke_images_to_pdf_combine
source venv/bin/activate
python3 main.py -i /tmp/folder_with_images -o /tmp/output.pdf
deactivate
```
