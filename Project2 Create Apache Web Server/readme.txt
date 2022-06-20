A few things I'd like to address before we begin.

1. Sharing Access Keys the way I'm asking in the code is obviously not the most secure way
2. Generating pem files for ssh keypairs is also not very secure (with a few caveats)

What Terraform Creates:

1. VPC
2. Internet Gateway
3. Routing Table
4. Subnet (associated to routing table)
6. Security Groupd with rules to allow http, https, & ssh
7. Network Interface (Virtual NIC)
8. Elastic IP (associated to SG)
9. SSH Key-Pair Variable + Resource (Default name is tempkey)
10. EC2 Instance with Userdata to download Apache Web Server



Add Access Keys (Lines 13-14)


After applying, go to aws console > ec2 instance > CheemaUbuntu > Copy public ip and paste into new tab to make sure the message appears

Under EC2, you can also find and access all other components created


In order to access the ec2 instance, there will be a file generated in the same folder as main.tf, remove any extra strings in the .pem extension (I had a trailing question mark at the end of the pem file extension which I had to manually remove in order for the pem key to work) 

This code was written on macOS and may have attributes of unix for creating the ssh key pair, please let me know if there any issues.

Resources:
Terraform Docs
StackOverflow: https://stackoverflow.com/questions/49743220/how-do-i-create-an-ssh-key-in-terraform
Youtube: https://www.youtube.com/watch?v=SLB_c_ayRMo&list=PLLe4nR5jrq50GMl2WoWDyoX1aETRhOqBt&index=1&t=6635s

