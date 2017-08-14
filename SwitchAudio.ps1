###############################################################################
# Script:      SwitchAudio.ps1
# Author:      MMetcalfe
# Date:        February 22, 2016
# Description: This script is used to toggle the current audio device.  Set
#     $AUDIO_DEVICE1 and $AUDIO_DEVICE2 to the 2 audio devices to toggle 
#     between.  These names can be found/renamed in the audio settings.
###############################################################################
$AUDIO_DEVICE1 = 'Speakers'
$AUDIO_DEVICE2 = 'Headphones'

$r = [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$regRoot = "HKCU:\Software\Microsoft\"


$profiles = @{"Speakers" = @("Realtek HD Audio output",      
                            "Realtek HD Audio input");
            "Headphones" = @("Siberia Raw Prism Headset", 
                            "Siberia Raw Prism Headset") }

function Display-Toast ([string]$message)
{
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null

    # Toasts templates: https://msdn.microsoft.com/en-us/library/windows/apps/hh761494.aspx
    $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    # Convert to .NET type for XML manipulation
    $toastXml = [xml] $template.GetXml()

    # Customize the toast message
    $toastXml.GetElementsByTagName(“text”)[0].AppendChild($toastXml.CreateTextNode(“Audio Device”)) > $null
    $toastXml.GetElementsByTagName(“text”)[1].AppendChild($toastXml.CreateTextNode(“Customizated notification: ” + [DateTime]::Now.ToShortTimeString())) > $null

 
    # Convert back to WinRT type
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($toastXml.OuterXml)
    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)

    # Unique Application id/tag and group
    $toast.Tag = “PowerShell UI”
    $toast.Group = “PowerShell UI”
    $toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(50)

    # Create the toats and show the toast. Make sure to include the AppId
    $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($toast.Tag)
    $notifier.Show($toast);
}

function Write-Message ( [string]$message )
{
    echo $message
    # Uncomment this line to show dialog outputs from -set 
    # $r = [System.Windows.Forms.MessageBox]::Show($message)
}

function Set-Mapping ( [string]$devOut, [string]$devIn )
{
    echo "Profile audio:`n  in  = $devIn`n  out = $devOut"

    $regKey = $regRoot + "\Multimedia\Sound Mapper\"
    Set-ItemProperty $regKey -name Playback -value $devOut
    Set-ItemProperty $regKey -name Record -value $devIn
}

function List-Devices
{
    $regKey = $regRoot + "\Windows\CurrentVersion\Applets\Volume Control\"
    echo "Sound devices:"
    ls $regKey | where { ! $_.Name.EndsWith("Options") } | 
        Foreach-Object { 
            echo ("  " + $_.Name.Substring($_.Name.LastIndexOf("\")+1)) 
        }
}

$cmd = $args[0]
switch ($cmd)
{
    "-profiles" 
    {
        echo "Sound profiles:"
        echo $profiles
    }
    "-devices"
    {
        List-Devices
    }
    "-set" 
    {
        $p = $args[1]
        if (!$profiles.ContainsKey($p)) {
            echo "No such profile: $p"
            echo $profiles
            exit
        }
        Set-Mapping $profiles.Get_Item($p)[0] $profiles.Get_Item($p)[1]
        Write-Message "Profile set to: $p"
        Display-Toast "Profile set to: $p"
    }
    default 
    { 
        Write-Message "No such option: $cmd" 
    }
}