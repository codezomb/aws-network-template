MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash -e

/etc/eks/bootstrap.sh \
  --b64-cluster-ca '${cluster_auth_base64}' \
  --apiserver-endpoint '${endpoint}' \
  '${cluster_name}'

--==MYBOUNDARY==
${additional_userdata}
