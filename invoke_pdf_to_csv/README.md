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

## Examples

### Example1 - Single file
Extract keys through defined regexes in file: `conf/conf_template.yaml` from PDF file `in.pdf` as defined in  to `out-pdf.csv` file
```
source venv/bin/activate
python3 main.py -c conf/conf_template.yaml -f ~/Downloads/in.pdf
```

### Example2 - Multiple files
Parse multiple PDF files in `~/Downloads` folder and put csv output files back in the `~/Downloads` folder as follows:
```
source venv/bin/activate
ls -1 ~/Downloads | grep -i pdf | xargs -I ARG /bin/bash -c "python3 main.py -c conf/conf_template.yaml -f ~/Downloads/ARG -o ARG; mv ARG ~/Downloads/ARG.csv"
```
