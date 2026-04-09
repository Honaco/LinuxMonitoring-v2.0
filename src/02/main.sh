#!/bin/bash

START=$(date +%s)

source ./check.sh
source ./generator.sh

check_params $@
echo "Время начала = $START" >> log.txt
echo "Время начала = $START"

generate $1 $2 $3

END=$(date +%s)
DIFF=$(( $END - $START ))

echo "Время окончания = $END" >> log.txt
echo "Общее время выполнения = $DIFF" >> log.txt

echo "Время окончания = $END"
echo "Общее время выполнения = $DIFF"