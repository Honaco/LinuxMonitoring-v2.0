#!/bin/bash

function del_by_log {
   export TMPDIR="/var/tmp"
   local LOG_FILE="../02/log.txt"
   
   if [[ ! -f "$LOG_FILE" ]]; then
      echo "Ошибка. Лог файл $LOG_FILE не найден"
      return 1
   fi

   echo "Используется лог-файл: $LOG_FILE"
   
   grep "\." "$LOG_FILE" | while IFS= read -r line; do
      file_path=$(echo "$line" | awk '{print $1}')
      if [[ -f "$file_path" && -w "$file_path" ]]; then
         rm -f "$file_path"
         echo "Удален файл: $file_path"
      fi
   done

   grep -v "\." "$LOG_FILE" | tac | while IFS= read -r line; do
      folder_path=$(echo "$line" | awk '{print $1}')
      if [[ -d "$folder_path" && -w "$(dirname "$folder_path")" ]]; then
         rm -rf "$folder_path" 2>/dev/null
         echo "Удалена папка: $folder_path"
      fi
   done

   echo "Очистка завершена."
   return 0
}

function del_by_time {
    echo "Введите начало периода в формате YYYY-MM-DD HH:MM:SS:"
    read start_time

    echo "Введите конец периода в формате YYYY-MM-DD HH:MM:SS:"
    read end_time

    sudo find / \
        -path "/proc" -prune -o \
        -path "/sys" -prune -o \
        -path "/dev" -prune -o \
        -path "/run" -prune -o \
        -path "/bin" -prune -o \
        -path "/boot" -prune -o \
        -path "/etc" -prune -o \
        -path "/lib" -prune -o \
        -path "/lib32" -prune -o \
        -path "/lib64" -prune -o \
        -path "/usr" -prune -o \
        -path "/var" -prune -o \
        -path "/sbin" -prune -o \
        -type f -newermt "$start_time" ! -newermt "$end_time" \
        -exec echo "Удален файл: {}" \; -exec rm -f {} +

     sudo find / \
        -path "/proc" -prune -o \
        -path "/sys" -prune -o \
        -path "/dev" -prune -o \
        -path "/run" -prune -o \
        -path "/bin" -prune -o \
        -path "/boot" -prune -o \
        -path "/etc" -prune -o \
        -path "/lib" -prune -o \
        -path "/lib32" -prune -o \
        -path "/lib64" -prune -o \
        -path "/usr" -prune -o \
        -path "/var" -prune -o \
        -path "/sbin" -prune -o \
        -type d -newermt "$start_time" ! -newermt "$end_time" \
        -exec echo "Удалена папка: {}" \; -exec rm -rf {} +

     echo "Очистка завершена."
}

function del_by_mask {
    echo "Введите маску имени (например, abc_17062023):"
    read mask

    if [[ ! "$mask" =~ ^[a-zA-Z]+_[0-9]{6,8}$ ]]; then
        echo "Ошибка. Неверный формат маски. Должно быть: символы_дата"
        return 1
    fi

    exec 2> >(grep -v 'Operation not permitted\|Permission denied' >&2)

    sudo find / \
        -path "/proc" -prune -o \
        -path "/sys" -prune -o \
        -path "/dev" -prune -o \
        -path "/run" -prune -o \
        -path "/bin" -prune -o \
        -path "/boot" -prune -o \
        -path "/etc" -prune -o \
        -path "/lib" -prune -o \
        -path "/lib32" -prune -o \
        -path "/lib64" -prune -o \
        -path "/usr" -prune -o \
        -path "/var" -prune -o \
        -path "/sbin" -prune -o \
        -path "/media/*" -prune -o \
        -type f -name "*${mask}*" \
        -exec echo "Удаление файла: {}" \; -exec rm -f {} + 2>/dev/null

    sudo find / \
        -path "/proc" -prune -o \
        -path "/sys" -prune -o \
        -path "/dev" -prune -o \
        -path "/run" -prune -o \
        -path "/bin" -prune -o \
        -path "/boot" -prune -o \
        -path "/etc" -prune -o \
        -path "/lib" -prune -o \
        -path "/lib32" -prune -o \
        -path "/lib64" -prune -o \
        -path "/usr" -prune -o \
        -path "/var" -prune -o \
        -path "/sbin" -prune -o \
        -path "/media/*" -prune -o \
        -type d -name "*${mask}*" \
        -exec echo "Удаление папки: {}" \; -exec rm -rf {} + 2>/dev/null

    echo "Очистка завершена."
    exec 2>&1
}
