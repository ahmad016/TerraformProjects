Main.tf

- Creates an EC2 instance
- Creates a VPC, Security Group & Elastic ip for instance

Outputs.tf

- Outputs instance id, public ip, vpc id

Variables.tf

- Allows to change the EC2 instance name
In the terminal, you can input: ' terraform apply -var "instance_name=[Choose Name]" '