So I made a bit of changes.

First off it is impossible to build a VNET with address space /26 followed by a sub-net with /24.

-26 has 64 address spaces while /24 has 256 address spaces.

Second I was able to build all the infrastructure in Terraform up to step 5/6.

Instead I used Power-Shell, basically my native language to attach the managed identity to the VM and give it contributor access to the storage account. step 5/6

Technically this is all still infrastructure as code.

I hope this improvisation does not affect my results.


Infrastructure deployment:

To deploy the infrastructure navigate to azure cli bash prompt:

Run:
Code Foxcorp.tf
- paste terraform code into document
- Ctrl s save
- ctrl q to exit

terraform init
terraform plan
terraform apply

The powershell code will have to be changed to match the subscription.