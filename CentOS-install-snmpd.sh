#!/bin/bash

#Line separator variable
drawline=`printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -`

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

clear

echo -e ${BLUE}$drawline;
echo "Install SNMPd"
echo -e $drawline${NC}
yum -y install net-snmp net-snmp-utils

echo -e ${BLUE}$drawline;
echo "Backup default config"
echo -e $drawline${NC}
mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.bak

echo -e ${BLUE}$drawline;
echo "Generate new config"
echo -e $drawline${NC}

echo -e ${BLUE}$drawline;
echo "Enter a location (ex. United States):"
echo -e $drawline${NC}
read location
echo -e ${BLUE}$drawline;
echo "Enter a system contact (ex. IT Infrastructure): "
echo -e $drawline${NC}
read contact
echo -e ${BLUE}$drawline;
echo "Enter the RO community string (ex. my!snmp!string): "
echo -e $drawline${NC}
read rostring

echo "syslocation \"$location\"" >> /etc/snmp/snmpd.conf
echo "syscontact  \"$contact\"" >> /etc/snmp/snmpd.conf
echo 'sysservices 76' >> /etc/snmp/snmpd.conf
echo '' >> /etc/snmp/snmpd.conf
echo 'rocommunity testing localhost' >> /etc/snmp/snmpd.conf
echo "rocommunity $rostring  monitoring-server.domain.com" >> /etc/snmp/snmpd.conf
echo '' >> /etc/snmp/snmpd.conf
echo 'disk /' >> /etc/snmp/snmpd.conf

echo -e ${BLUE}$drawline;
echo "Restart SNMPd service and set to start on boot"
echo -e $drawline${NC}
service snmpd restart
chkconfig snmpd on

echo -e ${BLUE}$drawline;
echo "Allow SNMP thru firewall"
echo -e $drawline${NC}
echo -e "${BLUE}Add port 161/tcp${NC}";
firewall-cmd --zone=public --add-port=161/tcp --permanent
echo -e "${BLUE}Add port 162/tcp${NC}";
firewall-cmd --zone=public --add-port=162/tcp --permanent
echo -e "${BLUE}Add port 161/udp${NC}";
firewall-cmd --zone=public --add-port=161/udp --permanent
echo -e "${BLUE}Add port 162/udp${NC}";
firewall-cmd --zone=public --add-port=162/udp --permanent
echo -e "${BLUE}Reloading firewall${NC}";
firewall-cmd --reload

echo -e ${BLUE}$drawline;
echo "Test the system info configuration"
echo -e $drawline${NC}
snmpwalk -v 2c -c testing localhost system
echo ""
echo -e ${BLUE}$drawline;
echo "Test the disk info configuration"
echo -e $drawline${NC}
snmpwalk  -v 2c -c testing localhost .1.3.6.1.4.1.2021.9

echo -e ${BLUE}$drawline;
echo -e "SNMP has been configured on ${RED}$HOSTNAME${BLUE}."
echo -e $drawline${NC}
