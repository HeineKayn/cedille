#!/bin/bash
OK_FOLDER=Tests_ok

for i in `ls $OK_FOLDER`
do
    cat $OK_FOLDER/$i | ./cedille
    echo "$? -0"
done