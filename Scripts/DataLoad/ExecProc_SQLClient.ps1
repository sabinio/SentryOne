<#
.SYNOPSIS
Execute a stored procedure multiple times to simulate a crude workload

.DESCRIPTION
To easily create a workload by running a stored procedure multiple times in parallel, with optional randomized delays.

.PARAMETER InstanceName
The SQL Server instance name to run on.

.PARAMETER DatabaseName
The database where the stored procedure is located.

.PARAMETER StoredProcName
The name of the stored procedure to execute including the schema name

.PARAMETER ParamName
The name of the parameter to pass to the proc

.PARAMETER Threads
Number of parallel executions of the proc to run at the same time

.PARAMETER MinId
The minimum value to pass to the parameter defined in ParamName. This defines the lower bound of a randomizer

.PARAMETER MaxId
The maximum value to pass to the parameter defined in ParamName. This defines the upper bound of a randomizer

.PARAMETER MinDelay
The lower bound of the delay between executions in milliseconds

.PARAMETER MaxDelay
The upper bound of the delay between executions in milliseconds

.PARAMETER IterateSeconds
The number of seconds to run the procs in a loop before stopping

.NOTES
This proc is quite a crude way to run a simple single-valued stored procedure in a loop for demo purposes.
It could be extended to accept a hashtable of parameters.


Author: Mark Allison, Sabin.IO <mark.allison@sabin.io>

.EXAMPLE
.\ExecProc_SQLClient.ps1 `
    -InstanceName "SQL01" `
    -DatabaseName "WideWorldImporters" `
    -StoredProcName "Sales.GetBasket" `
    -ParamName BasketID `
    -Threads 20 `
    -MinId 1 `
    -MaxId 1000 `
    -MinDelay 10 `
    -MaxDelay 150 `
    -IterateSeconds $IterateSeconds

    This will run proc Sales.GetBasket with a BasketId ranging between 1 and 1000, with 20 parallel threads as background tasks. There will be a randomized delay on each thread varying between 10 and 150ms.
#>
   [cmdletbinding()]
param (
    [string][Parameter(Mandatory=$true)]$InstanceName,
    [string][Parameter(Mandatory=$true)]$DatabaseName,
    [string][Parameter(Mandatory=$true)]$StoredProcName,
    [string][Parameter(Mandatory=$true)]$ParamName,
    [string][Parameter(Mandatory=$true)]$Threads,
    [string][Parameter(Mandatory=$true)]$minId,
    [string][Parameter(Mandatory=$true)]$maxId,
    [string][Parameter(Mandatory=$false)]$minDelay=10,
    [string][Parameter(Mandatory=$false)]$maxDelay=100,
    [int]$IterateSeconds # number of Seconds to run in a loop
)

for ($i=1; $i -le $Threads; $i++) {
    Start-Job -ScriptBlock {
        $StartTime = Get-Date
        $conn = New-Object System.Data.SqlClient.SqlConnection
        $conn.ConnectionString = "Data Source=$($using:InstanceName);Initial Catalog=$($using:DatabaseName);Integrated Security=SSPI;Application Name=PowerShell.SabinDataLoader;"
        $conn.Open()
        do {

            $id = (Get-Random -Minimum $using:minId -Maximum $using:maxId)
            $SleepMs = (Get-Random -Minimum $using:minDelay -Maximum $using:maxDelay)
            $cmd = $Null
            $cmd = New-Object System.Data.SqlClient.SqlCommand
            $cmd.connection = $conn
            $cmd.CommandType = [System.Data.CommandType]::StoredProcedure
            $cmd.Parameters.AddWithValue("@$($using:ParamName)",$id) | Out-Null
            $cmd.commandtext = $using:StoredProcName
            $result = $cmd.executenonquery()
            Start-Sleep -Milliseconds $SleepMs
        }
        While ((Get-Date) -le $StartTime.AddSeconds($using:IterateSeconds))
        $conn.close()
    }
}
#Get-Job | Wait-Job
#Get-Job | Remove-Job