# invoke_image_caption

Script to add caption to image / images using pillow library and .mp4,.mov videos using ffmpeg

## Setup

Steps tested on Macbook only. They may vary on windows or linux. 

```
python3 -m virtualenv venv
source venv/bin/activate
python3 -m pip install -r requirements.txt
deactivate
```

For videos captioning, ensure that `ffmpeg` is also installed

```
# Macbook
brew install ffmpeg
# Linux
apt-get -y install ffmpeg
```

## Usage

To be able to add caption `Test Caption 3` but also include date and name of folder `test` in the caption and remove any HEIC image files: 
```
source venv/bin/activate
python3 main.py -f $(pwd)/test -c "Test Caption3" -cfon -id -ro
deactivate
```

To be able to add caption `Test Caption 3` but also include date and remove any HEIC image files (no parent folder name):
```
source venv/bin/activate
python3 main.py -f $(pwd)/test -c "Test Caption3" -id -ro
deactivate
```
