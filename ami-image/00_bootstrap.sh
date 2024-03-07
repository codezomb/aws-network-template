#!/bin/bash

set -e

echo "waiting 180 seconds for cloud-init to finish"
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do sleep 1; done'

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# Apt Install
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------

# Disable unattended upgrades
sed -i "s/Unattended-Upgrade \"1\"/Unattended-Upgrade \"0\"/g" /etc/apt/apt.conf.d/20auto-upgrades

apt update && apt install -y apt-transport-https ca-certificates curl gnupg lsb-release awscli

# Docker Repository

curl -fsSL \
  https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list

# Ruby Repository

curl -fsSL \
  https://raw.githubusercontent.com/fullstaq-labs/fullstaq-ruby-server-edition/main/fullstaq-ruby.asc | apt-key add

echo \
  "deb https://apt.fullstaqruby.org ubuntu-$(lsb_release -rs) main" | tee /etc/apt/sources.list.d/ruby.list

apt update && apt install -y libpam-google-authenticator docker-ce docker-ce-cli containerd.io \
  fullstaq-ruby-common fullstaq-ruby-3.1 docker-compose-plugin docker-compose \
  amazon-ecr-credential-helper binutils tmux build-essential autoconf libtool \
  libpam0g-dev libqrencode4 zsh

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# Google MFA
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------

sed -i 's/KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/g' /etc/ssh/sshd_config
echo "AuthenticationMethods publickey,keyboard-interactive" >> /etc/ssh/sshd_config

sed -i 's/@include common-auth/#@include common-auth/g' /etc/pam.d/sshd
echo 'auth required pam_google_authenticator.so nullok' >> /etc/pam.d/sshd
echo 'auth required pam_permit.so' >> /etc/pam.d/sshd

cat << 'EOT' > /etc/profile.d/00-mfa.sh
if ! [ -s $HOME/.google_authenticator ]; then
  trap logout SIGINT # prevent bypassing with ctrl-c

  google-authenticator --time-based --disallow-reuse --force --rate-limit=3 --rate-time=30 --window-size=1

  echo
  echo "Save the generated emergency scratch codes and use secret key or scan the QR code to register your device for multifactor authentication."
  echo "Login again using your ssh key pair and the generated One-Time Password on your registereddevice."
  echo

  logout
fi
EOT

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# User
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------

usermod -aG docker ubuntu
