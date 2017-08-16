<# 
    .SYNOPSIS 
    Check and/or display the current machine's up time.
  
    .DESCRIPTION 
    This script will check how long the current machine has been running without a reboot.
    There is a check to see what the longest uptime was and both the current uptime and the 
    maximum uptime for the machine can be displayed.
    
  
    .PARAMETER Silent 
    If true, no output is displayed.
  
    .NOTES 
    Author: Michael Metcalfe
    Date: April 24, 2017
#>

param (
    [Parameter(Mandatory=$false)]
    [switch]$Silent = $false
 )

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

#region Default parameters
$ConfigFileName = $scriptPath + "\UpTime.xml"

Write-Verbose ("Configuration file: {0}." -f ($ConfigFileName))

if (!(Test-Path $ConfigFileName))
{
    # Create The Document  
    $XmlWriter = New-Object System.XMl.XmlTextWriter($ConfigFileName, $Null)  
    # Set The Formatting  
    $xmlWriter.Formatting = "Indented"  
    $xmlWriter.Indentation = "4"  
    # Write the XML Decleration  
    $xmlWriter.WriteStartDocument()  

    # Write Root Element  
    $xmlWriter.WriteStartElement("uptime")  

    # Write the Document  
    $xmlWriter.WriteElementString("LastBootUpTime", (Get-Date))  

    $xmlWriter.WriteStartElement("MaxUpTime")
    $xmlWriter.WriteElementString("Days", 0)
    $xmlWriter.WriteElementString("Hours", 0)
    $xmlWriter.WriteElementString("Minutes", 0)
    $xmlWriter.WriteElementString("RecordedOn", (Get-Date))
    $xmlWriter.WriteEndElement()

    # Write Close Tag for Root Element  
    $xmlWriter.WriteEndElement() # <-- Closing RootElement  
    # End the XML Document  
    $xmlWriter.WriteEndDocument()  
    # Finish The Document  
    $xmlWriter.Flush()  
    $xmlWriter.Close()  
}

[xml]$ConfigFile = Get-Content $ConfigFileName
$uptimeSettings = @{
    LastBootUpTime = $ConfigFile.uptime.LastBootUpTime
    MaxUpTime = $ConfigFile.uptime.MaxUpTime
}

$uptime = Get-CimInstance -ClassName win32_operatingsystem | Select-Object CSName, LastBootUpTime

$uptimeSettings.LastBootUpTime = [string]$uptime.LastBootUpTime
$ConfigFile.uptime.LastBootUpTime = [string]$uptime.LastBootUpTime

$ts = New-TimeSpan -Start $uptime.LastBootUpTime -End (Get-Date)

if (($ts.Days -gt $uptimeSettings.MaxUpTime.Days) -or
    ($ts.Days -eq $uptimeSettings.MaxUpTime.Days -and $ts.Hours -gt $uptimeSettings.MaxUpTime.Hours) -or
    ($ts.Days -eq $uptimeSettings.MaxUpTime.Days -and $ts.Hours -eq $uptimeSettings.MaxUpTime.Hours -and $ts.Minutes -gt $uptimeSettings.MaxUpTime.Minutes))
{
    Write-Verbose "New max uptime achieved."
    $uptimeSettings.MaxUpTime.Days = [string]$ts.Days
    $uptimeSettings.MaxUpTime.Hours = [string]$ts.Hours
    $uptimeSettings.MaxUpTime.Minutes = [string]$ts.Minutes
    $uptimeSettings.MaxUpTime.RecordedOn = (Get-Date).ToString()
}

if (!$Silent)
{
    Write-Host ("{0} has been up since {1}.`t{2} Days, {3} Hours, {4} minutes." -f ($uptime.CSName, $uptime.LastBootUpTime, $ts.Days, $ts.Hours, $ts.Minutes)) -BackgroundColor Yellow -ForegroundColor DarkBlue
    Write-Host ("Longest uptime ended on {3}.`t{0} days, {1} hours, {2} minutes." -f ($uptimeSettings.MaxUpTime.Days, $uptimeSettings.MaxUpTime.Hours, $uptimeSettings.MaxUpTime.Minutes, $uptimeSettings.MaxUpTime.RecordedOn)) -BackgroundColor Yellow -ForegroundColor DarkBlue
}
$ConfigFile.Save($ConfigFileName)