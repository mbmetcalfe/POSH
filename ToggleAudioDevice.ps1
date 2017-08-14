<# 
    .SYNOPSIS 
    This script is used to toggle the current audio device.

    .DESCRIPTION 
    This script is used to toggle the current audio device.

    .NOTES 
    Author: Michael Metcalfe
    Date: February 22, 2016

    Set $AUDIO_DEVICE1 and $AUDIO_DEVICE2 to the 2 audio devices to toggle 
    between.  These names can be found/renamed in the audio settings. 
    This script uses a  3rd party software to display the toaster notifications of which device was set: 
    http://www.nirsoft.net/utils/nircmd.html
    If you wish not to have this 3rd party software, remove the lines referencing 'nircmd'.
#>
Import-Module C:\Users\micha\OneDrive\Documents\WindowsPowerShell\Modules\Toast.psm1
$AUDIO_DEVICE1 = 'Speakers'
$AUDIO_DEVICE2 = 'Headphones'

function Set-EnvironmentVariable
{
    param
    (
        [Parameter(Mandatory=$true, HelpMessage='Help note')]
        $Name,
        [System.EnvironmentVariableTarget]
        $Target,
        $Value = $null
    )
    
    [System.Environment]::SetEnvironmentVariable($Name, $Value, $Target)
}

$currentAudioDevice = [System.Environment]::GetEnvironmentVariable('CurrentAudioDevice')
$toastImage = "C:\Users\micha\OneDrive\Pictures\Avatars\Skeptical_Hippo.jpeg"

if ($currentAudioDevice -eq $AUDIO_DEVICE1)
{
    $newAudioDevice = $AUDIO_DEVICE2
    $toastImage = "D:\Tools\Scripts\Steelseries_Headphones.png"
}
elseif ($currentAudioDevice -eq $AUDIO_DEVICE2)
{
    $newAudioDevice = $AUDIO_DEVICE1
    $toastImage = "D:\Tools\Scripts\Bose_Speakers.jpg"
}
else
{
    # Default to whatever was passed back from the call to get current audio device.
    $newAudioDevice = $currentAudioDevice
}

Set-EnvironmentVariable -Name CurrentAudioDevice -Value $newAudioDevice -Target User

D:\tools\nircmd\nircmd.exe showerror setdefaultsounddevice $newAudioDevice

Show-Toast -Group "Audio Device" -Title "Toggle Audio Device" -Message "Audio device set to $newAudioDevice." -Image "$toastImage"
