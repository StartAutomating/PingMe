function Get-Ping
{
    <#
    .Synopsis
        Gets things to ping
    .Description
        Gets things to ping, and resolves the ping if you use -Resolve.
    .Example
        Get-Ping
    .Example
        Get-Ping -Resolve
    .Link
        Add-Ping
    .Link
        Remove-Ping
    .Link
        Clear-Ping
    .Link
        Watch-Ping
    #>    
    [CmdletBinding(DefaultParameterSetName='All')]
    param(
    # The server name,  DNS name, or URL to ping
    [Parameter(Mandatory=$true,
        Position=0,
        ValueFromPipeline=$true,
        ParameterSetName='Computer')]
    [Alias('Server', 'ComputerName', 'Destination')]
    [uri]$Ping,
            
    # The name of the group to add the ping monitor
    [string]$Group,
    
    # If set, performs the actual ping validation
    [switch]$Resolve    
    )
    
    begin {
        $outputPingResult = {
            $result = New-Object PSObject -Property @{
                Pinged = $pinged
                Destination = $pingObject.Ping
                Result = $pingResult 
                PingType = $pingType
            }
            $result.pstypenames.clear()
            $result.pstypenames.add('PingResult')
            $result
        }
        $ResolvePing = {
            $pingObject = $_
            if (-not $resolve) { 
                if ($pingObject) {
                    $returnObject =New-Object PSObject -Property $pingObject 
                    $returnObject.pstypenames.clear()
                    $null = $returnObject.pstypenames.add('PingInfo')
                    return $returnObject
                }
            }
            $pingType = if ($pingObject.Echo) {
                "Echo"
            } elseif ($pingObject.WebClient) {
                "Web"
            } elseif ($pingObject.Dns) {
                "Dns"
            } elseif ($pingObject.Dns) {
                "PowerShell"
            }

            if ($PingObject.Echo) {
                $pingResult = ping $pingObject.Ping -n 1 
                $pinged = if ($pingResult | ? {$_ -like "*(100%*" }) {
                    $false
                } else {
                    $true
                }
                . $outputPingResult                                    
            }
            if ($PingObject.WebClient) {
                $wc = New-Object Net.Webclient               
                $pinged = $false 
                $pingResult  = try {
                    $wc.DownloadString("$($pingObject.ping)")
                    $pinged = $true
                } catch {
                    $_
                }
                . $outputPingResult
                
            }
            if ($pingObject.DNS) {
                Add-Type -AssemblyName System.Net
                $pinged = $false
                $pingResult = try {
                    [Net.Dns]::Resolve($pingObject.Ping)
                    $pinged = $true
                } catch {
                    $_
                }
                . $outputPingResult                
            }
            if ($PingObject.PowerShellConnection) {
                $issue = $null
                $psConn = Invoke-Command -ComputerName $pingObject.Ping -ScriptBlock { Get-Command } -ErrorAction SilentlyContinue -ErrorVariable issue
                $pinged = $false
                if ($issue) {
                    $pingResult = $issue
                } elseif ($psConn) {
                    $pinged = $true
                    $pingResult = $psConn                    
                }
                . $outputPingResult
            }
                   
        }
    }
    
    process {
        if ($PsCmdlet.ParameterSetName -eq 'All') {
            $script:PingList.Values | 
                ForEach-Object { $_ } |                
                ForEach-Object $ResolvePing
        } elseif ($psCmdlet.ParameterSetName -eq 'Computer') {
            $script:PingList.Values | 
                ForEach-Object { $_ } |
                Where-Object { $_.Ping -eq $ping } |
                ForEach-Object $ResolvePing
                
        } elseif ($psCmdlet.ParameterSetName -eq 'Group') {
            if ($script:PingList.$Group) {
                $script:PingList.$Group | Get-Ping -Resolve:$Resolve
            }
        }
    }    
} 
