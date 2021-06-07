# Terraform Basics

## Exercice 2

As a reminder here, the objective is to **add names** to all the ressources created on Exercice 1.

This exercice 2 folder contains all the code done in exercice 1* plus a tag Naming addition in **all resources** created in the infrastructure, as examples below two of them:

### EC2 Instance

```terraform
...
  tags = {
    Name = "EC2-Server"
  }
...
```

### RDS Machine

```terraform
...

  tags = {
    Name = "AWS-POSTGRE-DB"
  }
...
```

**please see this [README](https://github.com/OlivierPaulo/DDChallenges/tree/main/Terraform/ex1#terraform-basics) if you want to see explanations on how the infrastructure was build for exercice 1*
