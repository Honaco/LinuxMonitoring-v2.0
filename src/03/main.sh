#!/bin/bash

source ./uni.sh

if [[ "$#" -ne 1 || ! "$1" =~ ^[1-3]$ ]]
    then
    echo "Ошибка. Должен быть задан ровно один параметр от 1 до 3"
    exit 1
fi

choice="$1"

case "$choice" in
    1) del_by_log ;;
    2) del_by_time ;;
    3) del_by_mask ;;
esac
