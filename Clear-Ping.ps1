function Clear-Ping
{
    <#
    .Synopsis
        Clears the ping cache
    .Description
        Clears the ping cache
    .Example
        Clear-Ping
    #>
    param()
    
    $script:PingList = @{}
} 
