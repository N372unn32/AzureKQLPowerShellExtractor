function AzureKQLPowerShellExtractor {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [string]$kqlQuery
    )
    Write-Output "You entered: $InputString"
}

Export-ModuleMember -Function AzureKQLPowerShellExtractor