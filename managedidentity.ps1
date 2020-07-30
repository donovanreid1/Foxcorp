# Creates a system assigned managed identity for VM
$vm = Get-AzVM -ResourceGroupName "devtest" -Name "linuxvm"
Update-AzVM -ResourceGroupName "devtest" -VM $vm -IdentityType "SystemAssigned"

#Creates a contributor role for that system assigned managed identity scoped to specfic storage account
$spID = (Get-AzVM -ResourceGroupName "devtest" -Name "linuxvm").identity.principalid
New-AzRoleAssignment -ObjectId $spID -RoleDefinitionName "Contributor" -Scope "/subscriptions/<917e32fe-361a-4bb7-aada-92f002a05a39>/resourceGroups/<devtest>/providers/Microsoft.Storage/storageAccounts/<istsolutionstesting>"