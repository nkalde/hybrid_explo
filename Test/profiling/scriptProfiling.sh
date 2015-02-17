#!/bin/bash

for f in *.log 
do
	echo "Processing $f file..";
	lua summary.lua $f > "$f.sum"
	lua summary.lua -v $f > "$f.sumv"
done