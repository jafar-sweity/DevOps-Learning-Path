#!/bin/bash
read -p "Enter a filename: " file
if [[ -e "$file" ]]; then
    echo "File exists"
else
    echo "File not found"
fi
