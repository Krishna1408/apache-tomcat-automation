# apache-tomcat-automation

## Overview

We aim to create a Highly Available apache-tomcat cluster with ansible, packer and terraform.

There are 3 parts of this automation:
 1. Using [Terraform] creating a VPC with public and private subnets.
 2. Create an ami which has apache, tomcat & one sample application configured using  [Packer] and [Ansible]
 3. Create ELB, security groups and autoscaling group with scaling policies using [Terraform]
