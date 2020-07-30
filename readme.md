I have made a few changes.

First off, it is impossible to build a VNET with an address space /26 followed by a sub-net with /24.

/26 has 64 address spaces while /24 has 256 address spaces.

I added the role definition and the role assignment to the linux vm.

The role definition is scoped to the istsolutions storage account and gives contributor access.

The role assignment is scoped to the linuxvm and assigns the role definition.

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
