# COSC2759 Assignment 2

## Student details

- Full Name: Nguyen Thanh Dat, Seyed Akeel Akthar Malik
- Student ID: s3975867, s3991933

## Solution design

Our solution automates the deployment of the Foo app, improving its resiliency and reliability. We use a combination of AWS services, Terraform for infrastructure provisioning, and Ansible for configuration management.

### Infrastructure

The infrastructure consists of:
- A VPC with two public subnets and one private subnet
- Two EC2 instances in public subnets for the application containers
- One EC2 instance in a private subnet for the database container
- An Application Load Balancer (ALB) to distribute traffic between the app instances
- Security groups to control inbound and outbound traffic

Here's a diagram of our infrastructure:

#### Key data flows

1. User requests come in through the internet to the ALB.
2. The ALB distributes requests to the two app instances.
3. App instances process requests and communicate with the database instance as needed.
4. The database instance is isolated in a private subnet and only accessible by the app instances.

### Deployment process

Our GitHub Actions workflow automates the deployment process:

1. Checkout the repository
2. Set up AWS credentials
3. Install Terraform and Ansible
4. Run Terraform to create the infrastructure
5. Run Ansible to configure instances and deploy containers
6. Validate the deployment

#### Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed
- Ansible installed
- Docker image for the Foo app available at mattcul/assignment2app:1.0.0

#### Description of the GitHub Actions workflow



#### Backup process: deploying from a shell script

In case GitHub Actions is unavailable, we provide a shell script (`deploy.sh`) that can be run locally:

1. Run Terraform to create the infrastructure
2. Generate an Ansible inventory file based on Terraform outputs
3. Run Ansible to configure instances and deploy containers
4. Display the ALB DNS name for accessing the application

#### Validating that the app is working

To validate the deployment:
1. Access the application using the ALB DNS name
2. Navigate to the `/foos` page to ensure the database connection is working
3. Test basic functionality of the app
4. Monitor the EC2 instances and ALB in the AWS Console

## Contents of this repo

- `main.tf`: Terraform configuration for infrastructure
- `deploy.yml`: Ansible playbook for instance configuration and container deployment
- `deploy.sh`: Shell script for local deployment
- `.github/workflows/deploy.yml`: GitHub Actions workflow configuration
- `misc/snapshot-prod-data.sql`: Database snapshot for initialization
- `README.md`: This file, containing project documentation


