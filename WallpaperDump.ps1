<# 
    .SYNOPSIS 
    Download images from some subreddits and NASA's APOD that can then be used for desktop backgrounds.
  
    .DESCRIPTION 
    This script will cycle through a list of subreddits and download the specified number of images.
    It will also download NASA's A Picture of the Day.
    
    .PARAMETER $MinimumWidth

    .PARAMETER $MinimumHeight

    .PARAMETER $NumberOfImages

    .PARAMETER $DestinationPath

  
    .NOTES 
    Author: Michael Metcalfe
    Date: April 29, 2017
#>
param (
    $MinimumWidth = 1680,
    $MinimumHeight = 1050,
    $NumberOfImages = 5,
    $RetentionDays = 7,
    [string]$DestinationPath = [environment]::getfolderpath("MyPictures")+"\BackgroundDump"
)
Import-Module $PSScriptRoot\Modules\Image-Functions.psm1 -Force
Import-Module BitsTransfer

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")


$NET_ADAPTER_NAME = 'Intel(R) Dual Band Wireless-AC 7265'
$subreddits = @("BackgroundArt", "EarthPorn", "Breathless", "Wallpapers", "SpacePorn", "BigWallpapers")

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
    Write-Debug "Restarting network adapter: $NET_ADAPTER_NAME."
    Restart-NetAdapter -InterfaceDescription $NET_ADAPTER_NAME -Confirm:$false
    Write-Host -NoNewline "Waiting for connection." -ForegroundColor Magenta
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

foreach ($subreddit in $subreddits)
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
                #$dateFilename = (Get-Date -Format "yyyyMMddHHmm")
                #$fileName = ("{0}\{1}-{2}_{3}") -f ($DestinationPath, $dateFilename, $subreddit, $subredditFilename)
                $fileName = ("{0}\{1}_{2}") -f ($DestinationPath, $subreddit, $subredditFilename)
                Start-BitsTransfer -DisplayName "Downloading images" -Description "Getting images from reddit." -Source $_ -Destination $fileName -ErrorAction SilentlyContinue
                #AddTextToImage -Title $postTitle -SourcePath $DestinationPath\$_ -DestinationPath $DestinationPath\$_
            }
    }
    catch
    {
        Write-Debug "There was a problem retrieving $url."
    }
}

# Remove any images that are below the desired resolution
(Get-ChildItem -Path $DestinationPath -Filter *.jpg).FullName | % {
    $fileDate = (Get-ChildItem $_).CreationTime;
    $retentionDate = (Get-date).AddDays($RetentionDays * -1);

    $img = [Drawing.Image]::FromFile($_);
    if (($img.Width -lt $MinimumWidth -OR $img.Height -lt $MinimumHeight) -or ($fileDate -lt $retentionDate))
    {
        Write-Debug (("{0} is smaller than {1} x {2} or is older than {3} days.") -f ($_, $MinimumHeight, $MinimumWidth, $RetentionDays))
        Remove-Item $_ -Force -ErrorAction SilentlyContinue
    }
}

#region APOD Image retrieval
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try
{
    Write-Debug "Retrieving the NASA APOD image..."
    try
    {
        $apodContent = Invoke-RestMethod -Uri "https://api.nasa.gov/planetary/apod?api_key=GWJpmhJe5s58fbZ5e6wNMmr8NU07l2S08NjLgCLV" -Method Get
        [regex]$regex = '[^/\\&\?]+\.\w{3,4}(?=([\?&].*$|$))'
        $APODFilename = $regex.Matches($apodContent.hdurl).Value

        if ($apodContent.media_type -eq "image")
        {
            $dateFilename = (Get-Date -Format "yyyyMMdd")
            $fileName = ("{0}\{1}-APOD_{2}") -f ($DestinationPath, $dateFilename, $APODFilename)
            Start-BitsTransfer -Source $apodContent.hdurl -Destination $fileName -ErrorAction SilentlyContinue -DisplayName "NASA APOD image: $apodContent.title"
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