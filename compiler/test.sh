#!/bin/bash

for i in `ls Tests_ko`
do
    cat $i | ./cedille
    echo "$? -0"
done