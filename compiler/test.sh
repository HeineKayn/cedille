#!/bin/bash
OK_FOLDER=Tests_ok
ERROR_FILES=()

for i in `ls $OK_FOLDER`
do
    echo "------------------Executing file $i-----------------------"
    lol=$(cat $OK_FOLDER/$i | ./cedille 2>&1 | grep "syntax error" | wc -l)
    if test $lol -eq 1
    then
        ERROR_FILES+=($i)
    fi
done
echo "Syntax errors for $OK_FOLDER at : "
for i in ${ERROR_FILES[*]}
do
    echo $i
done