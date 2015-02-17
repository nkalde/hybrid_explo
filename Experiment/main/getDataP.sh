#!/bin/bash
dirDataO=$PWD/Experiment/data_*
dirDataT=$PWD/Experiment/data
echo from : $dirDataO
echo to : $dirDataT

if [ -d "$dirDataT" ]; then
	rm -r $dirDataT
fi
mkdir $dirDataT

#renaming and formating	
shopt -s nullglob
for dir	in `ls -d $dirDataO`;
do
	echo $dir
	shopt -s nullglob
	for file in $dir/test_*.txt;
	do
		filename=$(basename "$file")
		newfilename=$(echo "$filename" | sed 's/[a-z]*_\([a-zA-Z]*\).ttt_[a-z0-9]*\(_[a-z0-9,.]*\)\([a-zA-Z_]*\).*/\1\2\3.dat/')
		echo "$filename --> $newfilename"
		newfile=$dirDataT/$newfilename
		cat $file | tr , . | tr '\t' ' ' | sort -nk 11 | sed 's/Explorer#0/2/' | sed 's/Explorer/1/' >> $newfile
	done
done	




