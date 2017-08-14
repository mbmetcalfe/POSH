﻿Add-Type -AssemblyName System.Windows.Forms

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
PS C:\> Prevent-Idle -Duration 1 -ActionTime 5
Will move the mouse every 5 seconds for 1 minute.

.NOTES
NAME        :  Prevent-Idle
VERSION     :  1.0   
LAST UPDATED:  6/5/2017
AUTHOR      :  Michael Metcalfe
.INPUTS
None
.OUTPUTS
None
#>
Function Prevent-Idle
{
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
        Write-Debug (("Still there? ({0}, {1}) -> ({2}, {3}).") -f ($Pos.X, $Pos.Y, $newX, $newY))
        [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(($newX) , ($newY))
    }
}