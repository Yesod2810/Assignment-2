#!/bin/bash
#
# Deploy Foo app - see README.md
#
set -e

echo "Testing AWS credentials"
aws sts get-caller-identity

cd infra

path_to_ssh_key="my_key"
echo "Creating SSH keypair ${path_to_ssh_key}..."
ssh-keygen -C ubuntu@ -f "${path_to_ssh_key}" -N ''

echo "Initialising Terraform..."
terraform init
echo "Validating Terraform configuration..."
terraform validate
echo "Running terraform apply, get ready to review and approve actions..."
terraform apply -auto-approve

# Get instance IP addresses
APP_INSTANCE_1_IP=$(terraform output -raw app_instance_1_public_ip)
APP_INSTANCE_2_IP=$(terraform output -raw app_instance_2_public_ip)
DB_INSTANCE_IP=$(terraform output -raw db_instance_private_ip)

# Create Ansible inventory
cat << EOF > inventory.ini
[app_instances]
app1 ansible_host=$APP_INSTANCE_1_IP
app2 ansible_host=$APP_INSTANCE_2_IP

[db_instance]
db ansible_host=$DB_INSTANCE_IP
EOF

# Run Ansible playbook
echo "Configuring instances and deploying containers with Ansible..."
ansible-playbook -i inventory.ini playbook.yml

# Get load balancer DNS name
LB_DNS_NAME=$(terraform output -raw lb_dns_name)

echo "Deployment complete!"
echo "Access the application at: http://$LB_DNS_NAME"
