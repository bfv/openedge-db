#!/bin/bash

#ls -l /install/patch/
echo "******** install base **************************************************************************************"
/install/openedge/proinst -b /install/openedge/response.ini -l /install/install_oe.log -n

cat /usr/dlc/version

echo "******** done **************************************************************************************"
