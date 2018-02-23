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
###        [Parameter(Mandatory=$true)]
        [ValidateSet("mp_dev_db", "r2ua")]
        [string]$DatabaseName
    )
    $registryPath = "HKLM:\Software\Wow6432Node\VAC-ACC\BRP\R2 csdn"
    $registryKey = "Database Connect"
    $csdn = Get-ItemProperty -Path "HKLM:\Software\Wow6432Node\VAC-ACC\BRP\R2 csdn" -ErrorAction SilentlyContinue
    if($csdn.'Database Connect')
    {
        #Write-Host ("Changing CSDN Database from {0} to {1}." -f ($csdn.'Database Connect', $DatabaseName))
        Write-Host -NoNewline ("Changing CSDN Database from {0} to {1}." -f ($csdn.'Database Connect', $DatabaseName))
        Set-ItemProperty -Path $registryPath -Name $registryKey -Value $DatabaseName
    }
    else
    {
        Write-Host "There was a problem locating the registry path: $registryPath" -ForegroundColor Red
    }
}
New-Alias -Name setcsdn -Value Set-CSDNDatabase -Description "Set the CSDN database to use."

function Get-CSDNDatabase
{
    <#
        .SYNOPSIS
        Get the CSDN database that is currently set.
        
        .DESCRIPTION
        This cmdlet will get the CSDN database value from the registry (HKLM:\Software\Wow6432Node\VAC-ACC\BRP\R2 csdn\Database Connect)
        
        .NOTES
        NAME        :  Get-CSDNDatabase
        VERSION     :  1.0   
        LAST UPDATED:  17/08/2017
        AUTHOR      :  Michael Metcalfe
        .INPUTS
        None
        .OUTPUTS
        None
    #>
    $registryPath = "HKLM:\Software\Wow6432Node\VAC-ACC\BRP\R2 csdn"
    $registryKey = "Database Connect"
    $csdn = Get-ItemProperty -Path "HKLM:\Software\Wow6432Node\VAC-ACC\BRP\R2 csdn" -ErrorAction SilentlyContinue
    if($csdn.'Database Connect')
    {
        return $csdn.'Database Connect'
    }
}
New-Alias -Name getcsdn -Value Get-CSDNDatabase -Description "Get the value of the CSDN database."

function Update-CSDN
{
    <#
        .SYNOPSIS
        Update the local copy of the CSDN app.
        
        .DESCRIPTION
        This cmdlet will update the local installation of CSDN.

        .PARAMETER Clean
        Perform a clean update by deleting the local copy first.

        .PARAMETER Force
        If CSDN is running, use this parameter to kill it without prompting.

        .NOTES
        NAME        :  Update-CSDN
        VERSION     :  1.0   
        LAST UPDATED:  2018-02-23
        AUTHOR      :  Michael Metcalfe
        .INPUTS
        None
        .OUTPUTS
        None
    #>
    [CmdletBinding()]
    param
    (
        [switch]$Clean,
        [switch]$Force
    )
    $LOCAL_INSTALLATION_DIRECTORY = "C:\corp\csdn\MAINT_FT_FLDR\bin"
    $REMOTE_INSTALLATION_DIRECTORY = "\\VAHCMN01\CDE\corp\CSDN\MAINT_FT_FLDR\bin"

    if (Get-Process -Name "csdn")
    {
        Add-Type -AssemblyName System.Windows.Forms;
        $response = [System.Windows.Forms.MessageBox]::Show('CSDN is running.  Do you want to kill it?', 'Warning', 3, 'Question')

        if ($response -eq 'Yes')
        {
            Stop-Process -Name "csdn" -Force -ErrorAction Stop;
        }
        elseif ($response -eq 'Cancel')
        {
            return;
        }
    }

    if ($Clean)
    {
        Write-Debug "Cleaning local copy...";
        Remove-Item -Recurse -Force -Path $LOCAL_INSTALLATION_DIRECTORY;
        New-Item -Type Directory $LOCAL_INSTALLATION_DIRECTORY | Out-Null;
    }

    Write-Host -ForegroundColor Cyan "Copying CSDN files...";
    Copy-Item -Path "$REMOTE_INSTALLATION_DIRECTORY\*" -Destination $LOCAL_INSTALLATION_DIRECTORY -Recurse -ErrorAction Continue
}

Export-ModuleMember -Function * -Alias *