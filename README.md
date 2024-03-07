
This project is for setting up an VPC in AWS with EKS and ECR and a jump host for connecting to the cluster. It can easily be expanded to incorporate other AWS services.

You will need an amazon account, and credentials stored within `$HOME/.aws/credentials`.

## Build the docker container

All dependencies are installed via docker container and bash script. You will need, at minimum docker installed. If you want to use encrypted terraform values, then you will need [sops](https://github.com/getsops/sops). This run script will handle descrypting the file for you. I recommend AWS KMS for the encryption key.

```shell
docker build -t dev-env .
```

## Build the amazon image

Once the docker image is built, you may shell into the container.

```shell
docker run --rm -it  -v <path to .aws folder>:/root/.aws -v $PWD:/workspace dev-env bash
```

Once inside the container you can build the development image. This image is setup for some basic depenendcies including, Ruby, NodeJS, and Docker. It is setup with SSH access and uses Google Authenticator and private keys to handle authentication. This image is built using packer, and can be customized, or new custom images can be defined and built.

```shell
cd /workspace/ami-image
packer init .
packer build -var prefix=<uniq prefix> .

# ...
# ==> Wait completed after 9 minutes 31 seconds
# ==> Builds finished. The artifacts of successful builds are:
# --> amazon-ebs.amd64: AMIs were created:
# us-west-2: ami-...
```

## Launch the environment

Before launching the environment create a file in `terraform/terraform.tfvars`, or if you prefer to have an encrypted version you can create a file in `terraform/secrets/<workspace>.tfvars` and encrypt it using `sops`.

The file should look like the following, you can customize as necessary:

```hcl
prefix = "<unique index>"
user = {
  ssh_key       = "<public SSH key>"
  instance_type = "t2.micro"
  volume_size   = 500
}

vpc_cidr_block = "10.100.0.0/16"
kubernetes_version = "1.25"
eks_node_size = 2
```

To launch the environment first run a plan to make sure things look correct.

```shell
./terraform/run plan
```

If everything looks good apply the plan.

```shell
./terraform/run apply

# ...
# Apply complete! Resources: 32 added, 0 changed, 0 destroyed.
# Outputs:
# admin_ip_address = "..."
# cidr_blocks      = [...]
# vpc_id           = "..."
```

## Connect to the environment

Once the environment is up, you can connect to the environment via SSH. Upon first connection, you will be shows a QR code and emeergency codes. Scan the code and enter the initial code, and save the emergency codes. You will be disconnected, just reconnect again and you're good to go.

Once connected, setup your aws credentials, and run the following to setup credentials for the kubernetes cluster.

```shell
aws eks update-kubeconfig --region region-code --name <prefix>-default
```

From here you can use Helm, Kubectl, or k9s to communicate with the cluster.

