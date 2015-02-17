#!/bin/bash
	echo "deleting reservation" 
        myjob=$(oarstat -u | grep nkalde | sed "s#\([0-9]*\)\(.*\)#\1#");
        echo $myjob;
	oardel $myjob;