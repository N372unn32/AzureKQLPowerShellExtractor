Import-Module .\AzureKQLPowerShellExtractor.psm1 -Force -Verbose
#Disconnect-AzAccount
#Connect-AzAccount
#Search-AzGraph -Query "resourcecontainers" j
Get-AzureKQLPowerShellExtract -kqlQuery .\sample.kql
