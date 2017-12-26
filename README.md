# apache-tomcat-automation

## Overview

We aim to create a Highly Available apache-tomcat cluster with ansible, packer and terraform. This automation is supported currently for **Ubuntu** only.

There are 3 parts of this automation:
 1. Using **Terraform** creating a VPC with public and private subnets.
 2. Create an ami which has apache, tomcat & one sample application configured using  **Packer** and **Ansible**. The AJP connection is used between apache & tomcat.
 3. Create ELB, security groups and autoscaling group with scaling policies using **Terraform**

- The **Ansible** playbook to install and configure Apache-Tomcat is included independently as well in case user does not want to use packer.
- I've used Amazon Linux box to setup the automation instance where I've configured Terraform, Ansible & Packer.
## Prerequisites

- ##### We are tagging the resources getting created through terraform and packer. These resources are called later during Autoscaling Group Creating using terraform **data resources**.
 
- ##### Use of tags reduces the human errors and simplify the code. Hence, in case VPC is not created using the given Terraform code then the subnets must be tagged as below:
    Name: `tag_name`a\b\c
```YAML
Example for tag named "public_subnet":
  For subnet of Public AZ 1:
    Name: public_subneta
    
  For subnet of Public AZ 2:
    Name: public_subnetb
    
  For subnet of Public AZ 3:
    Name: public_subnetc
```
- ##### For packer automation to create AMI, we are using Ubuntu 16.04 OS. User need to get this AMI ID and enter in Packer variables file manually. In case user want to avoid doing it then Packer and auto fetch the AMI ID, the code for that is given in **info.txt** file inside **Create AMI** directory.

### Creating VPC Using Terraform

The code given in **1-Create VPC** is use to setup a new VPC. It creates:
1. A VPC
2. Three Public Subnets. They are created with tag `Name = public_subneta \ public_subnetb \ public_subnetc`
3. Three Private Subnets.

To setup Terraform:
1. Download Terraform (linux) from: https://www.terraform.io/downloads.html
2. Extract the zip and move the terraform binary in /usr/sbin directory
#### Terraform variables
The following variables can be modified by the user. User need to edit **1-Create VPC/variables.tf** file

  - `access_key`: AWS access key for user's project
  - `secret_key`: AWS secret Key for User's project
  - `aws_region`: Region to use Default is ap-southeast-2
  - `vpc_cidr`: CIDR for whole VPC, default is 192.168.0.0/22
  - `public_subnet_cidr_a\b\c`: CIDRs for the public subnets. The default values are given in the variables.tf file.
  - `private_subnet_cidr_a\b\c`: CIDRs for the private subnets. The default values are given in the variables.tf file.

#### Running Terraform 

Once all the info is correctly entered in variables.tf file user need to run below from **1-Create VPC**:
- To initialize terraform: `terraform init`  
- To check the different resources being created: `terraform plan`
- To create the resources: `terraform apply`


### Creating AMI Using Packer 

Creating AMI part consist of Packer and Ansible which are integrated together. This part focuses on Packer configs.
The default AMI is created with Tag `Name = apache-tomcat-0.1`

To setup Packer:
1. Download Packer (linux) from: https://www.packer.io/downloads.html
2. Extract the zip and move the packer binary in /usr/sbin directory
#### Packer Variables

The following variables can be modified by the user. User need to edit **2-Create AMI/vars.json** file
  - `aws_access_key`: AWS access key for user's project
  - `aws_secret_key`: AWS secret Key for User's project
  - `aws_region`: Region to use Default is ap-southeast-2
  - `aws_ami_image`: Ubuntu ami Id for the specific region.
  - `aws_instance_type`: The instance type with which the ami will be created by packer.
  - `image_version`: In case more images are created using the same automation this can be used to add versions. Default value is **0.1**. AMI created is **Name = apache-tomcat-0.1**

```JSON 
Below is the example config available:
{
    "aws_access_key": "",
    "aws_secret_key": "",
    "aws_region": "ap-southeast-2",
    "aws_ami_image": "ami-cab258a8",
    "aws_instance_type": "t2.small",
    "image_version" : "0.1"
}
```

#### Running Packer

Go to the directory 2-Create AMI and run: 
- packer build -var-file=vars.json apache-ami.json

#### Integration with Ansible

To Integrate packer with Ansible:
1. The ansible code is copied ino the playbook directory inside Create AMI directory
2. The ansible provisioner is then used to integrate ansible with packer.
3. Once a system is created with AMI the apache & tomcat services will be up and running.


### Ansible Playbook to install and configure apache & tomcat

1. The ansible playbook is integrated with Packer. As well same playbook is provided separately "Independent apache-tomcat Configuration.
2. The ansible version tested is 2.3.1 but playbook should also support 2.4
3. The playbook does below:
    - Install and configures apache
    - Install and configure tomcat (version 8) and Create tomcat service file.
    - Ensure that only AJP connector is used between Apache & Tomcat.
    - Deploy a sample application "clusterjsp" in the end of automation.

#### Ansible variables
The following variables can be modified by the user. User need to edit **2-Create AMI/playbook/variables.yml** file
  - `java_home`: The java home being used to create tomcat service file. (Default: java-1.8.0-openjdk-amd64 )
  - `tomcat_url`: The url to download the tomcat .tar.gz file. (Default: http://apache.mirror.digitalpacific.com.au/tomcat/tomcat-8/v8.5.24/bin/apache-tomcat-8.5.24.tar.gz)

#### Running ansible playbook independently
1. All the instances where apache should be installed should have their IP's mentioned in "inventory.txt" file.
2. Run below command from "Independent apache-tomcat Configuration":
- ansible-playbook main.yml
3. The ansible logs will be created in **/tmp/ansible.log** file
4. The ansible configurations are mentioned in "ansible.cfg" file. User can modify them as per need basis.


### Creating Autoscaling Group using Terraform

1. Here we are using Terraform to create:
- Creates Security Groups
- Creates public key for user to use with launch configuration.
- Creates Elastic Load balancer
- Creates Launch Configuration & Autoscaling Group
- Creates policies for Autoscaling group for Increase & Decrease of number of instance as per CPU and Memory usage
- Creates CPU & Memory based Cloud Watch Metrics to be used with policy of autoscaling group.

2. Info about Autoscaling Group Created:

- The Desired and Minimum number of instances are 3.
- The maximum number of instances is 5.
- One additional instance is created when the CPU or Memory threshold crosses 80% with cool down of 300 seconds.
- One instance is removed when the CPU or Memory threshold drops below 20%.

3. In the end of terraform run, the ELB DNS is generated as output. That can be used to test the ASG created.
#### Terraform variables & Files

The following variables can be modified by the user. User need to edit **3- Create ASG/vars.tf** file
  - `access_key`: AWS access key for user's project
  - `secret_key`: AWS secret Key for User's project
  - `aws_region`: Region to use Default is ap-southeast-2
  - `filter_ami`: The tag name for AMI being used. The default is **apache-tomcat-0.1** (This is also the default tag created by packer)
  - `subnet_tag_name`: This is the name of Tag's **Key** being used. The default is **Name**.
  - `subnet_tag_value`: This is the tag's **value** being used. The default is **public_subnet** (This is also the default subnet name created by VPC code)
  - `instance_type`: The size of instance to be launched with autoscaling group.
  - `port_22_cidr`: The cidr for the Ip range which will be used for ssh to this instances. (E.g. 103.11.226.0/24)
  - `max_instance_asg`: The max limit for the instances in autoscaling group. (Default = 5)

For creation of key part:
1. Enter the public key in **key.pub** file.
2. If user does not want to create new key.pub then update the "key_name" part of "aws_launch_configuration" part in **3-Create ASG/create_autoscaling_group.tf** file :
```YAML
resource "aws_launch_configuration" "apache" {
  key_name        = "enter_your_key_name"
}
```

#### Running Terraform 

Once all the info is correctly entered in vars.tf file user need to run below from **2-Create ASG** directory:
- To initialize terraform: `terraform init`  
- To check the different resources being created: `terraform plan`
- To create the resources: `terraform apply`


## Testing the final setup

Take the output of ELB DNS created in the last terrafrom run, append clusterjsp to it and hit the url in brouwer:
http://ELB_DNS_GENERATED/clusterjsp

example: http://apache-elb-993864931.ap-southeast-2.elb.amazonaws.com/clusterjsp/

