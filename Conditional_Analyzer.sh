#!/bin/bash
count=15 #number of thread dumps
while :

do
  pid=1234 #process ID of the java tool
  usage=`top -b -n 2 -p $pid | tail -1 | awk '{print $9}' |cut -f 1 -d "."`

  echo "CPU is [$usage]"

  if [ "$usage" -ge 100 ]; then #runs if CPU usage > 100
    echo "Running the script. CPU is [$usage]"
    jcmd $pid VM.unlock_commercial_features
    echo "Capturing thread dumps"
      for i in `seq 1 $count`;
      do
        jstack -l $pid > thread_dump_`date "+%F-%T"`.txt &
        ps --pid $pid -Lo pid,tid,%cpu,time,nlwp,c > thread_usage_`date "+%F-%T"`.txt &
        if [ $i -ne $count ]; then
          echo "sleeping for 1s [$i]"
          sleep 1 #Interval
        fi
      done
      echo "Capturing heap dump"
      jmap -dump:format=b,file=heapdump.hprof $pid
      echo "sleeping for 10s"
      sleep 10
      echo "Capturing JFR dump"
      jcmd $pid JFR.start name=test settings=profile.jfc duration=600s filename=apim_profiling.jfr
      echo "sleeping for 10s"
      sleep 10
      echo "sleeping for 2h"
      sleep 7200
    fi


  echo "sleeping for 30s"
  sleep 30

done
