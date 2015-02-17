#!/bin/bash
        if [ -f fileNodeList ];
        then
                echo "removing old file of nodes";
                rm fileNodeList;
        fi
        echo "creating file of nodes";
        touch fileNodeList;

        myjob=$(oarstat -u | grep nkalde | sed "s#\([0-9]*\)\(.*\)#\1#");
        echo $myjob;
        mynodes=$(oarstat -fj $myjob | tr -d ' ' | grep assigned_hostnames | sed 's#assigned_hostnames=*\(.*\)#\1#')
        echo $mynodes;
		sed s#+#\\n#g <<< $mynodes | sed s#grid5000.fr#g5k# >> fileNodeList