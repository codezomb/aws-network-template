#!/bin/sh

trap clean EXIT
set -e

arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
terraform_version=1.7.1
packer_version=1.10.1
sops_version=3.8.1

clean() {
  rm -f *.zip
  rm -rf aws
}

apk update && apk add curl unzip aws-cli bash

# ----------------------------------------------------------------------------------------------------------------------
# terraform

curl -sLO https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_${arch}.zip
unzip -o terraform_${terraform_version}_linux_${arch}.zip -d /bin
chmod +x /bin/terraform

# ----------------------------------------------------------------------------------------------------------------------
# packer

curl -sLO https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_${arch}.zip
unzip -o packer_${packer_version}_linux_${arch}.zip -d /bin
chmod +x /bin/packer

# ----------------------------------------------------------------------------------------------------------------------
# sops

curl -sLO https://github.com/mozilla/sops/releases/download/v${sops_version}/sops-v${sops_version}.linux.${arch}
mv sops-v${sops_version}.linux.${arch} /bin/sops && chmod +x /bin/sops
