<# 
    .SYNOPSIS 
    Displays a Windows Toast popup message.

    .DESCRIPTION 
    This cmdlet will display a toast message with a configurable title and picture.

    .PARAMETER Title 
    Title displayed at the top of the toast message.

    .PARAMETER Message
    The message to be displayed in the toast popup.

    .PARAMETER Image
    Filename of image to display in toast icon.

    .EXAMPLE 
    Show-Toast "Test Title" "Testing toast popup."

    Measure the latency between your computer and www.google.ca

    .NOTES 
    Author: Michael Metcalfe
    Date: March 30, 2017
#>
function Show-Toast ([string]$Group = "No Group", [string]$Title, [string]$Message, [string]$Image)
{
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null

    # Toasts templates: https://msdn.microsoft.com/en-us/library/windows/apps/hh761494.aspx
    $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastImageAndText02)

    # Convert to .NET type for XML manipulation
    $toastXml = [xml] $template.GetXml()

    # Customize the toast message
    $toastXml.GetElementsByTagName(“text”)[0].AppendChild($toastXml.CreateTextNode($Title)) > $null
    #$toastXml.GetElementsByTagName(“text”)[1].AppendChild($toastXml.CreateTextNode(“Customizated notification: ” + [DateTime]::Now.ToShortTimeString())) > $null
    $toastXml.GetElementsByTagName(“text”)[1].AppendChild($toastXml.CreateTextNode($Message)) > $null

    if (Test-Path $Image)
    {
        $ImageElements = $toastXml.GetElementsByTagName('image')
        $ImageElements[0].src = "file:///$Image"
    }

    # Convert back to WinRT type
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($toastXml.OuterXml)
    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)

    # Unique Application id/tag and group
    $toast.Tag = “PSScript”
    $toast.Group = $Group
    $toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(50)

    # Create the toats and show the toast. Make sure to include the AppId
    $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($toast.Tag)
    $notifier.Show($toast);
}

Export-ModuleMember -Function Show-Toast