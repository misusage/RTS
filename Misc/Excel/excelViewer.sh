#!/bin/bash
# Rafa quick script: Open excel spreadsheets in linux command line.

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <excel-file-you-want-to-view>"
	exit 1
fi

if ! [ -x "$(command -v py_xls2html)" ]; then
	echo "Python-excelerator is needed to proceed and is not installed. Installing."
	apt-get install -y -qq python-excelerator w3m
fi

py_xls2html $1 2>/dev/null | sed 's/"//g' | w3m -dump -T 'text/html'
