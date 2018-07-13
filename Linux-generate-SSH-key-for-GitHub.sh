# Open a terminal and type the below (enter your email address registered with GitHub)
ssh-keygen -t rsa -b 4096 -C "your_email@users.noreply.github.com"
# Generating public/private rsa key pair.

# Enter a file in which to save the key (/home/you/.ssh/id_rsa):
~/.ssh/id_rsa_github

# Enter passphrase (empty for no passphrase):
[Type a passphrase]
# Enter same passphrase again:
[Type passphrase again]

# Add the key to the SSH-Agent permanently
touch ~/.ssh/config
vim ~/.ssh/config

# Paste in below contents
Host github
   HostName github.com
   User git
   IdentityFile ~/.ssh/id_rsa_github

# Add SSH key to your GitHub account
# 1. Login to GitHub
# 2. Go to 'Settings' > 'SSH and GPG keys'
# 3. Select 'New SSH key'
# 4. Enter a name (I normally use computer name)
# 5. Paste in the content of ~/.ssh/id_rsa_github.pub (note: this is the public key file)

# Be sure to update your git configs to have it set to use 'git' rather than 'https'

# Example
[remote "origin"]
	url = git@github:badgumby/repo-name
	fetch = +refs/heads/*:refs/remotes/origin/*
