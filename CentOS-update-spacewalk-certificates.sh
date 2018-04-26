#Backup current SSL config
tar -cvf SSLconfig.tar \
  /etc/httpd/conf/ssl.* \
  /etc/pki/spacewalk/jabberd/server.pem \
  /root/ssl-build \
  /var/www/html/pub

#Copy both intermediate and root certs to server
#Cat into single cert chain
cat intermediate_ca.pem root_ca.pem > /root/ssl-build/RHN-ORG-TRUSTED-SSL-CERT

#Verify certs - Replace servername with the server name
openssl verify -CAfile /root/ssl-build/RHN-ORG-TRUSTED-SSL-CERT \
  /root/ssl-build/servername/server.crt

#Store CA cert in Spacewalk database
rhn-ssl-dbstore -v --ca-cert=/root/ssl-build/RHN-ORG-TRUSTED-SSL-CERT

#Generate web server SSL package
rhn-ssl-tool --gen-server --rpm-only --dir /root/ssl-build

echo "Enter the revision number from previous command:"
echo "(example: /root/ssl-build/servername/rhn-org-httpd-ssl-key-pair-servername-1.0-rev.src.rpm)"
read rev

#Install web server SSL package - Replace both servernames with the server name
rpm -Uhv /root/ssl-build/servername/rhn-org-httpd-ssl-key-pair-servername-1.0-$rev.noarch.rpm

#Generate public CA certificate package
rhn-ssl-tool --gen-ca --dir=/root/ssl-build --rpm-only

#Install  public CA certificate
rpm -Uhv /root/ssl-build/rhn-org-trusted-ssl-cert-1.0-$rev.noarch.rpm

#Copy certificates to pub for client access
cp /root/ssl-build/rhn-org-trusted-ssl-cert-1.0-$rev.noarch.rpm /var/www/html/pub
cp /root/ssl-build/RHN-ORG-TRUSTED-SSL-CERT /var/www/html/pub

#Stop Spacewalk services, clear the jabberd database, and restart Spacewalk - - Replace servername with the server name
spacewalk-service stop
rm -Rf /var/lib/jabberd/db/*
mv /etc/pki/spacewalk/jabberd/server.pem /etc/pki/spacewalk/jabberd/server.pem.old
cat /root/ssl-build/servername/server.crt /root/ssl-build/servername/server.key > /etc/pki/spacewalk/jabberd/server.pem
spacewalk-service start

echo "New certificates have been generated and installed."
echo "Please issue the following commands on any Spacewalk clients:"
echo "wget https://servername.domain.com/pub/rhn-org-trusted-ssl-cert-1.0-$rev.noarch.rpm"
