Add-Type -AssemblyName System.Windows.Forms

function Block-Idle
{
    <#
    .SYNOPSIS
    Move the mouse a random amount in X/Y.

    .DESCRIPTION
    This script will move the mouse a random amount from its current location at a set interval for a set amount of time.

    .PARAMETER Duration
    The amount of time, in minutes to perform the mouse-move.

    .PARAMETER  ActionTime
    The amount of time, in seconds, between each interval of moving the mouse.

    .PARAMETER  Silent
    Whether or not to display output.  If true, no output is displayed.

    .EXAMPLE
    PS C:\> Block-Idle -Duration 1 -ActionTime 5
    Will move the mouse every 5 seconds for 1 minute.

    .NOTES
    NAME        :  Block-Idle
    VERSION     :  1.0   
    LAST UPDATED:  6/5/2017
    AUTHOR      :  Michael Metcalfe
    .INPUTS
    None
    .OUTPUTS
    None
    #>
    [CmdletBinding()]
    param (
        $Duration = 1,  # How long (in minutes) to perform the action
        $ActionTime = 5, # How often (in seconds) to perform the action
        [switch]$Silent = $false # Whether or not to display output.
    )

    $myshell = New-Object -com "Wscript.Shell"

    if (!$Silent) {Write-Host (("Will perform every {0} seconds for {1} minutes.") -f ($ActionTime, $Duration))}

    $MaxXMovement = 200
    $MaxYMovement = 200

    $DurationSeconds = $Duration * 60
    for ($i = 0; $i -lt $DurationSeconds; $i+=$ActionTime)
    {
        Start-Sleep -Seconds $ActionTime

        $Pos = [System.Windows.Forms.Cursor]::Position
    
        # Set X and Y to the current position +/- (0 to Max Movement)
        $newXOffset = (Get-Random -Minimum -1 -Maximum 2) * (Get-Random -Minimum 0 -Maximum $MaxXMovement)
        $newYOffset = (Get-Random -Minimum -1 -Maximum 2) * (Get-Random -Minimum 0 -Maximum $MaxYMovement)

        $newX = $Pos.X + $newXOffset
        $newY = $Pos.Y + $newYOffset
        Write-Debug (("({0}, {1}) -> ({2}, {3})") -f ($Pos.X,$Pos.Y,$newX,$newY))
        [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(($newX) , ($newY))
    }
}
New-Alias -Name noidle -Value Block-Idle -Description "Keep PC from going idle."

function Show-Pause
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )

    # Check if running Powershell ISE
    if ($psISE)
    {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$Message")
    }
    else
    {
        Write-Host "$Message " -ForegroundColor Yellow -NoNewline
        $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Write-Host ""
    }
}
New-Alias -Name spause -Value Show-Pause -Description "Show a pause message or dialog."

function Clear-Session()
{
    <#
        .SYNOPSIS
        Clear variables and modules.

        .DESCRIPTION
        This cmdlet will clear all variables and modules from the current console session.

        .PARAMETER ClearVariables
        Clear variables from the current session.

        .PARAMETER  ClearModules
        Clear modules from the current session.

        .PARAMETER ReloadProfile
        After clearing items, load the default PowerShell profile file.

        .EXAMPLE
        PS C:\> Clear-Session
        Will clear all variables and modules from the current console session.

        .EXAMPLE
        PS C:\> Clear-Session -ClearVariables
        Will clear all variables current console session.

        .NOTES
        NAME        :  Clear-Session
        VERSION     :  1.0   
        LAST UPDATED:  7/12/2017
        AUTHOR      :  Michael Metcalfe
        .INPUTS
        None
        .OUTPUTS
        None
    #>
    [CmdletBinding()]
    param
    (
        [switch]$ClearVariables,
        [switch]$ClearModules,
        [switch]$ReloadProfile
    )

    # if neither parameter supplied, default to both enabled.
    if (-not $ClearVariables -and -not $ClearModules)
    {
        $ClearVariables = $true
        $ClearModules = $true
    }

    if ($ClearModules)
    {
        $moduleCount = (Get-Module | Measure).Count
        Remove-Module *
        $moduleCount = $moduleCount - ((Get-Module | Measure).Count)
        Write-Host "$moduleCount modules cleared." -ForegroundColor Green
    }
    
    if ($ClearVariables)
    {
        Remove-Variable * -ErrorAction SilentlyContinue -Exclude "ClearVariables"
        Write-Host "Variables cleared." -ForegroundColor Green
    }
    $error.Clear()

    if ($ReloadProfile)
    {
        Write-Host "Reloading profile: $profile" -ForegroundColor Yellow
        & "$profile"
    }
}

function Send-PhoneCommand
{
    <#
        .SYNOPSIS
        Perform a Tasker command on a specific phone.

        .DESCRIPTION
        Using Join's API, send a Tasker command to an identified phone.  For this to work, Tasker has
        to be setup to accept a command via the Join push.
        See this URL on how to set this up: http://forum.joaoapps.com/index.php?resources/run-any-task-from-any-autoapp.139/

        .PARAMETER PhoneName
        The name of the phone that the command will get sent to.

        .PARAMETER  Command
        The Tasker command to execute.

        .EXAMPLE
        PS C:\> Send-PhoneCommand -PhoneName Home -Command "Work Mode On"
        Execute the Tasker command "Work Mode On" on the "Home" phone.

        .NOTES
        NAME        :  Send-PhoneCommand
        VERSION     :  1.0   
        LAST UPDATED:  18/08/2017
        AUTHOR      :  Michael Metcalfe
        .INPUTS
        None
        .OUTPUTS
        None
    #>
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Work", "Home")]
        [string]$PhoneName,
        [Parameter(Mandatory=$true)]
        [ValidateSet("Mute", "UnMute", "Work Mode On", "Work Mode Off")]
        [string]$Command
    )
    $SendPhoneConfigFile = ([Environment]::GetFolderPath("MyDocuments") + "\send_phone.xml")

    [xml]$ConfigFile = Get-Content $SendPhoneConfigFile
<#    $SendPhoneSettings = @{
        SendPhoneAPIKey = $ConfigFile.config.APIKey
    }
#>
    # TODO: Add the phone names and device names to the config file, maybe the list of commands as well.
    $SendPhoneAPIKey = [string]$ConfigFile.config.APIKey

    $deviceName = "SM-J320W8"
    switch($PhoneName)
    {
        "Work" { $deviceName = "SM-J320W8" }
        "Home" { $deviceName = "Galaxy S5 Neo" }
    }
    $null = Invoke-WebRequest -Uri (("https://joinjoaomgcd.appspot.com/_ah/api/messaging/v1/sendPush?deviceNames={0}&deviceId=group.phone&text=task%3D%3A%3D{1}&apikey={2}") -f ($deviceName, $Command, $SendPhoneAPIKey)) -Method Post
}

#ls *.log | Select-String @("^.{2,3}-\d{4,5}", "exit code: (1|2|3|4)")
Export-ModuleMember -Function * -Alias *