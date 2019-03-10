#!/bin/sh
# Task 1

if [ ! -d $1 ]; then
	echo "Path given doesn't exist!"
	exit 7;
fi
cd $1
make > log 2>&1
MakeRet=$?
if [ $MakeRet = 0 ];
then
	if [ ! -e $2 ]; then
		echo "File given doesn't exist"
		exit 3;
fi
	valgrind --error-exitcode=1 --log-file=/dev/null --leak-check=full -v ./$2
	MemRet=$?
	valgrind --error-exitcode=1 --log-file=/dev/null --tool=helgrind ./$2
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

