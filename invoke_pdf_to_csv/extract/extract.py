#!/usr/bin/env python3
import re

def extract_regex(regex, text):
    """Extract text via regex (which consists of relevant captures) from text 
    content

    Args:
        regexes (str): Content to extract
        text (str): Text to parse

    Returns:
        list: Content extracted given the regex
    """
    matches_list = []
    matches = re.finditer(regex, text, re.M|re.I)
    for match in matches:
        matches_list.append(match.groupdict())
    return matches_list

def flatten_as_csv(matches, quote='"', delimiter=","):
    """Flatten matches that were found via extract_regex by finding 
    unique fields and then get the conte

    Args:
        matches (list): List of matches which contains the relevant values
        quote (str, optional): Quote to use around field values. Default to '"'
        delimiter (str, optional): Delimiter to use for field values. Default to ','
    
    Returns:
        str: Text Content
    """
    # First find the unique set of keys
    keys = []
    csv_content = ''
    for m in matches:
        m_keys =list(m.keys())
        for k in m_keys:
            if k not in keys:
                keys.append(k)

    # Write the heading
    csv_content += delimiter.join( [ quote + k + quote for k in keys ] ) + "\n"
    
    for m in matches:
        # Now write the CSV content each match line
        csv_content += delimiter.join( [ quote + m.get(k, '') + quote for k in keys] ) + "\n"
    return csv_content
