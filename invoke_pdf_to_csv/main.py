#!/usr/bin/env python3
import argparse
import os
import sys
import yaml

from pdf import pdf
from extract import extract
from outfile import outfile

from messages import messages as m

class CustomFormatter(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass

DESCRIPTION = """
Script to parse the PDF to text file and optionally extract regex content from file
"""
def main():
    parser = argparse.ArgumentParser(description=DESCRIPTION,
        formatter_class=CustomFormatter)
    parser.add_argument("-f", "--file", required=True, help="Input PDF File")
    parser.add_argument("-c", "--config-file", default="./conf/in-conf.yaml", 
        help="Config file with various regexes and filters to read")
    parser.add_argument("-o", "--outfile", default="out-pdf.csv", 
        help="Output file")
    args = parser.parse_args()

    m.verbose(f"Checking if config file: {args.config_file} exists...")
    if not os.path.isfile(args.config_file):
        m.error(f"File: {args.config_file} not found")

    m.verbose(f"Reading config file: {args.config_file}...")
    with open(args.config_file, "r+") as f:
        config = yaml.safe_load(f.read())

    m.verbose(f"Extracting regexes from config file: {args.config_file}...")
    regexes = config.get('regexes', [])

    m.verbose(f"Parsing text from file: {args.file}...")
    pdf_text = pdf.parse_pdf_to_text(args.file)
    m.verbose(f"Number of regexes: {len(regexes)}...")

    all_matches = []

    for regex in regexes:
        m.verbose(f"Parsing regex: {regex} from file: {args.file}...")
        matches = extract.extract_regex(regex, pdf_text)
        num_matches = len(matches)
        m.verbose(f"Number of matches: {num_matches} for regex: {regex}")
        
        all_matches.extend(matches)

    m.verbose(f"Flattening content...")
    csv_content = extract.flatten_as_csv(all_matches)
    
    m.verbose(f"Writing to outfile: {args.outfile}")
    with open(args.outfile, "w+") as f:
        f.write(csv_content)

if __name__ == "__main__":
    sys.exit(main())
