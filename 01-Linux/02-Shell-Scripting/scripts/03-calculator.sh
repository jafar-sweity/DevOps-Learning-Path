#!/bin/bash
read -p "Enter first number: " n1
read -p "Enter operation (+,-,*,/): " op
read -p "Enter second number: " n2

result=0
case $op in
    +) result=$((n1 + n2)) ;;
    -) result=$((n1 - n2)) ;;
    \*) result=$((n1 * n2)) ;;
    /) result=$((n1 / n2)) ;;
    *) echo "Invalid operator"; exit 1 ;;
esac
echo "Result: $result"
