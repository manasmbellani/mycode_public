#!/usr/bin/env python3

def write_to_file(outfile_path, text):
    """Write the output to file

    Args:
        outfile_path (str): Path to the output file
        text (str): Text to write to file
    """
    with open(outfile_path, "w+") as f:
        f.write(text)
        
