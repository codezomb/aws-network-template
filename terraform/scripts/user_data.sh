#!/bin/bash -e

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
EC2_INSTANCE_ID=$(curl -s http://instance-data/latest/meta-data/instance-id)

DATA_STATE="unknown"
until [ "$${DATA_STATE}" == "attached" ]; do
  DATA_STATE=$(aws ec2 describe-volumes \
    --filters \
        Name=attachment.instance-id,Values=$${EC2_INSTANCE_ID} \
        Name=attachment.device,Values=/dev/sdh \
    --query Volumes[].Attachments[].State \
    --output text)

  sleep 5
done

# Setup /etc/fstab to automount the volume at the users home directory
echo '/dev/xvdh /home/ubuntu ext4 defaults,nofail 0 2' | tee -a /etc/fstab

# Format and mount the volume, copy the data and unmount
if [[ "$(lsblk -no FSTYPE /dev/xvdh)" != "ext4" ]]; then
  mkfs -t ext4 /dev/xvdh && mount /dev/xvdh /mnt
  cp -pR /home/ubuntu/. /mnt/ && umount /mnt
fi

# Mount all volumes
mount -a

# Setup docker credentials helper
mkdir -p /home/ubuntu/.docker/
cat <<EOF > /home/ubuntu/.docker/config.json
{
  "credHelpers" : {
    "${account}.dkr.ecr.us-west-2.amazonaws.com" : "ecr-login"
  }
}
EOF

# Setup user SSH
echo "${ssh_key}" > /home/ubuntu/.ssh/authorized_keys
