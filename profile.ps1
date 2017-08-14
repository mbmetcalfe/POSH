Set-Location c:\

# Import modules
Import-Module $PSScriptRoot\Modules\File-Search.psm1
Import-Module $PSScriptRoot\Modules\Network.psm1
Import-Module $PSScriptRoot\Modules\Miscellaneous.psm1 -DisableNameChecking

# Import data type so that we can get a prettier file size
# e.g. gci|select mode,lastwritetime,filesize,name
Update-TypeData -AppendPath $PSScriptRoot\Modules\shrf.ps1xml

#(Get-Host).UI.RawUI.BackgroundColor = "DarkBlue"
(Get-Host).UI.RawUI.ForegroundColor = "Gray"
(Get-Host).UI.RawUI.WindowTitle = "Michael's PowerShell"

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

    Write-Host ("[ " + $(Get-Date).Tostring("HH:mm:ss") + " | " + $(Get-Location) + " ] $") -NoNewline -ForegroundColor Yellow 
    return " "
}

Import-Alias $PSScriptRoot\Aliases.txt -Force
$transcriptFile = "$PSScriptRoot\log\transcript$($(get-date).toString('yyyyMMdd-HHmmss')).log"
##Write-Host ('Recording transcript to "{0}".' -f ($transcriptFile))
Start-Transcript $transcriptFile

Write-Host " "
D:\Tools\Scripts\UpTime.ps1