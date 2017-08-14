Function AddTextToImage
{
    # Orignal code from http://www.ravichaganti.com/blog/?p=1012
    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory=$true)][String] $SourcePath,
        [Parameter(Mandatory=$true)][String] $DestinationPath,
        [Parameter(Mandatory=$true)][String] $Title,
        [Parameter()][String] $Description = $null
    )
 
    Write-Verbose "Load System.Drawing"
    [Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
     
    Write-Verbose "Get the image from $SourcePath"
    $sourceImage = [System.Drawing.Image]::FromFile($SourcePath)
     
    Write-Verbose "Create a bitmap as $DestinationPath"
    $bmpFile = new-object System.Drawing.Bitmap([int]($sourceImage.width)),([int]($sourceImage.height))
 
    Write-Verbose "Intialize Graphics"
    $Image = [System.Drawing.Graphics]::FromImage($bmpFile)
    $Image.SmoothingMode = "AntiAlias"
     
    $Rectangle = New-Object Drawing.Rectangle 0, 0, $sourceImage.Width, $sourceImage.Height
    $Image.DrawImage($sourceImage, $Rectangle, 0, 0, $sourceImage.Width, $sourceImage.Height, ([Drawing.GraphicsUnit]::Pixel))
 
    Write-Verbose "Draw title: $Title"
    $Font = new-object System.Drawing.Font("Verdana", 24)
    $Brush = New-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 0, 0,0))
    $Image.DrawString($Title, $Font, $Brush, 10, 100)
     
    if ($Description -ne $null) {
        Write-Verbose "Draw description: $Description"
        $Font = New-object System.Drawing.Font("Verdana", 12)
        $Brush = New-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(120, 0, 0, 0))
        $Image.DrawString($Description, $Font, $Brush, 20, 150)
    }
 
    Write-Verbose "Save and close the files"
    $bmpFile.save($DestinationPath, [System.Drawing.Imaging.ImageFormat]::Bmp)
    $bmpFile.Dispose()
    $sourceImage.Dispose()
}