#!/bin/bash

dirData=$PWD/Experiment/data

#r pass statistical mean sd min max
for file in $dirData/*.dat;
do
	filename=$(basename "$file")
	echo from : $dirData
	echo to : $dirData
	
	echo $filename "-->" $filename.r
	$PWD/Experiment/main/stat.r $file
done	

#sort alpha sigma
for file in $dirData/*.dat.r;
do
	filename=$(basename "$file")
	sort $file -k1,2n -o $file
done
#rename to scene-d0-MinGreedy
#sed 's/[a-z]*_\([a-z]*\)[.]ttt_[a-z]*[0-9]*\(_[a-z]*[0-9,.]*\)_ass\([a-zA-Z_]\)*.*/\1\2/' 
