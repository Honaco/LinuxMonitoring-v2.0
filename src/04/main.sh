#!/bin/bash

# Проверка параметров
if [ $# -ne 0 ]; then
    echo "Ошибка: Скрипт main.sh не принимает параметры" >&2
    exit 1
fi

source ./log_generator.sh

echo "Начало генерации логов nginx"

for day in {1..5}; do
    generate_day_log "$day"
done

echo "Создано 5 файлов логов."