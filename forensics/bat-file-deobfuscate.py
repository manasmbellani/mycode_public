#!/usr/bin/env python3
import argparse
import re
import os
import sys

EV_INDEXED_REGEX="%{key}:~[0-9]+,[0-9]+%,?"
EV_INDEXED_INDEX_NUM_CHARS_REGEX="%{key}:~(?P<index>[0-9]+),(?P<num_chars>[0-9]+)%,?"

DESCRIPTION="""
Summary:
    An automated deobfsucator for Windows bat/batch files. Output is written to 
    STDOUT.

Methods:
    ev_indexed: The beginning of the batch script contains a set of environment vars, 
    and subsequent lines contains obfuscated code which is indexing into the 
    environment var values.
    
Example Malware dcoded in the past:
    ev_indexed: SHA256: e523b1c3486bd9353c85d9699e5d35788dae77cbe6d3fc0fcb68cdb7fe654c27
"""
parser = argparse.ArgumentParser(description=DESCRIPTION, formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument("-f", "--file", required=True, help="Batch file to parse")
parser.add_argument("-m", "--method", default="ev_indexed", help="Method to use for decoding")
args = parser.parse_args()
file = args.file
method = args.method

print(f"[*] Checking if file: {file} exists")
if not os.path.isfile(file):
    print(f"[-] File: {file} not found")
    sys.exit(1)
    
print(f"[*] Reading file: {file}")
lines = []
with open(file, "r+") as f:
    lines = f.readlines()

# Key value store
kvs = {}

print(f"[*] Parsing file: {file} line-by-line")
for l in lines:
    li = l.strip()
    
    if method == "ev_indexed":
        # Found a line that sets environment variable
        if li.startswith("set ") and "=" in li:
            # Parse the key value pairs 
            _, _, kv = li.partition(" ")
            key = kv.split("=")[0]
            value = kv.split("=")[1]
            kvs[key] = value
            #print(f"[*] Found key: {key}, value: {value}")
        elif "%" in li and "~" in li:
            # Replace indexed value for each matching key to deobfuscate each
            # entry in the batch file
            li_new = li
            for key, value in kvs.items():
                regex = EV_INDEXED_REGEX.replace("{key}", key)
                occurrences = re.findall(regex, li)
                for o in occurrences:
                    regex = EV_INDEXED_INDEX_NUM_CHARS_REGEX.replace("{key}", key)
                    m = re.search(regex, o)
                    index = int(m.group('index'))
                    
                    num_chars = int(m.group('num_chars'))
                    content = value[index : index+num_chars]
                    #print(f"key, o, index, content: {key}, {o}, {index}, {content}")
                    li_new = li_new.replace(o, content)
                    
            print(li_new)
        else:
            print(li)