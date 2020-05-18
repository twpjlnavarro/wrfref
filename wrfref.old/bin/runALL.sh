#!/bin/bash 

hh=${1-00}
source $HOME/etc/setENV.sh
source $HOME/etc/setCONFIG.sh $hh

exec &> $HOME/log/${stamp}.runALL.log

echo '.' | mail -s "Start run ${stamp}..." jlnavarro@theweatherpartner.com  &> /dev/null

echo $(date +"%T") runPRE.sh ...
$HOME/bin/runPRE.sh $hh

echo $(date +"%T") runGFS.sh ...
$HOME/bin/runGFS.sh $hh

echo $(date +"%T") runWPS.sh ...
$HOME/bin/runWPS.sh $hh

echo $(date +"%T") runWRF.sh ...
$HOME/bin/runWRF.sh $hh

echo $(date +"%T") runPOST.sh ...
$HOME/bin/runPOST.sh $hh

sleep 5
cat $HOME/log/${stamp}.runALL.log | mail -s "... run ${stamp} finished!" jlnavarro@theweatherpartner.com   &> /dev/null

echo $(date +"%T") runALL.sh finished!
