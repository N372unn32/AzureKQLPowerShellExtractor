
function Get-AzureKQLPowerShellExtract {
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 0)]
        [string]$kqlQueryPath = "empty",
        [switch]$inExcel = $false,
        [switch]$inJSON = $false,
        [switch]$h = $false,
        [switch]$inCSV = -not ($inJSON -and $inExcel)
    )


    if ($h) {
        help
        return
    }

    if ($kqlQueryPath -eq "empty") {
        Write-Error "Path to the KQL Query is missing. Please provide the path to the KQL Query and pass it to the -kqlQueryPath Argument"  -Category InvalidArgument
        return
    }

    Write-Host "Export format selected - Excel: $inExcel, CSV: $inCSV, JSON: $inJSON" -ForegroundColor Yellow
    Login
    Write-host "Querying for data" -ForegroundColor Yellow
    $query = Get-Content $kqlQueryPath -Raw
    $queryRows = $query + " |  summarize count() "
    $RowsResult = Search-AzGraph -Query $queryRows 
    $ResultRows = $RowsResult.count_
    Write-Host Total $ResultRows rows to be fetched  -ForegroundColor Blue
    $batchSize = 1000
    $totalRows = 0
    #$skipToken = $null
    $JSONdata = $null


    Exists -Excel inExcel -CSV inCSV -JSON inJSON



    # Set initial values
  
    $throttleLimit = 15
    $throttleWindow = 5
    $remainingQuota = $throttleLimit
    $lastRequestTime = Get-Date

    $subscriptions = Get-AzSubscription
    $subscriptionIds = $subscriptions.Id

    # Grouping queries by subscription


    foreach ($ID in $subscriptionIds) {
        $skipToken = $null
        $retryCount = 0
        do {
            # Staggering queries
            if ($remainingQuota -le 0) {
                $timeSinceLastRequest = (Get-Date) - $lastRequestTime
                if ($timeSinceLastRequest.TotalSeconds -lt $throttleWindow) {
                    Start-Sleep -Seconds ($throttleWindow - $timeSinceLastRequest.TotalSeconds)
                }
                $remainingQuota = $throttleLimit
            }


            try {
                $results = Search-AzGraph -Query $query -First $batchSize -SkipToken $skipToken -Subscription $ID
    
                # Output data
                if ($inJSON -eq $true) {
                    $JSONdata += $results
                }
                if ($inExcel -eq $true) {
                    $P = "result.xlsx"
                    $results | Export-Excel -Path $P -Append
                }
                if ($inCSV -eq $true) {
                    $P = "result.csv"
                    $results | Export-Csv -Path $P -Append -NoTypeInformation
                }
        
                # Update skip token and progress
                $skipToken = $results.SkipToken
                Write-Progress -Activity "Fetching data" -Status "Fetched $totalRows rows so far" -PercentComplete (($totalRows / $ResultRows) * 100)
                $totalRows += $results.Count
        
                # Update remaining quota and last request time
                $remainingQuota--
                $lastRequestTime = Get-Date
                $retryCount = 0
            }
            catch {
                <#Do this if a terminating exception happens#>
                Write-Error $_.Exception.Message

                # Handle error and retry or skip batch if necessary
                $retryCount++
                if ($retryCount -gt 3) {
                    Write-Warning "Failed to query data after $retryCount attempts. Skipping batch."
                    break
                }
                else {
                    Write-Warning "Error encountered during query. Retrying in 20 seconds..."
                    Start-Sleep -Seconds 20
                }


            }
            # Query data
           
        } while ($null -ne $skipToken)
    
    }

    if ($inJSON -eq $true) {
        $json = $JSONdata | ConvertTo-Json 
        $json | Out-File "result.json"
    }
    Write-Host "Fetched a total of $totalRows rows available at $PWD "-ForegroundColor Green
}












    
# do {
#     $results = Search-AzGraph -Query $query -First $batchSize -SkipToken $skipToken
#     #  Output -data $results -Excel $inExcel -CSV $inCSV 

#     if ($inJSON -eq $true) {
#         $JSONdata += $results

#     }
#     if ($inExcel -eq $true) {
            
#         $P = "result.xlsx"
#         $results | Export-Excel -Path $P -Append    
#     }
#     if ($inCSV -eq $true) {
#         $P = "result.csv"  
#         $results | Export-Csv -Path $P  -Append -NoTypeInformation 
#     }

#     $skipToken = $results.SkipToken
#     $currentBatch++
#     Write-Progress -Activity "Fetching data" -Status "Fetched $totalRows rows so far" -PercentComplete (($totalRows / $ResultRows) * 100) 
#     $totalRows += $results.Count
# } while ($null -ne $skipToken)




function Login () {
    $context = Get-AzContext
    if (!$context) {
        Connect-AzAccount
        if ($? -eq "False") {
            Write-Error "Error: Connect to Azure Account to proceed" -RecommendedAction "Disconnect using Disconnect-AzAccount and reconnect using Connect-AzAccount" 
        }
    }
    else {
        Write-Host "Connected to Azure" -ForegroundColor Green
        Write-Host "Connected Account" $(Get-AzContext).Account "to" $(Get-AzContext).Tenant.Id
    }
}


function help () {
    
    Write-Host "Description" -ForegroundColor Green
    Write-Host "
    With this script you will be able to generate the results of Azure Resource Graph (ARG) queries locally in csv, excel or json format.
    This script also helps to mitigate the limitation of running ARG queries on Azure Resource Graph Explorer on Azure Portal and the maximum rows that can be downloaded at a time per query. Project and documentation is available at - https://github.com/G-Lucifer/AzureKQLPowerShellExtractor .
    The new results file will generated from where the Get-AzureKQLPowerShellExtract is invoked." 
    Write-Host "Examples" -ForegroundColor Green
    Write-Host "To generate a CSV file " 
    Write-Host "Get-AzureKQLPowerShellExtract .\sample.kql -inCSV" -ForegroundColor Yellow
    Write-Host "To generate a JSON file " 
    Write-Host "Get-AzureKQLPowerShellExtract -kqlQueryPath .\sample.kql -inJSON" -ForegroundColor Yellow
    Write-Host "To generate an Excel file " 
    Write-Host "Get-AzureKQLPowerShellExtract -kqlQueryPath .\sample.kql -inExcel" -ForegroundColor Yellow
    Write-Host "To generate all three types of file " 
    Write-Host "Get-AzureKQLPowerShellExtract -kqlQueryPath .\sample.kql -inCSV -inExcel -inJSON" -ForegroundColor Yellow
    Write-Host "Arguments" -ForegroundColor Green
    Write-Host "-kqlQueryPath    {Mandatory Parameter, Postitional Argument, Requires Path to the KQL file}" 
    Write-Host "-inExcel   {Optional Flag, Mention this to generate result.xlsx file}" 
    Write-Host "-inJSON     {Optional Flag, Mention this to generate result.json file}" 
    Write-Host "-inCSV    {Optional Flag, Mention this to generate result.csv file}" 
    Write-Host "-h    {Optional Flag, Mention this for help}" 

       





        
}


function Exists () {
    param(
                
        [switch]$Excel = $false,
        [switch]$CSV = $false,
        [switch]$JSON = $false
            
    )

    
    if (($inJSON -eq $true) -and (Test-Path -Path "result.json") ) {
        Write-Information "Removing the existing result.json file" 
        Remove-Item "result.json"
        
    }
    if (($inExcel -eq $true) -and (Test-Path -Path "result.xlsx") ) {
        Write-Information "Removing the existing result.xlsx file" 

        Remove-Item "result.xlsx"
      
    }
    if (($inCSV -eq $true) -and (Test-Path -Path "result.csv") ) {
        Write-Information "Removing the existing result.csv file" 

        Remove-Item "result.csv"
        
    }


}
# function Output () {
#     param(
#         [Parameter(Mandatory = $true)]
#         $data,
#         [switch]$Excel = $false,
#         [switch]$CSV = $false
    
#     )
#     Write-Host "Excel: $Excel, CSV: $CSV"

#     if ($Excel) {
#         $P =  "result.xlsx"
#         $data | Export-Excel -Path $P -Append    
#         Write-Host "p is $P"
#     }
#     if ($CSV) {
#         $P ="result.csv"  
#         $data | Export-Csv -Path $P  -Append -NoTypeInformation 
#         Write-Host "p is $P   "
#     }
# }

Export-ModuleMember -Function Get-AzureKQLPowerShellExtract

    


