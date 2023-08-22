# get_http_web_favicon_hash
Get the Favicon hash for a website =

## Setup

```
python3 -m virtualenv venv
source venv/bin/activate
python3 -m pip install -r requirements.txt
deactivate
```


## Usage

To get the favicon hash for `https://www.google.com`, assuming favicon hash located at `https://www.google.com/favicon.ico`, run the following commands:
```
source venv/bin/activate
python3 main.py -u https://www.google.com
deactivate
```