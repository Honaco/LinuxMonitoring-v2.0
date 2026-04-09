function check_free_space {
    local log_file="$1"
    local free_space=$(df / | awk 'NR==2 {print $4}')
    if (( free_space < 1048576 ))
    then
        echo "Ошибка. Недостаточно места на диске" | tee -a "$log_file"
        exit 1
    fi
}