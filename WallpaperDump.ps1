<# 
    .SYNOPSIS 
    Download images from some subreddits and NASA's APOD that can then be used for desktop backgrounds.
  
    .DESCRIPTION 
    This script will cycle through a list of subreddits and download the specified number of images.
    It will also download NASA's A Picture of the Day.
    
    .PARAMETER $MinimumWidth
    Minimum image width.  This is used when determining which images to retain.

    .PARAMETER $MinimumHeight
    Minimum image height.  This is used when determining which images to retain.

    .PARAMETER $NumberOfImages
    The number of images to retrieve when getting subreddit images.

    .PARAMETER $Subreddits
    An array of subreddits.  Works best if subreddits dedicated to posting images is used (e.g. Wallpapers, BackgroundArt, Breathless, etc).

    .PARAMETER $DestinationPath
    The folder path where downloaded images will be saved.
  
    .NOTES 
    Author: Michael Metcalfe
    Date: April 29, 2017
#>
param (
    $MinimumWidth = 1680,
    $MinimumHeight = 1050,
    $NumberOfImages = 5,
    $RetentionDays = 10,
    [string[]]$Subreddits = @("BackgroundArt", "EarthPorn", "Breathless", "Wallpapers", "SpacePorn", "BigWallpapers"),
    [string]$DestinationPath = [environment]::getfolderpath("MyPictures")+"\BackgroundDump"
)
Import-Module $PSScriptRoot\Modules\Image-Functions.psm1 -Force
Import-Module BitsTransfer

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$NET_ADAPTER_NAME = 'Intel(R) Dual Band Wireless-AC 7265';
$APOD_API_KEY = 'GWJpmhJe5s58fbZ5e6wNMmr8NU07l2S08NjLgCLV';

$InformationPreference = "Continue"

# create the destination folder if it does not exist.
if (!(Test-Path $DestinationPath))
{
    Write-Information "Destination folder, $DestinationPath, does not exist.  Creating..."
    New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null
}

#region Wait until a connection has been established.
$connected = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet
if (!$connected)
{
    if ($env:COMPUTERNAME -eq "E386091") # Work PC
    {
        # Just a hack to start a random internet connection.
        $tempPage = (iwr -Uri "http://www.cbc.ca/pei")
        Start-Sleep -Seconds 60
    }
    else
    {
        Write-Debug "Restarting network adapter: $NET_ADAPTER_NAME."
        Restart-NetAdapter -InterfaceDescription $NET_ADAPTER_NAME -Confirm:$false
        Write-Host -NoNewline "Waiting for connection." -ForegroundColor Magenta
    }
}

while (!$connected)
{
    $connected = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet

    if (!$connected)
    {
        Write-Host -NoNewline "."  -ForegroundColor Magenta
        Start-Sleep -Seconds 30
    }
    else 
    {
        Write-Host "." -ForegroundColor Magenta
    }
}
#endregion

foreach ($subreddit in $Subreddits)
{
    $url = "https://www.reddit.com/r/{0}/top/.json" -f ($subreddit)

    Write-Debug "Retrieving the $subreddit images..."

    # Grab the URL's from the reddit JSON object.
    try
    {
        Invoke-RestMethod $url -Method Get -Body @{limit="$NumberOfImages"} | %{
            #$postTitle = $_.data.children.data.title;
            $_.data.children.data.url;
            } | ?{
                $_ -match "\.jpg$"
            } | 
            Foreach {
                [regex]$regex = '[^/\\&\?]+\.\w{3,4}(?=([\?&].*$|$))'
                $subredditFilename = $regex.Matches($_).Value

                Write-Debug "Getting images from $subreddit." 
                $fileName = ("{0}\{1}_{2}") -f ($DestinationPath, $subreddit, $subredditFilename)
                if (!(Test-Path -Path $fileName))
                {
                    Start-BitsTransfer -DisplayName "Downloading images" -Description "Getting images from reddit." -Source $_ -Destination $fileName -ErrorAction SilentlyContinue | Complete-BitsTransfer
                    #AddTextToImage -Title $postTitle -SourcePath $DestinationPath\$_ -DestinationPath $DestinationPath\$_
                }
            }
    }
    catch
    {
        Write-Debug "There was a problem retrieving $url."
    }
}

# Completes all the BITS transfer jobs. 
Get-BitsTransfer | Complete-BitsTransfer

#region APOD Image retrieval
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try
{
    Write-Debug "Retrieving the NASA APOD image..."
    try
    {
        $apodContent = Invoke-RestMethod -Uri "https://api.nasa.gov/planetary/apod?api_key=$APOD_API_KEY" -Method Get
        [regex]$regex = '[^/\\&\?]+\.\w{3,4}(?=([\?&].*$|$))'
        $APODFilename = $regex.Matches($apodContent.hdurl).Value

        if ($apodContent.media_type -eq "image")
        {
            $dateFilename = (Get-Date -Format "yyyyMMdd")
            $fileName = ("{0}\{1}-APOD_{2}") -f ($DestinationPath, $dateFilename, $APODFilename)
            if (!(Test-Path -Path $fileName))
            {
                Start-BitsTransfer -Source $apodContent.hdurl -Destination $fileName -ErrorAction SilentlyContinue -DisplayName "NASA APOD image: $apodContent.title"
            }
        }
        else
        {
            Write-Host "APOD content type is" $apodContent.media_type -ForegroundColor Yellow
        }
    }
    catch
    {
        Write-Debug "There was a problem retrieving APOD content."
    }
}
catch
{
    Write-Error "Error retrieving NASA APOD." -RecommendedAction "Try again later."
}
#endregion

#region Remove any images that are old or below the desired resolution
$imagePurgeList = New-Object System.Collections.ArrayList;

# Gather list of files that need to be purged.
(Get-ChildItem -Path $DestinationPath -Include ('*.png', '*.jpg') -Recurse).FullName | % {
    $fileName = $_;
    $fileDate = (Get-ChildItem $fileName).CreationTime;
    $retentionDate = (Get-date).AddDays($RetentionDays * -1);

    try
    {
        $img = [Drawing.Image]::FromFile($fileName);
        if (($img.Width -lt $MinimumWidth -OR $img.Height -lt $MinimumHeight) -or ($fileDate -lt $retentionDate))
        {
            $idx = $imagePurgeList.Add($fileName);
            Write-Debug (("{0} is smaller than {1} x {2} or is older than {3} days.") -f ($_, $MinimumHeight, $MinimumWidth, $RetentionDays))
        }
    }
    catch [OutOfMemoryException]
    {
        Write-Warning "Could not get image dimensions for $fileName.";
        # This exception gets thrown if  the file does not have a valid image format or if GDI+ does not support the pixel format of the file.
        # So, just check the file date
        if ($fileDate -lt $retentionDate)
        {
            $idx = $imagePurgeList.Add($fileName);
        }
    }
}

Write-Debug (("Purging {0} unwanted files...") -f ($imagePurgeList.Count));
foreach ($file in $imagePurgeList)
{
    Remove-Item $file -Force -ErrorAction Continue;
}
#endregion