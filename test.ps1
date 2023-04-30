Import-Module .\AzureKQLPowerShellExtractor.psm1 -Force -Verbose
#Disconnect-AzAccount
#Connect-AzAccount
Search-AzGraph -Query "resourcecontainers" -Subscription "7edb96ee-28a1-4dab-96f7-a0374a9d5dc8"
##Get-AzureKQLPowerShellExtract -kqlQuery .\samplekql.ps1
