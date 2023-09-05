# AzureKQLPowerShellExtractor

This PowerShell module allows you to extract data from Microsoft Azure using ARG KQL Queries running via PowerShell. 

The extracted data can be exported in JSON, CSV or Excel format.

This module helps mitigate the export limitation of 51000 rows at a time in ARG Explorer when ARG KQL Queries are executed on Azure Portal.

For large output, the module has mitigations in place for throttling.


## References

| Description | Link |
| ------ | ------ |
| Brief Documetation  | [Medium Blog](https://medium.com/@MTushar/extracting-large-azure-resource-graph-data-using-azurekqlpowershellextractor-d310b1601910) |

## Requirements

PowerShell Core

Azure PowerShell module

Import-Excel PowerShell module

## Steps

### Using PowerShell Core




<pre><code class="language-powershell">

#Import the PowerShell Module after cloning the repository
Import-Module .\AzureKQLPowerShellExtractor.psm1 -Force -Verbose

# run " Get-AzureKQLPowerShellExtract -h " for help and examples

# Call the Get-AzureKQLPowerShellExtract command and supply necessary arguments

# Replace ".\sample.kql" with the path to your ARG KQL Query. Simply create a text file with your KQL query as its content, e.g., sample.kql

Get-AzureKQLPowerShellExtract -kqlQueryPath .\sample.kql -inCSV


</code></pre>



