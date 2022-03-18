#!/bin/bash
OK_FOLDER=Tests_ok
ERROR_FILES=()

echo ""
echo "-----------EXECUTING OK TESTS---------"
for i in `ls $OK_FOLDER`
do
    a="--"
    lol=$(cat $OK_FOLDER/$i | ./cedille  2>&1 | grep "syntax error" | wc -l)
    if test $lol -eq 1
    then
        a="KO"
        ERROR_FILES+=($i)
    fi
    echo "$a $i"
done
echo ""
echo "Syntax errors for $OK_FOLDER at : "
for i in ${ERROR_FILES[*]}
do
    echo $i
done
echo ""