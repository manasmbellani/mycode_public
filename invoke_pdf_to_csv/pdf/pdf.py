#!/usr/bin/env python3
import PyPDF2
from messages import messages as m

def parse_pdf_to_text(filepath, page_num=None, delim="\n\n\n"):
    """Converts specified PDF file path to text

    Args:
        filepath (str): Filepath to PDF file to parse
        page_num (str, optional): Specific page to extract which if not specified 
        gets all the pages and concatenates the text separated by specified delim. 
        Defaults to None.
        delim(str, optional): Delimiter to use between text. Defaults to '\n\n\n'

    Returns:
        str: PDF file text contents
    """
    pdf_text = ""

    m.verbose(f"Opening PDF file: {filepath} for parsing...")
    with open(filepath, 'rb') as f:
        pdfReader = PyPDF2.PdfFileReader(f)
        m.verbose(f"Number of pages: {pdfReader.numPages}")

        page_nums_to_parse = []
        if page_num:
            if page_num <= pdfReader.numPages:
                m.verbose(f"Appending page: {page_num} to parse...")
                page_nums_to_parse.append(page_num)
        else:
            page_nums_to_parse = range(0, pdfReader.numPages)

        for p in page_nums_to_parse:
            m.verbose(f"Parsing page: {p}...")
            pdf_obj = pdfReader.getPage(p)
            pdf_text += pdf_obj.extractText() + delim

    return pdf_text