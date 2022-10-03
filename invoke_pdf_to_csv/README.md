# invoke_pdf_to_csv
Script will parse PDF file to text and extract key value pairs from it as describe from 
the regexes specified in a configuration file.

## Example
Extract keys from PDF file `in.pdf` as defined in  to `out-pdf.csv` file
```
python3 main.py -c conf/conf_template.yaml -f ~/Downloads/in.pdf
```