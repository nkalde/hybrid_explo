#! /bin/bash

for file in `ls tet`;
do
	echo $file
	diff tet/$file 10TPlusAngle2/$file
done
