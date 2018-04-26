#!/bin/bash
#Line separator variable
drawline=`printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -`

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\e[1m'
NB='\e[21m' #No Bold
NC='\033[0m' # No Color

clear
echo -e ${BLUE}$drawline;
echo "Installing domain tools"
echo -e $drawline${NC}
yum -y install sssd realmd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation openldap-clients policycoreutils-python

echo -e ${BLUE}$drawline;
echo "Enter DOMAIN.com username (ex. user1)"
echo -e $drawline${NC}
read -p "# " username

#Join to Domain.com domain
realm join --user=$username domain.com

#Show domain info
echo -e ${BLUE}$drawline;
echo "Displaying domain status"
echo -e $drawline${NC}
realm list

#Give user chance to exit script if domain join failed
echo ""
echo -e ${BLUE}$drawline
echo "Verify the machine joined the domain succesfully."
echo -e "Press ENTER to continue, press CTRL+C to exit."
read -p $drawline
echo -e ${NC}

#Change from user@domain.com to user
sed -i 's:use_fully_qualified_names = True:use_fully_qualified_names = False:g' /etc/sssd/sssd.conf
sed -i 's:fallback_homedir = /home/%u@%d:fallback_homedir = /home/%u:g' /etc/sssd/sssd.conf

#Turn off credential caching
sed -i 's:cache_credentials = True:cache_credentials = False:g' /etc/sssd/sssd.conf

#Create cron job to invalidate accounts/groups
# check to see if it already exists in /etc/crontab
if grep -q "sss_cache" /etc/crontab; then
  echo "sss_cache already exists as cron job. Skipping..."
else
  eval "sed -i '15i\*/15 * * * * root sss_cache -E' /etc/crontab"
fi

#Set groups with SSH access
echo -e ${BLUE}$drawline
echo -e "Enter groups for ${RED}${BOLD}SSH${BLUE}${NB} access"
echo "Group must be entered in all lowercase letters"
echo -e "${RED}Replace spaces in group with ? (ex. test?group)${BLUE}"
echo -e $drawline${NC}
read -p "# " sshgroup

eval "sed -i '97i\AllowGroups domain?admins wheel $sshgroup' /etc/ssh/sshd_config"

# Set idle checkin to 10 minutes, with disconnect after 3 ignored responses (30 minute idle timeout)
sed -i "s:\#ClientAliveInterval 0:ClientAliveInterval 600:g" /etc/ssh/sshd_config
sed -i "s:\#ClientAliveCountMax 3:ClientAliveCountMax 3:g" /etc/ssh/sshd_config

#Set groups with sudo access
echo -e ${BLUE}$drawline
echo -e "Enter group for ${RED}${BOLD}SUDO${BLUE}${NB} access"
echo -e "Group must be entered in all lowercase letters${RED}"
echo 'Escape spaces with \\\\ (ex. server\\\\ admins)'
echo -e ${BLUE}$drawline${NC}
read -p "# " sudogroup

eval "sed -i '100i\%$sudogroup ALL=(ALL) ALL' /etc/sudoers"
eval "sed -i '101i\%domain\\\ admins ALL=(ALL) ALL' /etc/sudoers"

echo -e ${BLUE}$drawline
echo "Restarting SSHd"
echo -e $drawline${NC}
systemctl restart sshd

echo -e ${BLUE}$drawline
echo "Restarting SSSd"
echo -e $drawline${NC}
systemctl restart sssd

echo ""
echo -e ${BLUE}$drawline
echo -e "${RED}$HOSTNAME${BLUE} has joined the domain. Please move to the Servers OU."
echo "Also, please verify that its DNS entry is static."
echo -e $drawline${NC}
