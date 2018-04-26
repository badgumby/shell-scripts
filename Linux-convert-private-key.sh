# Login to Windows machine and open MMC.exe
# Add Snapin for Certificates
# Select 'My user account'
# Expand 'Personal' store
# Double-click 'username' certificate with template type 'User-Private'
# Switch to 'Details' tab
# Copy to file...
# Export user certificate with private key - 'Yes, export the private key'
# Take the defaults on the next page, then check the password box, and enter password you will remember
# This will export as a .pfx file

# On a linux machine complete the below steps
# Extract encrypted key
openssl pkcs12 -in [yourfile.pfx] -nocerts -out [keyfile-encrypted.key]

# Extract certificate
openssl pkcs12 -in [yourfile.pfx] -clcerts -nokeys -out [certificate.cer]

# Decrypt the key
openssl rsa -in [keyfile-encrypted.key] -out [keyfile-decrypted.key]

# Re-encrypt the key with AES128
openssl rsa -aes128 -in [keyfile-decrypted.key] -out [keyfile-password.key]
