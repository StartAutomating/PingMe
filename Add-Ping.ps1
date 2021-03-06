 function Add-Ping
 {
    <#
    .Synopsis
        Adds a thing to ping
    .Description
        Adds a computer, DNS name, or URL to ping
    .Example
        # 'Pings' start-automating.com (really, downloads a webpage)
        Add-Ping start-automating.com     
    .Link
        Remove-Ping
    .Link
        Clear-Ping
    .Link
        Watch-Ping
    .Link
        Get-Ping
    #>
    [CmdletBinding(DefaultParameterSetName='WebTest')]
    param(
    # The server name,  DNS name, or URL to ping
    [Parameter(Mandatory=$true,
        Position=0,
        ValueFromPipeline=$true)]
    [Alias('Server', 'ComputerName')]
    [uri]$Ping,
    
    # If set, will do an old-fashioned "ping" request
    [Parameter(Mandatory=$true,ParameterSetName='PingTest')]
    [Switch]$Echo,
    
    # If set, will use the web client to ping the server.  This is great for ensuring that pages render
    [Parameter(ParameterSetName='WebTest')]
    [Switch]$WebClient,
    
    # If set, will ensure that PowerShell can connect to the server.    
    [Parameter(Mandatory=$true,ParameterSetName='PowerShellTest')]
    [Switch]$PowerShellConnection,

    # If set, resolves the name in DNS
    [Parameter(Mandatory=$true,ParameterSetName='DNSTest')]
    [Switch]$Dns,
            
    # The name of the group to add the ping monitor
    [string]$Group,
    
    # If set, outputs the ping object
    [switch]$PassThru
    )
    
    begin {
        #region Declare Ping List
        if (-not ($script:PingList)) {
            $script:PingList = @{}
        }
        #endregion
    }
    process {
        if (-not $Group) {
            $group = 'Default'
        }
        $pingData = @{} + $psBoundParameters
        if ($psCmdlet.ParameterSetName -eq 'WebTest' -and 
            -not $WebClient) {
            $pingData.Webclient = $true
        }
        $null = $pingData.Remove('PassThru')
        if (-not $script:PingList.$Group) 
        {
            $script:PingList.$group = @()
        }                    
        $pingObject = New-Object PSObject $pingData
        $script:PingList.$group += $pingObject
        if ($PassThru) {
            # region create ping object 
            $returnObject =New-Object PSObject -Property $pingData
            $returnObject.pstypenames.clear()
            $null = $returnObject.pstypenames.add('PingInfo')
            return $returnObject   
            # endregion         
        }
    
    }
 }