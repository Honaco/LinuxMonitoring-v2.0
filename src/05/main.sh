#!/bin/bash

source ./log_parser_functions.sh

if [ "$#" -ne 1 ]
    then
    echo "Ошибка: скрипт должен быть запущен с одним параметром от 1 до 4"
    exit 1
fi

if [[ ! "$1" =~ ^[1-4]$ ]]
    then
    echo "Ошибка: параметр должен быть числом от 1 до 4"
    exit 1
fi

case $1 in
    1) show_sorted_by_status ;;
    2) show_unique_ips ;;
    3) show_error_requests ;;
    4) show_unique_error_ips ;;
esac
