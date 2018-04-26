#!/bin/bash

#Line separator variable
drawline=`printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -`

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\e[1m'
NB='\e[21m' #No Bold
NC='\033[0m' # No Color

clear

echo -e ${BLUE}$drawline;
echo "This script will install the following applications:"
echo -e "${BOLD} wget vim zip unzip htop${NB}"
echo -e $drawline${NC}
read -p "Press ENTER to continue, CTRL+C to exit"

echo -e ${BLUE}$drawline;
echo "Installing applications"
echo -e $drawline${NC}
yum -y install wget vim zip unzip htop

echo -e ${BLUE}$drawline;
echo -e "Applications installed on ${RED}$HOSTNAME${BLUE}"
echo -e $drawline${NC}
