#!/usr/bin/env python3
import argparse
import json
import os
import requests
import sys
import time

BING_SEARCH_ENDPOINT = "https://api.bing.microsoft.com"

class CustomFormatter(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass

def main():
    parser = argparse.ArgumentParser(description="To perform a pbing search", formatter_class=CustomFormatter)
    parser.add_argument("-k", "--key", required=True, help="subscription key")
    parser.add_argument("-q", "--query", required=True, help="search query to run")
    parser.add_argument("-l", "--limit", default=0, help="number of results to limit if set >0")
    parser.add_argument("-c", "--count", default=50, help="Count of results to display")
    parser.add_argument("-f", "--offset", default=0, help="Start at custom offset")
    parser.add_argument("-t", "--sleep-time", default=1, help="Sleep time between requests")
    parser.add_argument("-o", "--out-file", default="out-results.json", help="Output file")
    args = parser.parse_args()

    endpoint = BING_SEARCH_ENDPOINT + "/v7.0/search"

    count = int(args.count)
    sleep_time = int(args.sleep_time)
    limit = int(args.limit)

    # Remove the existing output file
    if os.path.isfile(args.out_file):
        os.remove(args.out_file)

    done = False
    offset = int(args.offset)
    resp_json = {}
    while not done:
        try:
            print(f"[*] Making request for query: {args.query} with offset: {offset}, count: {count}...")
            params = {'q': args.query, 'mkt': 'en-US', 'count': count, 'offset': offset, 
                    'answerCount': count}
            headers = {'Ocp-Apim-Subscription-Key': args.key}
            
            response = requests.get(endpoint, headers=headers, params=params)
            if response.status_code == 200:

                print(f"[*] Parsing page for query: {args.query} with offset: {offset}, count: {count}...")
                resp_json = response.json()
                total_results = resp_json['webPages']['totalEstimatedMatches']
                
                with open(args.out_file, "a+") as f:
                    for webpage in resp_json['webPages']['value']:
                        f.write(json.dumps(webpage, indent=4))
                        f.write("\n")

                print(offset, count, total_results)
                if offset + count > total_results or (limit > 0 and offset + count > limit):
                    done = True
                else:
                    offset += count
            else:
                print(f'[-] Error retrieving results for for query: {args.query} with offset: {offset}, count: {count}')
                print(f'[-] Code: {response.status_code}, Raw: {response.text}')
        except Exception as ex:
            print(f'[-] Exception retrieving results for query: {args.query} with offset: {offset}, count: {count}')
            print(f'[-] Error: {ex.__class__}, {ex}')
            print(json.dumps(resp_json, indent=4))
        
        time.sleep(sleep_time)

if __name__ == "__main__":
    sys.exit(main())