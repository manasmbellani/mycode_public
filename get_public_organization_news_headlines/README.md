# get_public_organization_news_headlines

Script to parse the information about an organization from various public news sources and identify the latest news headlines

The script calls the public Web URIs for the announcements on various news headlines and uses regex-based `grep` commands to pull the latest news headlines. It keeps track of the previously seen URLs by storing them in a local text and continues to add them to this script

It is assumed that the news sources when queried will only show the latest news articles first

For AFR news, currently only the ASX joined company news is displayed

Currently, the following news sources are supported:

- AFR: https://www.afr.com/companies/all/a
- IT News Australia: https://www.itnews.com.au/

## Setup

No specific setup required except basic dependencies like `curl`

## Usage

First Identify the appropriate IDs for the organization you are interested to get news about by visiting Google and searching for the company 

For `Rio Tinto` as an example, search in google for keywords:

```
AFR "Rio Tinto"
```

The ASX news announcements link should be available at as one of the top searches on AFR website if the company has joined ASX. In this case, the URL displayed is https://www.afr.com/company/asx/rio. The ID is `rio`

For IT News as an example, search in google for keywords:

```
IT News "Rio Tinto"
```

The Tag URL for `IT News` is the appropriate one which in this case is https://www.itnews.com.au/tag/rio-tinto. The ID for IT News is `rio-tinto`

Next, run the following command to get the latest news headlines (shown prefixed with `[+]` on STDOUT).

```
./main.sh "rio" "rio-tinto"
```

Note that only the top headlines (default: 6) are parsed as only the latest news headline is intended to be shown. If we would like to compare more haeadlines and store them in a different output file (default: `out-urls.txt`), then run the following command:

```
./main.sh rio rio-tinto 10 out-urls2.txt
```

