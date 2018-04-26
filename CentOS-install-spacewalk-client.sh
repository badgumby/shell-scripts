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
echo "Installing Spacewalk client"
echo -e $drawline${NC}
rpm -Uvh http://yum.spacewalkproject.org/2.7-client/RHEL/7/x86_64/spacewalk-client-repo-2.7-2.el7.noarch.rpm

echo -e ${BLUE}$drawline;
echo "Adding additional required repository for Spacewalk and installing dependencies"
echo -e $drawline${NC}
rpm -Uvh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install rhn-client-tools rhn-check rhn-setup rhnsd m2crypto yum-rhn-plugin

echo -e ${BLUE}$drawline;
echo -e "Download and install certificate from ${RED}SPACEWALK${BLUE} server"
echo -e $drawline${NC}
curl --insecure -o /root/rhn-org-trusted-ssl-cert-1.0-4.noarch.rpm https:/spacewalk.domain.com/pub/rhn-org-trusted-ssl-cert-1.0-4.noarch.rpm
rpm -Uvh /root/rhn-org-trusted-ssl-cert-1.0-4.noarch.rpm

echo -e ${BLUE}$drawline;
echo -e "Register Spacewalk client with ${RED}SPACEWALK${BLUE} and assign to ${RED}centos-7-base${BLUE} channel"
echo -e $drawline${NC}
rhnreg_ks --serverUrl=https://spacewalk.domain.com/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --activationkey=1-centos-7-base

echo -e ${BLUE}$drawline;
echo "Install Remote Command modules for Spacewalk"
echo -e $drawline${NC}
yum -y install rhncfg-actions
rhn-actions-control --enable-all

echo -e ${BLUE}$drawline;
echo "Change checkin time from every 4 hours to every 15 minutes"
echo -e $drawline${NC}
# check to see if it already exists in /etc/crontab
if grep -q "rhn_check" /etc/crontab; then
  echo -e "${RED}rhn_check already exists as cron job. Skipping...${NC}"
else
  sed -i 's:INTERVAL=240:INTERVAL=15:g' /etc/sysconfig/rhn/rhnsd
  eval "sed -i '15i\*/15 * * * * root rhn_check' /etc/crontab"
  echo -e "${BLUE}rhn_check added to ${RED}/etc/crontab${NC}"
fi

echo -e ${BLUE}$drawline;
echo "Install and configure osad for additional management"
echo -e $drawline${NC}
yum -y install osad
if grep -q "RHN-ORG-TRUSTED-SSL-CERT" /etc/sysconfig/rhn/osad.conf; then
  echo -e "${RED}RHN-ORG-TRUSTED-SSL-CERT already configured in osad.conf. Skipping...${NC}"
else
  sed -i "s:\osa_ssl_cert =:osa_ssl_cert = /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT:g" /etc/sysconfig/rhn/osad.conf
  systemctl enable osad
  systemctl restart osad
fi

echo -e ${BLUE}$drawline;
echo "Allow Spacewalk ports thru firewall"
echo -e $drawline${NC}
echo -e "${BLUE}Add port 69/udp${NC}"
firewall-cmd --add-port=69/udp --permanent
echo -e "${BLUE}Add port 5269/udp${NC}"
firewall-cmd --add-port=5269/udp --permanent
echo -e "${BLUE}Add port 5222/udp${NC}"
firewall-cmd --add-port=5222/udp --permanent
echo -e "${BLUE}Reload firewall${NC}"
firewall-cmd --reload

echo -e ${BLUE}$drawline;
echo -e "Registration completed for client ${RED}$HOSTNAME${BLUE}."
echo -e $drawline${NC}
