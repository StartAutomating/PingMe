function Watch-Ping
{
    <#
    .Synopsis
        Watches the things to ping
    .Description
        Watches the things to ping
        
        Green is Good
        Red is Wrong        
    .Example
        Watch-Heatmap
    .Link
        Add-Ping
    .Link
        Remove-Ping
    .Link
        Get-Ping
    #>
    param(
    # If set, continously watches the heatmap
    [switch]$Continuous,
    
    # If set, waits this period of time between each sample of the heatmap    
    [Timespan]$WaitAfterGet = "0:0:0"
    )
    
    process {
        do {
            #region Get the values
            Get-Ping -Resolve
            #endregion Get the values
            
            #region Wait if needed
            if ($Continuous -and $WaitAfterGet.TotalMilliseconds) {
                Start-Sleep -Milliseconds $WaitAfterGet.TotalMilliseconds
            }
            #endregion Wait if needed
        } while ($continuous)
        
        
    }
} 
