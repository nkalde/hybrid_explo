#!/bin/bash
	if test $# -eq 0
	then
		nb=1
	else
		nb=$1
	fi
	echo "subscribing reservation" 
        mysub=$(oarsub -l nodes=$nb -t allow_classic_ssh "sleep 10d");
        echo $mysub;