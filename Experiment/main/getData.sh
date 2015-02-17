#!/bin/bash

dirDataO=$PWD/Core/monitoring/data
dirDataT=$PWD/Experiment/data

echo from : $dirDataO 
echo to : $dirDataT

if [ -d "$dirDataT" ]; then
	rm -r $dirDataT
fi
mkdir $dirDataT
#cp $dirDataO/* $dirDataTmkdir data 

#renaming and formating			
for file in $dirDataO/test_*.txt;
do
	filename=$(basename "$file")
	newfilename=$(echo "$filename" | sed 's/[a-z]*_\([a-zA-Z]*\).ttt_[a-z0-9]*\(_[a-z0-9,]*\)\([a-zA-Z_]*\).*/\1\2\3.dat/')
	echo "$filename --> $newfilename"
	newfile=$dirDataT/$newfilename
	cat $file | tr , . | tr '\t' ' ' | sort -nk 11 | sed 's/Explorer#0/2/' | sed 's/Explorer/1/' > $newfile
done	




