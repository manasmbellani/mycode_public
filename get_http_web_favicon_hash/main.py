#!/usr/bin/env python3
import argparse
import codecs
import requests

import mmh3

# Relative path where favicon icon is present
FAVICON_PATH = "/favicon.ico"

parser = argparse.ArgumentParser(description="Calculate favicon hash for website")
parser.add_argument("-u", "--url", required=True, 
        help="URL to scan for favicon e.g. https://www.msn.com. Request will be made to https://www.msn.com/favicon.ico")
args = parser.parse_args()
 
print("[*] Building URL to test based on whether favicon relative path is present in url...")
if args.url.endswith("/favicon.ico"):
    url_to_test = args.url
else:
    if args.url.endswith("/"):
        url_to_test = args.url + 'favicon.ico'
    else:
        url_to_test = args.url + '/favicon.ico'


print(f"[*] Testing URL: {url_to_test}...")
response = requests.get(url_to_test, verify=False)
favicon = codecs.encode(response.content,"base64")
hash = mmh3.hash(favicon)
print(hash)
