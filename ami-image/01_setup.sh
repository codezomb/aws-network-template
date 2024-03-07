#!/bin/bash

trap clean EXIT
set -e

kubectl_version=1.29.2
sops_version=3.7.1
helm_version=3.7.2

clean() {
  rm *.tar.gz *.zip
  rm -rf aws
}

apt-get update && apt-get install -y jq git curl unzip

# ----------------------------------------------------------------------------------------------------------------------
# kubectl

curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${kubectl_version}/bin/linux/amd64/kubectl
mv kubectl /bin/kubectl && chmod +x /bin/kubectl

# ----------------------------------------------------------------------------------------------------------------------
# sops

curl -sLO https://github.com/mozilla/sops/releases/download/v${sops_version}/sops-v${sops_version}.linux
mv sops-v${sops_version}.linux /bin/sops && chmod +x /bin/sops

# ----------------------------------------------------------------------------------------------------------------------
# helm

curl -sLO https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz
tar zxvf helm-v${helm_version}-linux-amd64.tar.gz --strip=1 linux-amd64/helm
mv helm /bin/helm && chmod +x /bin/helm

helm plugin install https://github.com/zendesk/helm-secrets || true

# ----------------------------------------------------------------------------------------------------------------------
# aws

curl -sLO https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
unzip awscli-exe-linux-x86_64.zip && ./aws/install
