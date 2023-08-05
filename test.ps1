Install-Module -Name AzureKQLPowerShellExtractor
Connect-AzAccount # you need to install the azure powershell module before you run this
Get-AzureKQLPowerShellExtract -kqlQueryPath .\sample.kql -inCSV
