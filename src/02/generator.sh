#!/bin/bash

date=$(date +"%d%m%y")

function generate() 
{
    local folder_chars=$1
    local full_filename=$2
    local size_with_mb=$3
    
    local file_name=$(echo "$full_filename" | cut -d '.' -f1)
    local file_ext=$(echo "$full_filename" | cut -d '.' -f2)
    local file_size=${size_with_mb%Mb}
    
    local i=1
    
    while true
    do
        check_free_space
        
        local folder=$(generate_name "$folder_chars")
        local directory=$(find_suitable_directory)
        
        if [ -z "$directory" ]; then
            echo "Не найдено подходящей директории" >&2
            break
        fi
        
        let "i++"
        
        if [ $i -gt 100 ]; then
            echo "Достигнуто максимальное количество папок (100)" >&2
            break
        fi
        
        if ! mkdir "$directory/$folder" 2>/dev/null; then
            continue
        fi
        
        local abs_folder_path=$(readlink -f "$directory/$folder")
        echo "$abs_folder_path $date" >> log.txt
        
        local files_count=$(shuf -i 1-100 -n 1)
        
        while [ $files_count -gt 0 ]
        do
            check_free_space
            
            local file=$(generate_name "$file_name")."$file_ext"
            
            if fallocate -l "${file_size}M" "$directory/$folder/$file" 2>/dev/null; then
                local created=$(readlink -f "$directory/$folder/$file")
                echo "$created $date ${file_size}Mb" >> log.txt
            fi
            
            let "files_count--"
        done
    done
}

function check_free_space() {
    local free_space_mb=$(df -k / | awk 'NR==2 {printf "%d", $4/1024}')
    if [ $free_space_mb -le 1024 ]; then
        echo "Ошибка: Осталось менее 1 ГБ свободного места на диске. Прерывание работы." >&2
        exit 1
    fi
}

function get_free_space_mb() {
    df -k / | awk 'NR==2 {printf "%d", $4/1024}'
}

function find_suitable_directory() {
    local safe_dirs=("/tmp" "/var/tmp" "/home" "/usr/local" "/opt")
    
    for dir in "${safe_dirs[@]}"; do
        if [ -d "$dir" ] && [ -w "$dir" ]; then
            echo "$dir"
            return
        fi
    done
    
    find / -type d 2>/dev/null | grep -v -E '(bin|sbin|proc|sys|dev|run)' | head -n 50 | shuf -n1
}

function generate_name {
    local chars="$1"
    local name=""
    local length=${#chars}
    
    for (( i=0; i<length; i++ ))
    do
        if [[ $i -eq 0 ]]
        then 
            char_count=$(( RANDOM % 20 + 5 ))
            name+=$(printf "%-${char_count}s" "" | tr ' ' "${chars:$i:1}")
        else
            char_count=$(( RANDOM % 15 + 1 ))
            name+=$(printf "%-${char_count}s" "" | tr ' ' "${chars:$i:1}")
        fi
    done
    
    if [ ${#name} -lt 5 ]; then
        while [ ${#name} -lt 5 ]; do
            name+="${chars:0:1}"
        done
    fi
    
    echo "${name}_$date"
}