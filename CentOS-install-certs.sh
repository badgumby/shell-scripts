#!/bin/bash
#Line separator variable
drawline=`printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -`
cr=`echo $'\n.'`
cr=${cr%.}
copts2="-O --tlsv1.2 --insecure --request"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e ${BLUE}$drawline;
echo "Download certificates from Hosted site"
echo -e $drawline${NC}
cd /root/
curl $copts2 GET --header "PRIVATE-TOKEN: $token" 'https://website.domain.com/certs.zip'

echo -e ${BLUE}$drawline;
echo "Install unzip, if not installed"
echo -e $drawline${NC}
yum -y install unzip

echo -e ${BLUE}$drawline;
echo "Unzip certificates to /root/certs"
echo -e $drawline${NC}
cd /root/
mkdir /root/certs
unzip certs.zip -d /root/certs
cd /root/certs/

echo -e ${BLUE}$drawline;
echo -e ${BLUE}$drawline;
echo "Initialize PKI database"
echo -e "${RED}When asked for a password, just press ENTER"
echo -e ${BLUE}$drawline;
echo -e $drawline${NC}
certutil -N -d sql:$HOME/.pki/nssdb

echo -e ${BLUE}$drawline;
echo -e "List current ${RED}ROOT USER/GLOBAL${BLUE} installed certificates"
echo -e $drawline${NC}
certutil -L -d sql:$HOME/.pki/nssdb
certutil -L -d sql:/etc/pki/nssdb

echo -e ${BLUE}$drawline;
echo "Verify there are no error messages displayed"
read -p "Press ENTER to continue, press CTRL+C to exit $cr$drawline$cr"
echo -e $drawline${NC}

echo -e ${BLUE}$drawline;
echo -e "Installing ${RED}ROOT USER${BLUE} certificates"
echo -e $drawline${NC}
certutil -d sql:$HOME/.pki/nssdb -A -t TC -n "Cert1" -i Cert1.cer
certutil -d sql:$HOME/.pki/nssdb -A -t TC -n "Cert2" -i Cert2.cer
certutil -d sql:$HOME/.pki/nssdb -A -t TC -n "Cert3" -i Cert3.crt
certutil -d sql:$HOME/.pki/nssdb -A -t TC -n "Cert4" -i Cert4.crt

echo -e ${BLUE}$drawline;
echo -e "List current installed ${RED}ROOT USER${BLUE} certificates"
echo -e $drawline${NC}
certutil -L -d sql:$HOME/.pki/nssdb

echo -e ${BLUE}$drawline;
echo "Verify you see all required certificates"
read -p "Press ENTER to continue, press CTRL+C to exit. $cr$drawline$cr"
echo -e $drawline${NC}

echo -e ${BLUE}$drawline;
echo -e "Installing ${RED}GLOBAL${BLUE} certificates"
echo -e $drawline${NC}
certutil -d sql:/etc/pki/nssdb -A -t TC -n "Cert1" -i Cert1.cer
certutil -d sql:/etc/pki/nssdb -A -t TC -n "Cert2" -i Cert2.cer
certutil -d sql:/etc/pki/nssdb -A -t TC -n "Cert3" -i Cert3.crt
certutil -d sql:/etc/pki/nssdb -A -t TC -n "Cert4" -i Cert4.crt

echo -e ${BLUE}$drawline;
echo -e "List current installed ${RED}GLOBAL${BLUE} certificates"
echo -e $drawline${NC}
certutil -L -d sql:/etc/pki/nssdb

echo -e ${BLUE}$drawline;
echo "Verify you see all required certificates"
read -p "Press ENTER to continue, press CTRL+C to exit $cr$drawline$cr"
echo -e $drawline${NC}

echo -e ${BLUE}$drawline;
echo -e "Certificate install complete on ${RED}$HOSTNAME${BLUE}."
echo -e $drawline${NC}
