function generate_name {
    local chars="$1"
    local current_date=$(date +"%d%m%y")
    local name=""
    local length=${#chars}
    
    for (( i=0; i<length; i++ ))
    do
        if [[ $i -eq 0 ]]
        then 
            char_count=$(( RANDOM % 20 + 3 ))
            for (( j=0; j<char_count; j++ ))
            do
                name+="${chars:$i:1}"
            done
        else
            char_count=$(( RANDOM % 15 + 1 ))
            for (( j=0; j<char_count; j++ ))
            do
                name+="${chars:$i:1}"
            done
        fi
    done

    if [[ ${#name} -lt 4 ]]
    then
        while [[ ${#name} -lt 4 ]]
        do
            name+="${chars:0:1}"
        done
    fi
    
    echo "${name}_$current_date"
}