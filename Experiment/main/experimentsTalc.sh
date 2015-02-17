#!/bin/bash
#DOES NOT WORK THE VERSION OF GLIBC IS OLD

#scripts
initCluster=./Experiment/main/talc/scriptsCluster/scriptInit.sh
endCluster=./Experiment/main/talc/scriptsCluster/scriptEnd.sh

#hosts
nbNodes=1
cluster=./Experiment/main/talc/hosts_talc 
clusterData=./Experiment/main/talc/data_talc
clusterSync=./Experiment/main/talc/sync_talc
excludeSyncFile=./Experiment/main/excludeSync
logFile=./Experiment/main/logEmpty

#profiles
cSep='BBB'
#controlmaster experimental
echo '--progress --nice -2 --slf '$cluster --joblog $logFile --controlmaster -j4 > ~/.parallel/cluster #cluster
echo '--gnu -k' > ~/.parallel/gk #gnu, order
echo '-C '$cSep > ~/.parallel/ft #format table

echo "-----------------------"
echo "-----SYNC FRONTEND-----"
echo "-----------------------"
#synchronize the cluster frontend
parallel --verbose -J ft -J gk "rsync -rh --exclude-from=$excludeSyncFile --delete-excluded . {1}:{2}" :::: $clusterSync

echo "-----------------------"
echo "---INIT RESERVATION----"
echo "-----------------------"
$initCluster $nbNodes
cat $cluster
cat $clusterData

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
den='0'
#strategy
opt='3'
#alpha
alp='0 0.25 0.5 0.75 1'
#sigma
sig='1'
#scenes
scenes=`ls $PWD/Experiment/scenes`
#scenes='test_empty.ttt'
#test_cave.ttt'
#scenes='test_cave.ttt test_roomsN.ttt'
#rep
rep=`seq 1 1 1`

parallel -J gk echo ::: $scenes ::: $cSep ::: $tim ::: $cSep ::: $nbr ::: $cSep ::: $den ::: $cSep ::: $opt ::: $cSep ::: $alp ::: $cSep ::: $sig ::: $cSep ::: $max ::: $cSep ::: $rep > parameters
parallel -J gk -J cluster -J ft $runScript {1} -s{2} -g{3} -g{4} -g{5} -g{6} -g{7} -g{8} -g{#} -q :::: parameters
rm parameters

echo "-----------------------"
echo "---------DATA----------"
echo "-----------------------"
#parallel -J ft -J gk "rsync -zrv --remove-source-files -e ssh {1}:{2}/Core/monitoring/data/ Experiment/data_{1} ; echo data from {1}:pwd ." :::: $clusterData
#$dataScript

echo "-----------------------"
echo "----------STAT---------"
echo "-----------------------"
#$statScript

echo "-----------------------"
echo "---FREE RESERVATION----"
echo "-----------------------"
#$endCluster