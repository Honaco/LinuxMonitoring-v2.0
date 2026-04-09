#!/bin/bash

function check_params() {
    if [ $# -ne 3 ]; then
        echo "Ошибка: Неверное количество параметров." >&2
        exit 1
    fi

    if [ "${#1}" -gt 7 ] || ! [[ $1 =~ ^[a-zA-Z]+$ ]]; then
        echo "Ошибка: Укажите корректный список используемых букв для названий папок" >&2
        exit 1
    fi
    
    withType=$(echo $2 | grep -o '\.')
    name=$(echo $2 | cut -d '.' -f1)
    type=$(echo $2 | cut -d '.' -f2)

    if [ "${#name}" -gt 7 ] || ! [[ $name =~ ^[a-zA-Z]+$ ]] || ! [ "$withType" == "." ]; then
        echo "Ошибка: Укажите корректный список используемых букв для названий файлов" >&2
        exit 1
    fi
    if [ "${#type}" -gt 3 ] || ! [[ $type =~ ^[a-zA-Z]+$ ]] || ! [ "$withType" == "." ]; then
        echo "Ошибка: Укажите корректный список используемых букв для расширения файлов" >&2
        exit 1
    fi

    if ! [[ $3 =~ ^[0-9]+Mb$ ]] || [ ${3::-2} -gt 100 ]; then
        echo "Ошибка: Укажите корректный размер файлов" >&2
        exit 1
    fi

    return 1
}

function check_free_space() {
    local free_space_mb=$(df -k / | awk 'NR==2 {printf "%d", $4/1024}')
    if [ $free_space_mb -le 1024 ]; then
        echo "Ошибка: Осталось менее 1 ГБ свободного места на диске" >&2
        exit 1
    fi
}