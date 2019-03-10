#!/bin/sh
# Task 1 

if [ ! -d $1 ]; then
	echo "Path given doesn't exist!"
	exit 7;
fi
cd $1
make > /dev/null 2>&1
MAKERET=$?
if [ $MAKERET = 0 ];
then
	if [ ! -e $2 ]; then
		echo "File given doesn't exist"
		exit 3;
fi
	valgrind --error-exitcode=1 --log-file=/dev/null --leak-check=full -v ./$2
	MEMRET=$?
	valgrind --error-exitcode=1 --log-file=/dev/null --tool=helgrind ./$2 
	RACERET=$?
	LEAKTEXT=PASS
	if [ $MEMRET = 1 ]; then
		LEAKTEXT="FAIL"
	fi
	RACETEXT=PASS
	if [ $RACERET = 1 ]; then
		RACETEXT="FAIL"
	fi
	echo "Compilation    Memory leaks     Thread race"
	echo "   PASS           $LEAKTEXT             $RACETEXT"
else
	echo "Compilation    Memory leaks     Thread race"
	echo "   FAIL         NOT TESTED       NOT TESTED"
	MAKERET=1
	exit 7;
fi

#calculating return value

MAKERET=$(( $MAKERET << 2 ))
MEMRET=$(( $MEMRET << 1 ))
RESULT=0
RESULT=$(( RESULT | MAKERET ))
RESULT=$(( RESULT | MEMRET ))
RESULT=$(( RESULT | RACERET ))
exit $RESULT;

