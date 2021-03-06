 function Remove-Ping
 {
    param(
    [Parameter(Mandatory=$true,
        Position=0,
        ValueFromPipeline=$true,
        ParameterSetName='RemoveComputer')]
    [Alias('Server', 'ComputerName')]
    [uri]$Ping,
            
    # The name of the group to add the ping monitor
    [string]$Group
    )
    
    begin {
        if (-not ($script:PingList)) {
            $script:PingList = @{}
        }
    }
    process {
        if ($Group) {
            if ($script:PingList.$Group) {
                $script:PingList.$Group = @()
            }
        } else {
            foreach ($kv in @($script:PingList.GetEnumerator())) {
                if ($kv.Value | Where-Object { $_.Ping.ToString() -eq "$ping" }) {
                    $script:PingList.$kv.Key = @($kv.Value | Where-Object { $_.Ping.ToString() -ne "$ping" })
                }
            }
        }    
    }
 } 
