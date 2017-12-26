# apache-tomcat-automation

Creating a Highly Available apache-tomcat cluster with ansible, packer &amp; terraform
There are 3 parts of this automation:
1. Create a VPC with public &amp; Private subnets using Terraform
2. Use Packer &amp; ansible to create an ami which has apache with one tomcat server running. Also we will deploy one test application using ansible.
3. Create ELB, security groups and autoscaling group with scaling policies.
