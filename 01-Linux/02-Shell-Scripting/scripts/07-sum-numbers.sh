#!/bin/bash
read -p "Enter numbers separated by space: " -a numbers
sum=0
for n in "${numbers[@]}"; do
    ((sum += n))
done
echo "Sum: $sum"
