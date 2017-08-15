$ScriptRootPath = "c:\dev\POSH"
Set-Location c:\

# Import modules
Import-Module $ScriptRootPath\Modules\File-Search.psm1
Import-Module $ScriptRootPath\Modules\Network.psm1
Import-Module $ScriptRootPath\Modules\Miscellaneous.psm1 -DisableNameChecking
Import-Module $ScriptRootPath\Modules\VAC-ACC.psm1

# Import data type so that we can get a prettier file size
# e.g. gci|select mode,lastwritetime,filesize,name
Update-TypeData -AppendPath $ScriptRootPath\Modules\shrf.ps1xml

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
    & "$ScriptRootPath\UpTime.ps1" -Silent
    return " "
}

Import-Alias $ScriptRootPath\Aliases.txt -Force
If (-not (Test-Path $ScriptRootPath\log))
{
    Write-Warning "Transcript directory '$ScriptRootPath\log' does not exist.  Creating."
    New-Item -ItemType Directory -Path "$ScriptRootPath\log" | Out-Null
}
$transcriptFile = "$ScriptRootPath\log\transcript$($(get-date).toString('yyyyMMdd-HHmmss')).log"
##Write-Host ('Recording transcript to "{0}".' -f ($transcriptFile))

# Try and stop the transcript (if one is running)
try
{
    Stop-Transcript | Out-Null
}
catch [System.InvalidOperationException]{}

Start-Transcript $transcriptFile

Write-Host " "
& "$ScriptRootPath\UpTime.ps1"