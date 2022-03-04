#!/bin/bash
OK_FOLDER=Tests_ok

for i in `ls $OK_FOLDER`
do
    echo "------------------Executing file $i------------------"
    cat $OK_FOLDER/$i | ./cedille >> test_results
    echo "$? -0"
done