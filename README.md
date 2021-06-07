# Infrastructure as a Code


This repo contains some exercices related to Infrastucture as a code products as `Terraform` and `Ansible`


# Table of Contents
1. [Terraform-basics](https://github.com/OlivierPaulo/DDChallenges#Terraform-basics)
2. [Ansible-basics](https://github.com/OlivierPaulo/DDChallenges#Ansible-basics)


## Terraform-basics

The *Terraform* folder contains code to cover the two following exercices. 

### Exercice 1 (ex1)

Here, the objective is to fully create using _Terraform_ an infrastructure containing the following elements :

An AWS `VPC` where : 
> Only Ports **80**, **443** and **22** are open to **Internet**.
> Create an `EC2 machine` (smallest one possible) which has access to an `RDS machine` (db engine : `postgres`, smallest one possible). The RDS machine is not publicly available.

You will find in this [README](https://github.com/OlivierPaulo/DDChallenges/Terraform/ex1/README.md) the explanation on how I build this infrascture using Terraform

### Exercice 2 (ex2)

Here, the objective is to add names to all the ressources created on Exercice 1.

You will find in this [README](https://github.com/OlivierPaulo/DDChallenges/Terraform/ex2/README.md) the explanation on how I build on how I build this infrascture using Terraform.



## Ansible-basics

The *Ansible* folder contains code to cover the following exercice.

### Exercice 1 (ex1)

Here, the objective is to deploy a ghost blogging platform using _Terraform_ and _Ansible_.

You will find in this [README](https://github.com/OlivierPaulo/DDChallenges/Ansible/ex1/README.md) how I deploy it.


