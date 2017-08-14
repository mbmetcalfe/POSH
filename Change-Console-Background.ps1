<# 
    .SYNOPSIS 
    Change-Console-Background.ps1: Select a random image from a list and copy it to the ConsoleZ background image.
  
    .NOTES 
    Author: That Guy
    Date: March 16, 2017
#>

$DebugPreference = "Continue"

$consoleZPath = "C:\Program Files (x86)\ConsoleZ\"
$image1FileName = "ps.jpg"
$image2FileName = "cmd.jpg"

$imageList = @(
    "C:\Users\mmetcalfe\Documents\Pictures\Wallpaper\DM\finery.png",
    "C:\Users\mmetcalfe\Documents\Pictures\Wallpaper\DM\honey.jpg",
    "C:\Users\mmetcalfe\Documents\Pictures\Wallpaper\DM\nighttimes.png",
    "C:\Users\mmetcalfe\Documents\Pictures\Wallpaper\DM\offtherecord.png",
    "C:\Users\mmetcalfe\Documents\Pictures\Wallpaper\DM\softblue.jpg",
    "C:\Users\mmetcalfe\Documents\Pictures\Wallpaper\DM\targetingsystem.jpg"
)

$currentImage = $imageList  | Get-Random -Count 1
Remove-Item "${consoleZPath}${image1FileName}", "${consoleZPath}${image2FileName}"
Copy-Item $currentImage -Destination "${consoleZPath}${image1FileName}"

$currentImage = $imageList  | Get-Random -Count 1
Copy-Item $currentImage -Destination "${consoleZPath}${image2FileName}"