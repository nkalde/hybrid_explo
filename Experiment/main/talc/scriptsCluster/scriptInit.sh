dir=./Experiment/main/talc/
scriptSubscribe=$dir/scriptsCluster/scriptSubscribe.sh
scriptNodeFile=$dir/scriptsCluster/scriptNodeFile.sh

#subscribe reservation
if test $# -eq 0
	then
		nb=1
	else
		nb=$1
	fi
ssh talc.nancy.g5k 'bash -s' < $scriptSubscribe $nb
ssh talc.nancy.g5k 'bash -s' < $scriptNodeFile
if [[ -f fileNodeList ]]; then
    rm fileNodeList
fi
scp talc.nancy.g5k:fileNodeList $dir

file=$dir/fileNodeList
hostFile=$dir/hosts_talc
dataFile=$dir/data_talc

#generate hosts
if [[ -f $hostFile ]]; then
    echo "remove last hosts"
    rm $hostFile
fi
touch $hostFile
cat $file | sed 's#\(.*\)#ssh -t -t -t -X \1 "cd kalde_local ; /bin/bash"#' >> $hostFile

#generate data
if [[ -f $dataFile ]]; then
    echo "remove last hosts"
    rm $dataFile
fi
touch $dataFile
cat $file | sed 's#\(.*\)#\1 BBB kalde_local#' >> $dataFile

