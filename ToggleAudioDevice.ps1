<# 
    .SYNOPSIS 
    This script is used to toggle the current audio device.

    .DESCRIPTION 
    This script is used to toggle the current audio device.  It uses an environment variable
    to keep track of which one is active.

    .NOTES 
    Author: Michael Metcalfe
    Date: February 22, 2016

    Set $AUDIO_DEVICE1 and $AUDIO_DEVICE2 to the 2 audio devices to toggle 
    between.  These names can be found/renamed in the audio settings. 
    This script uses a  3rd party software to set the audio device of which device was set: 
    http://www.nirsoft.net/utils/nircmd.html
    If you wish not to have this 3rd party software, remove the lines referencing 'nircmd'.
#>
$BasePath = "C:\dev\POSH"
Import-Module "$BasePath\Modules\Toast.psm1"

<# 
    TODO: Set up a dictionary with the device name as the key and have the image as the value
        or something similar.    
#>
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
# Default Toast Image
$toastImage = [environment]::getfolderpath("MyPictures") + "\Avatars\Skeptical_Hippo.jpeg"

if ($currentAudioDevice -eq $AUDIO_DEVICE1)
{
    $newAudioDevice = $AUDIO_DEVICE2
    $toastImage = "$BasePath\Steelseries_Headphones.png"
}
elseif ($currentAudioDevice -eq $AUDIO_DEVICE2)
{
    $newAudioDevice = $AUDIO_DEVICE1
    $toastImage = "$BasePath\Bose_Speakers.jpg"
}
else
{
    # Default to whatever was passed back from the call to get current audio device.
    $newAudioDevice = $currentAudioDevice
}

Set-EnvironmentVariable -Name CurrentAudioDevice -Value $newAudioDevice -Target User

D:\tools\nircmd\nircmd.exe showerror setdefaultsounddevice $newAudioDevice

Show-Toast -Group "Audio Device" -Title "Toggle Audio Device" -Message "Audio device set to $newAudioDevice." -Image "$toastImage"
