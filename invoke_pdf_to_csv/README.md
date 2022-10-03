# invoke_pdf_to_csv
Script will parse PDF file to text and extract key value pairs from it as describe from 
the regexes specified in a configuration file.

## Setup
Install dependencies
```
python3 -m virtualenv venv
source venv/bin/activate
python3 -m pip install -r requirements.txt
deactivate
```

## Example
Extract keys through defined regexes in file: `conf/conf_template.yaml` from PDF file `in.pdf` as defined in  to `out-pdf.csv` file
```
source venv/bin/activate
python3 main.py -c conf/conf_template.yaml -f ~/Downloads/in.pdf
```