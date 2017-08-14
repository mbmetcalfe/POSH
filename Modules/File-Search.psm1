### TODO: Re-write these functions to share functionality and pass along the includes parameter.

<# 
    .SYNOPSIS 
    This script is used to search know code-based files for text within.  The results are logged to a file and that file is displayed in the console.
    
  
    .DESCRIPTION 
    By default this script will search known code or code-related files, recursively from a given path and return a list of files that contain the search text.
    
  
    .PARAMETER Path 
    Path to search in.  If no path given, uses the current directory as starting point.

    .PARAMETER Include
    Include only the specified items from the Path.

    .PARAMETER CaseSensitive
    Make the matches case sensitive. By default, matches are not case-sensitive.

    .PARAMETER Text
    The text to search for in the files.

    .PARAMETER Results
    The file to log results to.  If not supplied, one is created in $env:Temp based on your search text (with any special characters removed).
    e.g. If you are searching for "env:path" your log file will be "Find-Code_envpath.log" in your temporary directory.
  
    .EXAMPLE 
    Find-Code -Path c:\src -Text "env:path"
  
    .NOTES 
    Company: Deltaware Systems. Copyright (c) DeltaWare Systems Inc. All Rights Reserved.
    Author: Michael Metcalfe
    Date: March 10, 2016
#>
function Find-Code
{

param (
    [string]$Path = "",
    [string]$Include = "('*.dpr', '*.js', '*.xml', '*.xsl', '*.xslt', '*.pck', '*.sql', '*.trg', '*.dql', '*.dpr', '*.dfm', '*.pas', '*.inc', '*.cjs', '*.htc', '*.scr', '*.thw', '*.mule')",
    [switch]$CaseSensitive,
    [Parameter(Mandatory=$true)]
    [string]$Text,
    [string]$Results = ""
)

    # If no path specified, assume current working directory
    if (!$Path)
    {
        $Path = (Get-Item -Path ".\" -Verbose).FullName
    }

    # If not results filename given, create one based on the search text (special characters removed).
    if (!$Results)
    {
        $pattern = '[^a-zA-Z ]'
        $fileName = $Text -replace $pattern, ''
        $Results = "$env:temp\Find-Code_$fileName.log"
    }

    # Remove results file if it already exists.
    if (Test-Path $Results)
    {
        Remove-Item $Results
    }

    # Add search information to the top of the file.
    'Search results for: "{0}" in "{1}".' -f ($Text, $Path) | Out-File $Results

    Write-Host ('Searching for: "{0}" in "{1}".  Log: "{2}"' -f ($Text, $Path, $Results))
    gci -recurse -include ('*.dpr', '*.js', '*.xml', '*.xsl', '*.xslt', '*.pck', '*.sql', '*.trg', '*.dql', '*.dpr', '*.dfm', '*.pas', '*.inc', '*.cjs', '*.htc', '*.scr', '*.thw', '*.ps1', '*.psm1', '*.mule') -EA SilentlyContinue| Select-String -CaseSensitive:$CaseSensitive -pattern $Text | Group-Object Path | Select-Object Name | Format-Table -Property Name -AutoSize | Out-String -Width 4096 | Out-File -Append $Results
    #gci -recurse -include:$Include -EA SilentlyContinue| Select-String -CaseSensitive:$CaseSensitive -pattern $Text | Group-Object Path | Select-Object Name | Format-Table -Wrap | Out-File -Append $Results

    # Show search results.
    if (Test-Path $Results)
    {
        Get-Content $Results
    }
}


<# 
    .SYNOPSIS 
    This script is used to search know log-based files for text within.  The results are logged to a file and that file is displayed in the console.
    
  
    .DESCRIPTION 
    By default this script will search known log or log-related files, recursively from a given path and return a list of files that contain the search text.
    
  
    .PARAMETER Path 
    Path to search in.  If no path given, uses the current directory as starting point.

    .PARAMETER Include
    Include only the specified items from the Path.

    .PARAMETER CaseSensitive
    Make the matches case sensitive. By default, matches are not case-sensitive.

    .PARAMETER Text
    The text to search for in the files.

    .PARAMETER Results
    The file to log results to.  If not supplied, one is created in $env:Temp based on your search text (with any special characters removed).
    e.g. If you are searching for "env:path" your log file will be "Find-Log_envpath.log" in your temporary directory.
  
    .EXAMPLE 
    Find-Log -Path c:\rm\logs -Text "env:path"
  
    .NOTES 
    Company: Deltaware Systems. Copyright (c) DeltaWare Systems Inc. All Rights Reserved.
    Author: Michael Metcalfe
    Date: March 10, 2016
#>
function Find-Log
{
param (
    [string]$Path = "",
    [Parameter(Mandatory=$true)]
    [string]$Text,
    [string]$Results = "",
    [switch]$CaseSensitive
 )

    # If no path specified, assume current working directory
    if (!$Path)
    {
        $Path = (Get-Item -Path ".\" -Verbose).FullName
    }

    # If not results filename given, create one based on the search text (special characters removed).
    if (!$Results)
    {
        $pattern = '[^a-zA-Z ]'
        $fileName = $Text -replace $pattern, ''
        $Results = "$env:temp\Find-Log_$fileName.log"
    }

    # Remove results file if it already exists.
    if (Test-Path $Results)
    {
        Remove-Item $Results
    }

    # Add search information to the top of the file.
    'Search results for: "{0}" in "{1}".' -f ($Text, $Path) | Out-File $Results

    Write-Host ('Searching for: "{0}" in "{1}".  Log: "{2}"' -f ($Text, $Path, $Results))
    gci -recurse -include ('*.log', '*.txt') -EA SilentlyContinue| Select-String -pattern $Text | Group-Object Path | Select-Object Name | Format-Table -Wrap | Out-File -Append $Results

    # Show search results.
    if (Test-Path $Results)
    {
        Get-Content $Results
    }
}

<# 
    .SYNOPSIS 
    This script is used to search for files.  The results are logged to a file and that file is displayed in the console.
  
  
    .PARAMETER Path 
    Path to search in.  If no path given, uses the current directory as starting point.

    .PARAMETER Text
    The text to search for in the file names.

    .PARAMETER Results
    The file to log results to.  If not supplied, one is created in $env:Temp based on your search text (with any special characters removed).
    e.g. If you are searching for "env:path" your log file will be "Find-File_envpath.log" in your temporary directory.
  
    .EXAMPLE 
    Find-Log -Path c:\rm\logs -Text "env:path"
  
    .NOTES 
    Company: Deltaware Systems. Copyright (c) DeltaWare Systems Inc. All Rights Reserved.
    Author: Michael Metcalfe
    Date: March 10, 2016
#>
function Find-File
{

param (
    [string]$Path = "",
    [Parameter(Mandatory=$true)]
    [string]$Text,
    [string]$Results = ""
 )

    # If no path specified, assume current working directory
    if (!$Path)
    {
        $Path = (Get-Item -Path ".\" -Verbose).FullName
    }

    # If not results filename given, create one based on the search text (special characters removed).
    if (!$Results)
    {
        $pattern = '[^a-zA-Z ]'
        $fileName = $Text -replace $pattern, ''
        $Results = "$env:temp\Find-File_$fileName.log"
    }

    # Remove results file if it already exists.
    if (Test-Path $Results)
    {
        Remove-Item $Results
    }

    # Add search information to the top of the file.
    'Search results for: "{0}" in "{1}".' -f ($Text, $Path) | Out-File $Results

    Write-Host ('Searching for: "{0}" in "{1}".  Log: "{2}"' -f ($Text, $Path, $Results))
    #| Group-Object Path | Select-Object Name | Format-Table -Wrap | Out-File -Append $results
    gci -EA SilentlyContinue -Path $Path -Filter "*$Text*" -Recurse | Out-File -Append $Results

    # Show search results.
    if (Test-Path $Results)
    {
        Get-Content $Results
    }
}

Export-ModuleMember -Function Find-File, Find-Log, Find-Code