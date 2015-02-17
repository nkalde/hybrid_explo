#!/bin/bash

#working directory must be luaN
if test $# -eq 0
then
	echo "usage: ./run.sh [scenePath]"
else
	platform='unknown'
	unamestr=`uname`
	if [[ "$unamestr" == 'Linux' ]]; then
	   platform='linux'
	elif [[ "$unamestr" == 'Darwin' ]]; then
	   platform='darwin'
	fi
	echo "platform : "$platform 
	if [[ "$platform" != 'unknown' ]]; then
	
		dirscene=$PWD/Experiment/scenes
		dirdistrib=$PWD/Simulator
		echo "scene: "$1
		
		if [[ "$platform" == 'linux' ]]; then
			distrib=V-REP_PRO_EDU_V3_1_2_64_Linux
			LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$dirdistrib/$distrib
			export LD_LIBRARY_PATH	
		elif [[ "$platform" == 'darwin' ]]; then
			distrib=V-REP_PRO_EDU_V3_1_2_Mac/vrep.app/Contents/MacOS
		fi
	
		$dirdistrib/$distrib/vrep \
		$dirscene/$*
	fi
fi

