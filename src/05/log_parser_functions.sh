#!/bin/bash

check_log_files() {
    if [ -z "$(ls ../04/nginx_access_*.log 2>/dev/null)" ]
        then
        echo "Ошибка: не найдены файлы логов nginx_access_*.log"
        exit 1
    fi
}

show_sorted_by_status() {
    check_log_files
    awk '{print $9, $0}' ../04/nginx_access_*.log | sort -n | cut -d' ' -f2-
}

show_unique_ips() {
    check_log_files
    awk -F'[ "]' '{print $1}' ../04/nginx_access_*.log | sort -u
}

show_error_requests() {
    check_log_files
    awk '
    {
        status = $9
        if (status >= 400 && status < 600) {
            print $0
        }
    }
    ' ../04/nginx_access_*.log
}

show_unique_error_ips() {
    check_log_files
    awk '
    {
        status = $9
        if (status >= 400 && status < 600) {
            print $1
        }
    }
    ' ../04/nginx_access_*.log | sort -u
}