<# 
    .SYNOPSIS 
    T#3233220: Merge two people based on identifiers.
  
    .DESCRIPTION 
    Merge two people based on a code/id pair (e.g. YT_PHN/12345).  Once two people have been
    correctly identified, their claims and their DIS data will be merged into one.
    
  
    .PARAMETER Username 
    Username value to be passed to the SQL script that will be used to set which user is responsible
    for the update (UPDATED_BY).
  
    .PARAMETER SQLScript 
    The name of the SQL script to run.  The script must reside in the same folder as this script.
  
    .PARAMETER NoPrompt 
    Run the install without prompting for source/destination paths.

    .EXAMPLE 
    Install.ps1 -SourcePath "c:\stage\cps\merge_scripts" -DestinationPath "c:\cps\Merge" -NoPrompt
  
    .NOTES 
    Company: Deltaware Systems. Copyright (c) DeltaWare Systems Inc. All Rights Reserved.
    Author: That Guy
    Date: June 24, 2016
#>
param (
    [Parameter(Mandatory=$false)]
    [string]$ImagePath = '.\ST'
 )
 
 Function Update-Wallpaper {
    Param(
        [Parameter(Mandatory=$true)]
        $Path,
         
        [ValidateSet('Center','Stretch','Fill','Tile','Fit')]
        $Style
    )
    Try {
        if (-not ([System.Management.Automation.PSTypeName]'Wallpaper.Setter').Type) {
            Add-Type -TypeDefinition @"
            using System;
            using System.Runtime.InteropServices;
            using Microsoft.Win32;
            namespace Wallpaper {
                public enum Style : int {
                    Center, Stretch, Fill, Fit, Tile
                }
                public class Setter {
                    public const int SetDesktopWallpaper = 20;
                    public const int UpdateIniFile = 0x01;
                    public const int SendWinIniChange = 0x02;
                    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
                    private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
                    public static void SetWallpaper ( string path, Wallpaper.Style style ) {
                        SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
                        RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
                        switch( style ) {
                            case Style.Tile :
                                key.SetValue(@"WallpaperStyle", "0") ; 
                                key.SetValue(@"TileWallpaper", "1") ; 
                                break;
                            case Style.Center :
                                key.SetValue(@"WallpaperStyle", "0") ; 
                                key.SetValue(@"TileWallpaper", "0") ; 
                                break;
                            case Style.Stretch :
                                key.SetValue(@"WallpaperStyle", "2") ; 
                                key.SetValue(@"TileWallpaper", "0") ;
                                break;
                            case Style.Fill :
                                key.SetValue(@"WallpaperStyle", "10") ; 
                                key.SetValue(@"TileWallpaper", "0") ; 
                                break;
                            case Style.Fit :
                                key.SetValue(@"WallpaperStyle", "6") ; 
                                key.SetValue(@"TileWallpaper", "0") ; 
                                break;
}
                        key.Close();
                    }
                }
            }
"@ -ErrorAction Stop 
            } 
        } 
        Catch {
            Write-Warning -Message "Wallpaper not changed because $($_.Exception.Message)"
        }
    [Wallpaper.Setter]::SetWallpaper( $Path, $Style )
}

$Style = 'Tile'

$ImageFiles = dir -Path $ImagePath -Filter "*.jpg"
$WallpaperImage = $ImageFiles | Get-Random -Count 1

Update-Wallpaper -Path $ImagePath\$WallpaperImage -Style $Style