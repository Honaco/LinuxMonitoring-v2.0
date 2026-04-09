#!/bin/bash

LOG_DIR="../04"
OUTPUT_DIR="./reports"
CONFIG_FILE="config.conf"

mkdir -p $OUTPUT_DIR

for log in $LOG_DIR/nginx_access_2025-08-*.log; do
    filename=$(basename $log)
    goaccess $log \
        -p $CONFIG_FILE \
        -o $OUTPUT_DIR/${filename%.*}.html \
        --log-format=COMBINED
done

goaccess $LOG_DIR/nginx_access_*.log \
    -p $CONFIG_FILE \
    -o $OUTPUT_DIR/full_report.html \
    --log-format=COMBINED

