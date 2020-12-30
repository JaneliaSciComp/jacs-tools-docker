#!/bin/bash
#
# Takes a Xvfb port and a process which is running inside of that Xvfb instance, and monitors 
# by taking periodic screenshots of the framebuffer. Kills the session if its been running for 
# longer than an hour.
#

NUMPARAMS=$#
if [ $NUMPARAMS -lt 2 ]
then
    echo " "
    echo " USAGE: sh $0 [XVFB port] [PID of process to monitor] [timeout in seconds]"
    echo " "
    exit
fi

PORT=$1
PROCESS_PID=$2
TIMEOUT=$3

XVFB_SCREENSHOT_DIR="./xvfb.${PORT}"
mkdir -p $XVFB_SCREENSHOT_DIR
ssinc=30
freq=$ssinc
inc=5
t=0
nt=$freq

# Take a screenshot with quadratically increase latency.
# For example, when ssinc=5, the time between screenshots works out to the quadratic sequence 2.5t^2+2.5t
# which means that screenshots are taken at 5 seconds, 15 seconds, 30 seconds, 50 seconds, etc.
while kill -0 $PROCESS_PID 2> /dev/null; do
  sleep $inc
  t=$((t+inc))
  if [ "$t" -eq "$nt" ]; then
    freq=$((freq+ssinc))
    nt=$((t+freq))
    DISPLAY=:$PORT import -window root $XVFB_SCREENSHOT_DIR/screenshot_$t.png
  fi
  if [ "$t" -gt $TIMEOUT ]; then
    echo "Killing xvfb-enabled program which has been running for over $TIMEOUT seconds"
    kill -9 $PROCESS_PID 2> /dev/null
  fi
done

