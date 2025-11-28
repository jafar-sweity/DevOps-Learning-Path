#!/bin/bash
while true; do
    echo "1) Show date"
    echo "2) Show current directory files"
    echo "3) Show disk usage"
    echo "4) Exit"
    read -p "Choose an option: " choice
    case $choice in
        1) date ;;
        2) ls ;;
        3) df -h ;;
        4) exit ;;
        *) echo "Invalid option" ;;
    esac
done

