function Login () {
    $context = Get-AzContext
    if (!$context) {
        Connect-AzAccount
        if ($? -eq "False") {
            <# Action to perform if the condition is true #>
            throw "Error: Connect to Azure Account to proceed"

        }
    }
    else {
        Write-Host "Connected to Azure"

    }
}

function Get-AzureKQLPowerShellExtract {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [string]$kqlQuery
    )

    Login
    Write-Output "You entered: $kqlQuery"


    Write-host "Querying for data" #-ForegroundColor Blue -BackgroundColor Red
    $query = Get-Content $kqlQuery -Raw

    # Set the batch size (number of rows to fetch at a time)
    $batchSize = 1000

    # Initialize variables to keep track of the current batch and the total number of rows fetched
    $currentBatch = 0
    $totalRows = 0

    # Initialize the skip token
    $skipToken = $null

    # Initialize an array to store all the results
    # $allResults = @()

    # Fetch data in batches until there are no more rows to fetch
    do {
        # Run the query using the Search-AzGraph cmdlet with the Skip and SkipToken parameters
        $results = Search-AzGraph -Query $query -First $batchSize -SkipToken $skipToken

        # Add the results to the array of all results
        # $allResults += $results
        $results | Export-Csv -Path .\result.csv -NoTypeInformation

        # Update the skip token for the next batch
        $skipToken = $results.SkipToken

        # Increment the current batch number and update the total number of rows fetched
        $currentBatch++
        

       # Write-Progress -Activity "Fetching data" -Status "Fetched $totalRows rows so far" -PercentComplete (($totalRows / $type["UsualRows"]) * 100) 

        $totalRows += $results.Count
    } while ($null -ne $skipToken)

    # Display the total number of rows fetched
    Write-Host Fetched a total of $totalRows rows  -ForegroundColor Red -BackgroundColor Blue

}

Export-ModuleMember -Function Get-AzureKQLPowerShellExtract

    


