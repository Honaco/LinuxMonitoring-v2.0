#!/bin/bash

source ./check.sh
source ./generator.sh

function is_number {
    [[ "$1" =~ ^[0-9]+$ ]]
}

function is_letters {
    [[ "$1" =~ ^[a-zA-Z]+$ ]]
}

function is_valid_file_chars {
    [[ "$1" =~ ^[a-zA-Z]{1,7}\.[a-zA-Z]{1,3}$ ]]
}

function is_valid_file_size {
    [[ "$1" =~ ^[0-9]+kb$ ]] && [[ "${1%kb}" -ge 1 ]] && [[ "${1%kb}" -le 100 ]]
}

if [[ "$#" -ne 6 ]]
then
    echo "Ошибка: Скрипт требует 6 параметров!" >&2
    echo "Пример использования: $0 /opt/test 4 az 5 az.az 3kb" >&2
    exit 1
fi

DIR="$1"
FOLDERS="$2"
FOLDER_CHARS="$3"
FILES="$4"
FILE_CHARS="$5"
FILE_SIZE="$6"

if [[ "$DIR" != /* ]]
then
    echo "Ошибка: Параметр 1 должен быть абсолютным путем, начинающимся с '/'" >&2
    exit 1
fi

if ! is_number "$FOLDERS"
then
    echo "Ошибка: Параметр 2 должен быть числом (количество папок)" >&2
    exit 1
fi

if ! is_letters "$FOLDER_CHARS" || [[ ${#FOLDER_CHARS} -lt 1 ]] || [[ ${#FOLDER_CHARS} -gt 7 ]]
then
    echo "Ошибка: Параметр 3 должен содержать только буквы (1-7 символов)" >&2
    exit 1
fi

if ! is_number "$FILES"
then
    echo "Ошибка: Параметр 4 должен быть числом (количество файлов)" >&2
    exit 1
fi

if ! is_valid_file_chars "$FILE_CHARS"
then
    echo "Ошибка: Параметр 5 должен быть в формате 'имя.расширение'" >&2
    echo "Имя: 1-7 букв, расширение: 1-3 буквы (например: az.az, test.txt)" >&2
    exit 1
fi

if ! is_valid_file_size "$FILE_SIZE"
then
    echo "Ошибка: Параметр 6 должен быть в формате 'Nkb' (1-100kb)" >&2
    echo "Пример: 3kb, 50kb, 100kb" >&2
    exit 1
fi

mkdir -p "$DIR"
if [[ $? -ne 0 ]]
then
    echo "Ошибка: Не удалось создать директорию $DIR" >&2
    exit 1
fi

LOG_FILE="$DIR/file_generator_$(date +'%Y%m%d_%H%M%S').log"
touch "$LOG_FILE"

echo "Начало работы скрипта $(date +'%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "Параметры: $@" >> "$LOG_FILE"

FILE_NAME_CHARS="${FILE_CHARS%.*}"
FILE_EXT_CHARS="${FILE_CHARS#*.}"

for (( folder_index=0; folder_index<FOLDERS; folder_index++ ))
do
    check_free_space "$LOG_FILE"
    
    folder_name=$(generate_name "$FOLDER_CHARS")
    folder_path="$DIR/$folder_name"
    mkdir -p "$folder_path"
    echo "Создана папка: $folder_path, $(date)" >> "$LOG_FILE"
    
    for (( i=0; i<FILES; i++ ))
    do
        check_free_space "$LOG_FILE"
            
        attempt_counter=0
        max_attempts=50
        
        while [[ $attempt_counter -lt $max_attempts ]]
        do
            file_name_part=$(generate_name "$FILE_NAME_CHARS")
            file_name="${file_name_part}.${FILE_EXT_CHARS}"
            file_path="$folder_path/$file_name"
            
            if [[ ! -e "$file_path" ]]
            then
                break
            fi
            attempt_counter=$((attempt_counter + 1))
        done
        
        if [[ $attempt_counter -eq $max_attempts ]]
        then
            echo "Предупреждение: Не удалось создать уникальное имя файла после $max_attempts попыток" >> "$LOG_FILE"
            continue
        fi
        
        if dd if=/dev/zero of="$file_path" bs=1K count="${FILE_SIZE%kb}" status=none 2>/dev/null
        then
            file_size=$(du -b "$file_path" | cut -f1)
            echo "Создан файл: $file_path, размер: ${FILE_SIZE%kb}KB ($file_size байт), $(date)" >> "$LOG_FILE"
        else
            echo "Ошибка создания файла $file_path" >> "$LOG_FILE"
        fi
    done
done

echo "=== Работа скрипта завершена $(date +'%Y-%m-%d %H:%M:%S') ===" >> "$LOG_FILE"
echo "Лог успешно сохранен в: $LOG_FILE"
exit 0