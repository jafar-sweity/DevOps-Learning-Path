#!/bin/bash
for file in *.txt; do
    lines=$(wc -l < "$file")
    echo "$file : $lines lines"
done
