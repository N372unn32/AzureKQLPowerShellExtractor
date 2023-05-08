# AzureKQLPowerShellExtractor

This PowerShell module allows you to extract data from Microsoft Azure using ARG KQL Queries running via PowerShell. 

The extracted data can be exported in JSON, CSV or Excel format.

This module helps mitigate the export limitation of 51000 rows at a time in ARG Explorer when ARG KQL Queries are executed on Azure Portal.

For large output, the module has mitigations in place for throttling.

## Steps

### Using PowerShell Core



Import-Module .\AzureKQLPowerShellExtractor.psm1 -Force -Verbose

Get-AzureKQLPowerShellExtract -kqlQueryPath .\sample.kql




