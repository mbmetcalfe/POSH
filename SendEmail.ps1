#Set-ExecutionPolicy RemoteSigned

#region Create the form
$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Simple Mail"
$objForm.Size = New-Object System.Drawing.Size(590,440)
$objForm.MinimizeBox = $True
$objForm.MaximizeBox = $False
$objForm.FormBorderStyle = "FixedDialog"
$objForm.StartPosition = "CenterScreen"

#region Email from input
$leftLabelPos = 10
$leftTextPos = 120
$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(($leftLabelPos + 5),20) 
$objLabel.Size = New-Object System.Drawing.Size(100,20) 
$objLabel.Text = "From Name/Email:"
$objForm.Controls.Add($objLabel) 

$txtFromName = New-Object System.Windows.Forms.TextBox 
$txtFromName.Location = New-Object System.Drawing.Size(($leftTextPos + 5),20) 
$txtFromName.Size = New-Object System.Drawing.Size(200,20) 
$txtFromName.Name = 'txtFrom'
$txtFromName.Text = 'Michael Metcalfe'
$objForm.Controls.Add($txtFromName) 

$txtFromEmail = New-Object System.Windows.Forms.TextBox 
$txtFromEmail.Location = New-Object System.Drawing.Size((340 + 5),20) 
$txtFromEmail.Size = New-Object System.Drawing.Size(200,20) 
$txtFromEmail.Name = 'txtFrom'
$txtFromEmail.Text = 'michael.metcalfe@maximuscanada.ca'
$objForm.Controls.Add($txtFromEmail) 

#endregion

#region Email to input
$leftLabelPos = 10
$leftTextPos = 120
$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(($leftLabelPos + 5),50) 
$objLabel.Size = New-Object System.Drawing.Size(100,20) 
$objLabel.Text = "To Name/Email:"
$objForm.Controls.Add($objLabel) 

$txtToName = New-Object System.Windows.Forms.TextBox 
$txtToName.Location = New-Object System.Drawing.Size(($leftTextPos + 5),50) 
$txtToName.Size = New-Object System.Drawing.Size(200,20) 
$txtToName.Name = 'txtTo'
$txtToName.Text = 'Michael Metcalfe'
$objForm.Controls.Add($txtToName) 

$txtToEmail = New-Object System.Windows.Forms.TextBox 
$txtToEmail.Location = New-Object System.Drawing.Size((340 + 5),50) 
$txtToEmail.Size = New-Object System.Drawing.Size(200,20) 
$txtToEmail.Name = 'txtTo'
$txtToEmail.Text = 'michael.metcalfe@maximuscanada.ca'
$objForm.Controls.Add($txtToEmail) 

#endregion

#region Subject input
$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(($leftLabelPos + 5),80) 
$objLabel.Size = New-Object System.Drawing.Size(100,20) 
$objLabel.Text = "Subject:"
$objForm.Controls.Add($objLabel) 

$txtSubject = New-Object System.Windows.Forms.TextBox 
$txtSubject.Location = New-Object System.Drawing.Size(($leftTextPos + 5),80) 
$txtSubject.Size = New-Object System.Drawing.Size(420,20) 
$txtSubject.Name = 'txtFrom'
$txtSubject.Text = ''
$objForm.Controls.Add($txtSubject) 
#endregion

#region Message
$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(($leftLabelPos + 5),110) 
$objLabel.Size = New-Object System.Drawing.Size(100,20) 
$objLabel.Text = "Message:"
$objForm.Controls.Add($objLabel) 

$txtMessage = New-Object System.Windows.Forms.TextBox 
$txtMessage.Location = New-Object System.Drawing.Size(($leftTextPos + 5),110) 
$txtMessage.Size = New-Object System.Drawing.Size(420,275) 
$txtMessage.Name = 'txtFrom'
$txtMessage.Text = ''
$txtMessage.MultiLine = $true
$objForm.Controls.Add($txtMessage) 
#endregion

#region Status label
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Size(($leftLabelPos + 5),110) 
$lblStatus.Size = New-Object System.Drawing.Size(100,20) 
$lblStatus.Text = ''
$objForm.Controls.Add($lblStatus) 
#endregion

#region Send/Cancel Buttons
$SendButton = New-Object System.Windows.Forms.Button
$SendButton.Location = New-Object System.Drawing.Size(260,380)
$SendButton.Size = New-Object System.Drawing.Size(75,23)
$SendButton.Text = "Send"

#region Code to send the email
$SendButton.Add_Click({
    $fromEmail = ("{0} <{1}>" -f ($txtFromName.Text, $txtFromEmail.Text))
    $toEmail = ("{0} <{1}>" -f ($txtToName.Text, $txtToEmail.Text))
    
    $body = "<html><body><div style='font-family: verdana; font-size: 75%;'><p>${txtMessage.Text}</p></div></body></html>"

    try
    {
        $smtpServer = "smtp.gmail.com"
        $smtpPort = "587"
<#
    $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
    $smtp.EnableSsl = $true
    $smtp.UseDefaultCredentials = $false


    # Send email message
    $message = New-Object Net.Mail.MailMessage($fromEmail, $toEmail, $txtSubject.Text, $body)
    $message.IsBodyHTML = $true

    $smtp.Send($message)

    $smtp.Dispose()
#>
        Send-MailMessage -From $fromEmail -To $toEmail -Subject $txtSubject.Text -BodyAsHtml $body -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential (Get-Credential)

        $txtSubject.Text = ''
        $txtMessage.Text = ''
        
        Write-Host "Message Sent."
    }
    catch
    {
        Write-Warning -Message "Message not sent: $($_.Exception.Message)"
    }
})
#endregion
$objForm.Controls.Add($SendButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(335,380)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)
#endregion

$objForm.KeyPreview = $True

$objForm.Add_KeyDown({
    if ($_.KeyCode -eq "Escape")
    {
        $objForm.Close()
        return
    }
})
$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()