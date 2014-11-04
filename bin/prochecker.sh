#!/bin/sh
test -z $1
if [ "$?" -eq "0" ]
  then
  echo "Bad Usage"
  exit -1
fi
test -z $2
if [ "$?" -eq "0" ]
  then
  echo "Bad Usage"
  exit -1
fi
test -z $3
if [ "$?" -eq "0" ]
  then
  echo "Bad Usage"
  exit -1
fi

USER=$1
QUES_DIR=`pwd`/question/$2
REQ_TIME=$3
ZERO=0

compile() {
  gcc -O2 -DNDEBUG tmp/$USER/tmp.c -o tmp/$USER/a.out > /dev/null 2> /dev/null
  if [ "$?" -ne "0" ]
    then
    echo "Compile Error"
    exit -1
  fi
}

run() {
  (time tmp/$USER/a.out < $CASE/input_sample) > tmp/$USER/output 2> tmp/$USER/err
  if [ "$?" -ne "0" ]
    then
    echo "Rumtime Error"
    exit -1
  fi
}

check() {
  TIME=`awk '{if($1 ~ /user/) print substr($2, 1, 1)}' tmp/$USER/err`
  if [ "$TIME" -gt "$REQ_TIME" ]
    then
    echo "Time Expired"
    exit -1
  fi
  diff tmp/$USER/output $CASE/output_sample > tmp/$USER/rs
  test -s tmp/$USER/rs
  if [ "$?" -ne "1" ]
    then
    echo "Wrong Answer"
    exit -1
  fi
}

compile
for CASE in $QUES_DIR/test*
do
  run
  check
done
echo "Accepted"
