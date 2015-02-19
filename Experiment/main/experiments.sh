#!/bin/bash

echo "-----------------------"
echo "------EXPERIMENTS------"
echo "-----------------------"
runScript=./Experiment/main/run.sh
#$scene $tim $nbr $den $opt $alp $sig $max $num
tim=300000
nbr=0
den=0
opt=3
alp=0.25
sig=0.25
max=500000
num=1
scenes[0]='test_empty.ttt'
scenes[1]='test_cave.ttt'
scenes[2]='test_roomsN.ttt'
scenes[3]='test_corridor.ttt'
scenes[4]='test_3rooms_corridor_small.ttt'

#params="${scenes[0]} -s$tim -g$nbr -g$den -g$opt -g$alp -g$sig -g$max -g$num -q"
#$runScript \
#$params

#params="${scenes[1]} -s$tim -g$nbr -g$den -g$opt -g$alp -g$sig -g$max -g$num -q"
#$runScript \
#$params

#params="${scenes[2]} -s$tim -g$nbr -g$den -g$opt -g$alp -g$sig -g$max -g$num -q"
#$runScript \
#$params

#params="${scenes[3]} -s$tim -g$nbr -g$den -g$opt -g$alp -g$sig -g$max -g$num -q"
#$runScript \
#$params

params="${scenes[1]} -g$nbr -g$den -g$opt -g$alp -g$sig -g$max -g$num"
$runScript \
$params

echo "-----------------------"
echo "----------DATA---------"
echo "-----------------------"
#./Experiment/main/getData.sh

echo "-----------------------"
echo "----------STAT---------"
echo "-----------------------"
#./Experiment/main/getStat.sh
