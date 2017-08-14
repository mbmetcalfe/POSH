<# 
    .SYNOPSIS 
    Run a set of scripts on machine logon.
  
    .NOTES 
    Author: Michael Metcalfe
    Date: March 16, 2017
#>
$ScriptPath = "C:\dev\POSH"
$ScriptPath\Change-Console-Background.ps1
$ScriptPath\Set-Wallpaper.ps1 MyPics *
$ScriptPath\UpTime.ps1 -Silent