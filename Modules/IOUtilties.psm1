function Save-FileAsDialog
{
    <#
    .SYNOPSIS
        Use the save dialog to get a filename to save.
    .DESCRIPTION
        Collect filename and path for a save as operation using GUI popup Dialog in PowerShell.
    .PARAMETER Filter
        A filter for the files displayed in the save file dialog.  You can have multiple filters,
        separated by |.  Each filter is a pair of "Description|Filter".  
        e.g. "All Files|*.*"
             "All Files|*.*|Text Files|*.txt"
        If multiple filters supplied, the first one in the list is chosen by default.
    .PARAMETER Title
        Title displayed on the dialog.
    .EXAMPLE
        Displays the save file dialog with *.log as the filter
        Save-FileAs -Filter "Log Files|*.log" -Title "Save log file"
    .EXAMPLE
        Displays the save file dialog with *.log and *.txt as possible filter values.
        Save-FileAs -Filter "Log Files|*.log|Text Files|*.txt"
    .NOTES
         Limitations:  
            * Must Run PowerShell (or ISE)  
            * UAC may get in the way depending on your settings (See: http://ITProGuru.com/PS-UAC) 
            * In ISE, the dialog box sometimes pops under the ISE so you may have to toggle to it 
    #>
    param
    (
        [Parameter(Position = 0,Mandatory = $false)]
        [string]$Filter = "All files (*.*)|*.*",
        [Parameter(Position = 1,Mandatory = $false)]
        [string]$Title = "Save As",
        [Parameter(Position = 2,Mandatory = $false)]
        [string]$InitialDirectory = [System.IO.Directory]::GetCurrentDirectory()
    )

    # Class Details:  https://msdn.microsoft.com/en-us/library/system.windows.forms.savefiledialog(v=vs.110).aspx 
    $SaveFileDialog = New-Object Windows.Forms.SaveFileDialog
    $SaveFileDialog.InitialDirectory = $InitialDirectory
    $SaveFileDialog.Title = $Title

    $SaveFileDialog.Filter = $Filter;
    $SaveFileDialog.ShowHelp = $False   

    $result = $SaveFileDialog.ShowDialog()    
    if($result -eq "OK")
    {    
        return $SaveFileDialog.filename
    }
    else
    {
        return $null
    }

    $SaveFileDialog = $null
}

function Open-FileDialog
{
    <#
    .SYNOPSIS
        Use the open dialog to get a filename to open.
    .DESCRIPTION
        Collect filename and path for a open as operation using GUI popup Dialog in PowerShell.
    .PARAMETER Filter
        A filter for the files displayed in the open file dialog.  You can have multiple filters,
        separated by |.  Each filter is a pair of "Description|Filter".  
        e.g. "All Files|*.*"
             "All Files|*.*|Text Files|*.txt"
        If multiple filters supplied, the first one in the list is chosen by default.
    .PARAMETER Title
        Title displayed on the dialog.
    .EXAMPLE
        Displays the open file dialog with *.log as the filter
        Save-FileAs -Filter "Log Files|*.log" -Title "Save log file"
    .EXAMPLE
        Displays the open file dialog with *.log and *.txt as possible filter values.
        Save-FileAs -Filter "Log Files|*.log|Text Files|*.txt"
    .NOTES
         Limitations:  
            * Must Run PowerShell (or ISE)  
            * UAC may get in the way depending on your settings (See: http://ITProGuru.com/PS-UAC) 
            * In ISE, the dialog box sometimes pops under the ISE so you may have to toggle to it 
    #>
    param
    (
        [Parameter(Position = 0,Mandatory = $false)]
        [string]$Filter = "All files (*.*)|*.*",
        [Parameter(Position = 1,Mandatory = $false)]
        [string]$Title = "Open",
        [Parameter(Position = 2,Mandatory = $false)]
        [string]$InitialDirectory = [System.IO.Directory]::GetCurrentDirectory()
    )

    # Class Details:  https://msdn.microsoft.com/en-us/library/system.windows.forms.openfiledialog(v=vs.110).aspx
    $OpenFileDialog = New-Object Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = $InitialDirectory
    $OpenFileDialog.Title = $Title

    $OpenFileDialog.Filter = $Filter;
    $OpenFileDialog.ShowHelp = $False   

    $result = $OpenFileDialog.ShowDialog()    
    if($result -eq "OK")
    {    
        return $OpenFileDialog.filename
    }
    else
    {
        return $null
    }

    $OpenFileDialog = $null
}

function Select-Folder
{
    <#
    .SYNOPSIS
        Use the open folder dialog to get a folder to use.
    .DESCRIPTION
        Call the browse for folder dialog to get select a folder.
    .PARAMETER Message
        Message displayed on the dialog.
    .PARAMETER InitialDirectory
        The directory to start with when dialog is displayed.
    .PARAMETER NewFolderButton
        Enable the option to create new folders on the dialog.
    .EXAMPLE
        Displays the open folder dialog starting from "c:\program files"
        PS> Select-Folder -IntialDirectory "C:\Program Files"
    .EXAMPLE
        Displays the open folder dialog with the option to create new folders.
        PS> Select-Folder -NewFolderButton
    .NOTES
         Limitations:  
            * Must Run PowerShell (or ISE)  
            * In ISE, the dialog box sometimes pops under the ISE so you may have to toggle to it 
    #>
    param
    (
        [Parameter(Position = 0)]
        [string]$InitialDirectory,
        [Parameter(Position = 1)]
        [string]$Message,
        [Parameter(Position = 2)]
        [switch]$NewFolderButton
    )
    $browseForFolderOptions = 512
    if ($NewFolderButton)
    {
        $browseForFolderOptions -= 512
    }

    $app = New-Object -ComObject Shell.Application
    $folder = $app.BrowseForFolder(0, $Message, $browseForFolderOptions, $InitialDirectory)    
    if ($folder)
    {
        $selectedDirectory = $folder.Self.Path
    }
    else
    {
        $selectedDirectory = $null
    }
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($app) > $null

    return $selectedDirectory
}
