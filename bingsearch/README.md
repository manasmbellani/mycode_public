# bingsearch

Simple script to run a search and retrieve the webPages results from the [Bing Search v7 API](https://learn.microsoft.com/en-us/rest/api/cognitiveservices-bingsearch/bing-web-api-v7-reference#query-parameters)

## Setup

This requires the subscription to the Azure Portal. Once Azure Portal is accessible, a Bing Resource must be setup, and a new `Bing Search` added under that resource.

Then access the `Keys and Endpoint` section of the new `Bing Search` resource to access one of the keys

To setup the script run the following to install the dependencies
```
python3 -m pip install -r requirements.txt
```

## Usage

To use the script to run the search for keyword `Microsoft`, run the command replacing the `$SUBSCRIPTION_KEY`:
```
python3 main.py -q Microsoft -k $SUBSCRIPTION_KEY
```

Similarly, execute the following command to limit the number of results to just `50``:
```
python3 main.py -q Microsoft -k $SUBSCRIPTION_KEY -l 50
```

To change the page size (as large number of results are returned in chunks), use `-c`
```
python3 main.py -q Microsoft -k $SUBSCRIPTION_KEY -c 50
```

To commence at a particular offset, use `-f` (aka start at result no. `251`): 
```
python3 main.py -q Microsoft -k $SUBSCRIPTION_KEY -f 251
```

