#!/bin/bash

#Line separator variable
drawline=`printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -`

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

clear

echo -e ${BLUE}$drawline;
echo "Install open-vm-tools"
echo -e $drawline${NC}
if ! rpm -qa | grep -qw open-vm-tools; then
  yum -y install open-vm-tools
else
  echo -e "${RED}open-vm-tools is already installed. Skipping...${NC}"
fi

echo -e ${BLUE}$drawline;
echo "Starting open-vm-tools service"
echo -e $drawline${NC}
systemctl restart vmtoolsd.service
systemctl status vmtoolsd.service | grep Active

echo -e ${BLUE}$drawline;
echo "Set open-vm-tools to start on boot"
echo -e $drawline${NC}
systemctl enable vmtoolsd.service
systemctl status vmtoolsd.service | grep Loaded

echo -e ${BLUE}$drawline;
echo -e "Installation of open-vm-tools is complete on ${RED}$HOSTNAME${BLUE}."
echo -e $drawline${NC}
