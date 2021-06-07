# Ansible Basics

## Exercice 1

As a reminder, the objective of the exercice is to deploy a ghost blogging platform using Terraform and Ansible.

For this exercice some variables values files were not pushed to GitHub (.gitignore) due to passwords / SSH keys values contained in plain text in those files...

### Terraform

For the "hardware"/"infrastructure" part, I build the following architecture: 

*this infrastructure is very similar to the one build in Terraform-basics Exercice 1 - please see the [README](https://github.com/OlivierPaulo/DDChallenges/tree/main/Terraform/ex1#terraform-basics) to have a code block to code block explanation)*

- a VPC module containing (in `modules/vpc/main.tf`) :
    - a CIDR block with `/16` mask
    - an Internet Gateway
    - 1 subnet with `/24` mask for EC2 instance(s) (`10.0.0.0 -> 10.0.0.255`)
    - 1 subnet with `/24` mask for RDS machine(s) (`10.0.1.0 -> 10.0.1.255`)
    - 1 Security Group for "EC2" subnet allowing **only TCP ports 22, 80 and 443** from Internet. All (ports, protocals, IPs) is allowed for Outbound.
    - 1 Security Group for "RDS" subnet allowing **only TCP port 3306 (MySQL here) from "EC2" subnet**. All (ports, protocols) is allowed to EC2 subnet for Outbound trafic.
    - 1 route table
    - 1 route table association


- one RDS machine containing (in `modules/aws-rds/main.tf`):
    - 1 DB subnet group which takes "EC2" and "RDS" subnets
    - 1 DB instance with :
        - 20 GB allocated storage
        - MySQL engine in version 5.7
        - identifier, username, password
        - the assiocation with the subnet group ID
        - the association with the VPC "RDS" Security Group ID.
        - Tags for Service (app_name) and Environment


- one EC2 instance [http-web-server] containing (in `modules/http-server/main.tf`):
    - 1 Ubuntu 18.04 VM
    - t2.nano instance type (prod.tfvars containing variables not pushed the repo)
    - 1 reserverd private IP (10.0.0.10 declared in `./variables.tf`
    - 1 subnet ID coming from VPC **Outputs** variables
    - 1 Security Group ID coming from VPC **Outputs** variables
    - 1 SSH Key Name associated to the Key Pair of Public and Private SSH keys.
    - Some Tags associated to EC2 Instance Name, Service and Environment.

- one Elastic IP association for public Internet IP for the EC2 Instance.

The terraform main `main.tf` file used to declare :
- The remote backend storage state (here in a S3 bucket)
- The VPC module call with App Name, Infrastructure Environment and DB port.
- The DB module call with App Name, Infrastructure Environment, Subnet ID for "RDS" subnets, RDS/DB instance type, DB Security Group ID, DB user, DB password and DB port.
- The HTTP-server module with App Name, Infrastructure Environment, SSH Key Name, Subnet ID for "EC2" subnet, Security Group for "EC2", EC2 Instance type and the Elastic Association IP (public Internet IP)

Region for Infrastructure is defined to be created in "us-west-2".

### Ansible 

On the Ansible side, we will run the 3 followings Playbook :
1. machine-initial-setup.yml
2. install-nginx-and-certs.yml
3. install-app.yml

#### Machine Initial Setup

This playbook will install the initial setup in the EC2 Instance (machine(s) declared into host inside group called `webserver`) with some basic upgrade from apt.
It will install also `htop` and `git` packages.
It will add also ssh keys insde the machine into `/home/ubuntu/.ssh/authorized_keys`.

#### Install Nginx and Certs

This playbook will install + configure Nginx (WebServer and Reverse Proxy) and Certbot for LetsEncrypt (HTTTS certificat management).

#### Install App

Note : both *Install Nginx and Certs* + *Install App* will reload Nginx service first before applying tasks of the playbook.

This playbook will install the app which includes then the following steps :
- Node.js repo addition
- Node.js installation
- Ghost CLI installation using npm
- Ghost directory creation
- Ghost installation and configuration
- Nginx configuration file modification and Nginx service reload.