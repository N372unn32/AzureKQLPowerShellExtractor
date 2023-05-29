Import-Module .\AzureKQLPowerShellExtractor.psm1 -Force -Verbose
#Disconnect-AzAccount
#Connect-AzAccount
#Search-AzGraph -Query "resourcecontainers" 
Get-AzureKQLPowerShellExtract -kqlQueryPath .\sample.kql -inCSV
