if ($env:COMPUTERNAME -eq "ORGANA")
{
    $ScriptRootPath = "D:\Tools\Scripts\POSH"
}
else
{
    $ScriptRootPath = "c:\dev\POSH"
}

Set-Location c:\

# Import modules
Import-Module $ScriptRootPath\Modules\File-Search.psm1
Import-Module $ScriptRootPath\Modules\Network.psm1
Import-Module $ScriptRootPath\Modules\Miscellaneous.psm1

if ($env:COMPUTERNAME -ne "ORGANA")
{
    Import-Module $ScriptRootPath\Modules\VAC-ACC.psm1
}

# Import data type so that we can get a prettier file size
# e.g. gci|select mode,lastwritetime,filesize,name
Update-TypeData -AppendPath $ScriptRootPath\Modules\shrf.ps1xml

#(Get-Host).UI.RawUI.BackgroundColor = "DarkBlue"
(Get-Host).UI.RawUI.ForegroundColor = "Gray"
(Get-Host).UI.RawUI.WindowTitle = "Michael's PowerShell"

$HistoryFileName = "$env:USERPROFILE\documents\posh_history.xml"

# Get username and if they are part of the administrators group
$Global:Admin=""
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.principal.windowsprincipal($CurrentUser)
if ($principal.IsInRole("Administrators")) 
{
    $Admin=" (Admin)"
}

# Display time, username, and path on the prompt
function prompt
{
    $host.ui.rawui.WindowTitle = $CurrentUser.Name + $Admin + "@" + $env:computername + " [" + $(get-location) + "]"
    Get-History -Count 1000 | Export-Clixml -Path $HistoryFileName

    Write-Host ("[ " + $(Get-Date).Tostring("HH:mm:ss") + " | " + $(Get-Location) + " ] $") -NoNewline -ForegroundColor Yellow 
    return " "
}

Import-Alias "$ScriptRootPath\Aliases.txt" -Force

if (Test-Path $HistoryFileName)
{
    Add-History -InputObject (Import-Clixml -Path $HistoryFileName)
}

Write-Host " "
& "$ScriptRootPath\UpTime.ps1"

if ($host.Name -eq 'Windows PowerShell ISE Host')
{
    #ISE specific code here

    $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Edit PowerShell Profile", { psedit  C:\Users\mmetcalfe\Documents\WindowsPowerShell\profile.ps1}, $null) | Out-Null
    
    # Import modules we only want in Powershell ISE
    #Import-Module "C:\dev\Scripts\PowerShell Modules\ISEScriptingGeek\ISEScriptingGeek.psd1"
    Import-Module "$ScriptRootPath\Modules\ISEUtilities.psm1"
    Import-Module "$ScriptRootPath\Modules\CommentSelectedLines.psm1" -DisableNameChecking

    # And, let's restore the last opened files too
    Import-ISEState -FileName "$env:USERPROFILE\documents\files.isexml"

    $DebugPreference = "Continue"
    $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Clear Variables and Modules", { Remove-Variable * -ErrorAction SilentlyContinue; Remove-Module *; $error.Clear(); Clear-Host; Write-Host "All variables and modules cleared." -ForegroundColor Green}, $null) | Out-Null
    $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Clear Console",{Clear-Host},"Ctrl+L") | Out-Null
}
elseif ($host.Name -eq 'ConsoleHost')
{
    If (-not (Test-Path $ScriptRootPath\log))
    {
        Write-Warning "Transcript directory '$ScriptRootPath\log' does not exist.  Creating."
        New-Item -ItemType Directory -Path "$ScriptRootPath\log" | Out-Null
    }
    $transcriptFile = "$ScriptRootPath\log\transcript$($(get-date).toString('yyyyMMdd-HHmmss')).log"

    # Try and stop the transcript (if one is running)
    try
    {
        Stop-Transcript | Out-Null
    }
    catch [System.InvalidOperationException]{}

    Start-Transcript $transcriptFile
}