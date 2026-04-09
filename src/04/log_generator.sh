#!/bin/bash

# Коды ответа HTTP и их значения:
# 200 - OK: Запрос успешно обработан
# 201 - Created: Ресурс успешно создан
# 400 - Bad Request: Неправильный синтаксис запроса
# 401 - Unauthorized: Требуется аутентификация
# 403 - Forbidden: Доступ запрещен
# 404 - Not Found: Ресурс не найден
# 500 - Internal Server Error: Внутренняя ошибка сервера
# 501 - Not Implemented: Метод не поддерживается
# 502 - Bad Gateway: Ошибка шлюза
# 503 - Service Unavailable: Сервис недоступен

# Проверка параметров
if [ $# -ne 0 ]; then
    echo "Ошибка: Скрипт log_generator.sh не принимает параметры" >&2
    exit 1
fi

generate_ip() {
    echo "$((RANDOM%256)).$((RANDOM%256)).$((RANDOM%256)).$((RANDOM%256))"
}

generate_status() {
    local codes=(200 201 400 401 403 404 500 501 502 503)
    echo "${codes[$((RANDOM%${#codes[@]}))]}"
}

generate_method() {
    local methods=("GET" "POST" "PUT" "PATCH" "DELETE")
    echo "${methods[$((RANDOM%${#methods[@]}))]}"
}

generate_url() {
    local paths=("/" "/index.html" "/main.php" "/api/v1/users" "/images/logo.png" 
                 "/documents/report.pdf" "/products" "/categories" "/search" "/login")
    echo "${paths[$((RANDOM%${#paths[@]}))]}"
}

generate_agent() {
    local agents=(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
        "Google Chrome/91.0.4472.124"
        "Opera/9.80 (Windows NT 6.1; Win64; x64)"
        "Safari/537.36"
        "Internet Explorer/11.0"
        "Microsoft Edge/91.0.864.59"
        "Crawler and bot"
        "Library and net tool"
    )
    echo "${agents[$((RANDOM%${#agents[@]}))]}"
}

generate_log_entry() {
    local date="$1"
    local time="$2"
    local ip=$(generate_ip)
    local status=$(generate_status)
    local method=$(generate_method)
    local url=$(generate_url)
    local agent=$(generate_agent)
    local bytes=$((RANDOM%5000 + 500))
    
    echo "$ip - - [$date:$time +0000] \"$method $url HTTP/1.1\" $status $bytes \"-\" \"$agent\""
}

generate_day_log() {
    local day="$1"
    local date=$(date -d "2025-08-$day" +"%d/%b/%Y")
    local log_file="nginx_access_2025-08-$day.log"
    local entries=$((RANDOM%901 + 100))
    echo "Генерация лога за $date ($entries записей) в файл $log_file"
    
    declare -a timestamps
    for ((i=0; i<entries; i++)); do
        hours=$(printf "%02d" $((RANDOM%24)))
        minutes=$(printf "%02d" $((RANDOM%60)))
        seconds=$(printf "%02d" $((RANDOM%60)))
        timestamps[$i]="$hours:$minutes:$seconds"
    done
    
    IFS=$'\n' sorted=($(sort <<<"${timestamps[*]}"))
    unset IFS
    
    for ((i=0; i<entries; i++)); do
        generate_log_entry "$date" "${sorted[$i]}" >> "$log_file"
    done
}