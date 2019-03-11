#!/bin/sh
# Task 1

Path=$1
File=$2
shift 2
Args=$@

if [ ! -d $Path ]; then
	echo "Path given doesn't exist!"
	exit 7;
fi
cd $Path
make > /dev/null 2>&1
MakeRet=$?
if [ $MakeRet = 0 ];
then
	if [ ! -e $File ]; then
		echo "File given doesn't exist"
		exit 3;
fi
	valgrind --error-exitcode=1 --log-file=/dev/null --leak-check=full -v ./$File $Args
	MemRet=$?
	valgrind --error-exitcode=1 --log-file=/dev/null --tool=helgrind ./$File $Args
	RaceRet=$?
	MemText=PASS
	if [ $MemRet = 1 ]; then
		MemText="FAIL"
	fi
	RaceText=PASS
	if [ $RaceRet = 1 ]; then
		RaceText="FAIL"
	fi
	echo "Compilation    Memory leaks     Thread race"
	echo "   PASS           $MemText             $RaceText"
else
	echo "Compilation    Memory leaks     Thread race"
	echo "   FAIL         NOT TESTED       NOT TESTED"
	MakeRet=1
	exit 7;
fi

#calculating return value
#The result is represented with 3 bits, so the answer ranges 0-7

MakeRet=$(( $MakeRet << 2 )) #The MSB
MemRet=$(( $MemRet << 1 ))   #The middle bit
Result=0
Result=$(( Result | MakeRet ))
Result=$(( Result | MemRet ))
Result=$(( Result | RaceRet )) #Race result is LSB, doesn't need to be shifted
exit $Result;

