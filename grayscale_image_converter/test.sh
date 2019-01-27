#!/bin/bash

file_name="duck.ppm"
rm "result.pgm" >/dev/null 2>&1

./convert >/dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "No argument. Test FAILED"
else
    echo "No argument. Test PASSSED"
fi


./convert dummy >/dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Invalid file. Test FAILED"
else
    echo "Invalid file. Test PASSSED"
fi


./convert duck.ppm >/dev/null 2>&1

if [ $? -eq 0 ]; then
    if [  -f "result.pgm" ]; then
        echo "Correct file. Test PASSSED"
        exit 0
    fi
fi
echo "Correct file. Test FAILED"