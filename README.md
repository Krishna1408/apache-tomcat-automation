# apache-tomcat-automation

## Overview

We aim to create a Highly Available apache-tomcat cluster with ansible, packer and terraform. This automation is supported currently for **Ubuntu** only.

There are 3 parts of this automation:
 1. Using **Terraform** creating a VPC with public and private subnets.
 2. Create an ami which has apache, tomcat & one sample application configured using  **Packer** and **Ansible**
 3. Create ELB, security groups and autoscaling group with scaling policies using **Terraform**

The **Ansible** playbook to install and configure Apache-Tomcat is included independently as well in case user does not want to use packer.

## Prerequisites

- ###### We are tagging the resources getting created through terraform and packer. These resources are called later during Autoscaling Group Creating using terraform **data resources**.
 
- ###### Use of tags reduces the human errors and simplify the code. Hence, in case VPC is not created using the given Terraform code then the subnets must be tagged as below:
    Name: `tag_name`a\b\c
```YAML
Example:
  For subnet of Public AZ 1:
    Name: public_subneta
    
  For subnet of Public AZ 2:
    Name: public_subnetb
    
  For subnet of Public AZ 3:
    Name: public_subnetc
```
- ###### For packer automation to create AMI, we are using Ubuntu 16.04 OS. User need to get this AMI ID and enter in Packer variables file manually. In case user want to avoid doing it then Packer and auto fetch the AMI ID, the code for that is given in **info.txt** file inside **Create AMI** directory.
