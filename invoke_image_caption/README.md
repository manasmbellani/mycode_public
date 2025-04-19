# invoke_image_caption

Script to add caption to image / images

## Setup

Steps tested on Macbook only. They may vary on windows or linux. 

```
python3 -m virtualenv venv
source venv/bin/activate
python3 -m pip install -r requirements.txt
deactivate
```

## Usage

To be able to add caption `Test Caption 3` but also include date and name of folder `test` in the caption: 
```
source venv/bin/activate
python3 main.py -f $(pwd)/test -c "Test Caption3" -cfon -id
deactivate
```