function Set-CSDNDatabase
{
    <#
        .SYNOPSIS
        Set the CSDN database to use.
        
        .DESCRIPTION
        This cmdlet will set the CSDN database to use in the registry (HKLM:\Software\Wow6432Node\VAC-ACC\BRP\R2 csdn\Database Connect)
        
        .PARAMETER DatabaseName
        The CSDN database name to set.
        
        .EXAMPLE
        PS C:\> Set-CSDNDatabase -DatabaseName r2ua
        Will set the CSDN database to r2ua.
        
        .NOTES
        NAME        :  Set-CSDNDatabase
        VERSION     :  1.0   
        LAST UPDATED:  15/08/2017
        AUTHOR      :  Michael Metcalfe
        .INPUTS
        None
        .OUTPUTS
        None
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet("mp_dev_db", "r2ua")]
        [string]$DatabaseName
    )
    $registryPath = "HKLM:\Software\Wow6432Node\VAC-ACC\BRP\R2 csdn"
    $registryKey = "Database Connect"
    $csdn = Get-ItemProperty -Path "HKLM:\Software\Wow6432Node\VAC-ACC\BRP\R2 csdn" -ErrorAction SilentlyContinue
    if($csdn.'Database Connect')
    {
        Write-Host ("Changing CSDN Database from {0} to {1}." -f ($csdn.'Database Connect', $DatabaseName))
        Set-ItemProperty -Path $registryPath -Name $registryKey -Value $DatabaseName
    }
    else
    {
        Write-Host "There was a problem locating the registry path: $registryPath" -ForegroundColor Red
    }
}

Export-ModuleMember -Function Set-CSDNDatabase