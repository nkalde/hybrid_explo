#!/bin/bash

#scripts
statScript=./Experiment/main/getStat.sh
dataScript=./Experiment/main/getDataP.sh
runScript=./Experiment/main/runP.sh

#hosts
#cluster=./Experiment/main/hosts_loria 
#clusterData=./Experiment/main/serversData_loria
#clusterSync=./Experiment/main/hosts_loria_sync
cluster=./Experiment/main/maia1
clusterData=./Experiment/main/maia1
clusterSync=./Experiment/main/maia1
excludeSyncFile=./Experiment/main/excludeSync
logFile=./Experiment/main/logEmpty

#profiles
#--dry-run --filter-hosts
cSep='BBB'
#controlmaster experimental
echo '--progress --nice -2 --slf '$cluster --joblog $logFile --controlmaster -j2 > ~/.parallel/cluster #cluster
echo '--gnu -k' > ~/.parallel/gk #gnu, order
echo '-C '$cSep > ~/.parallel/ft #format table

echo "-----------------------"
echo "------SYNC CLUSTER-----"
echo "-----------------------"
#use cluster sync
parallel -J ft -J gk "rsync -rhl --exclude-from=$excludeSyncFile --delete-excluded . {1}:{2}" :::: $clusterSync
#test with k keep dirlinks
echo "-----------------------"
echo "------EXPERIMENTS------"
echo "-----------------------"
#nb robots
nbr=2
#max simulation time
max=300000
#force quit time
tim=500000
#density
den='0.2'
#strategy
opt='1 3'
#alpha
alp='0 0.25 0.5 0.75 1'
#sigma
sig='0 0.25 0.5 0.75 1'
#scenes
#scenes=`ls $PWD/Experiment/scenes`
#scenes='test_empty.ttt'
#test_cave.ttt'
#scenes='test_cave.ttt test_roomsN.ttt'
scenes='test_corridor.ttt'
#rep
rep=`seq 1 1 10`

#parallel -J gk echo ::: $scenes ::: $cSep ::: $tim ::: $cSep ::: $nbr ::: $cSep ::: $den ::: $cSep ::: $opt ::: $cSep ::: $alp ::: $cSep ::: $sig ::: $cSep ::: $max ::: $cSep ::: $rep > parameters
#parallel -J gk -J cluster -J ft $runScript {1} -s{2} -g{3} -g{4} -g{5} -g{6} -g{7} -g{8} -g{#} -q -h :::: parameters
#rm parameters

echo "-----------------------"
echo "-----CLUSTER DATA------"
echo "-----------------------"
#parallel -J ft -J gk "rsync -zrv --remove-source-files -e ssh {1}:{2}/Core/monitoring/data/ Experiment/data_{1} ; echo data from {1}:pwd ." :::: $clusterData
#$dataScript

echo "-----------------------"
echo "----------STAT---------"
echo "-----------------------"
#$statScript