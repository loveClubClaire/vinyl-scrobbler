#!/bin/sh

#Expected to run nightly and rename the day's log file with todays date. Move it into a folder for convenience
_cDate=$(date +"%m-%d-%y")
cd /home/pi/docs
mv fingerprint.log log-files/"$_cDate".txt
