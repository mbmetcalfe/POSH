$inputFile = "C:\Users\MBMETCAL\Downloads\LEGO Sets - Complete.csv";
$errorFile = $inputFile.Replace("Complete", "Error");

#$bricksetURL = "https://brickset.com/sets/70001";
#$bricksetURL = "https://www.bricklink.com/v2/catalog/catalogitem.page?S=70001-1#T=P"

if (Test-Path $errorFile)
{
    Remove-Item $errorFile;
}

$LEGOList = Import-Csv $inputFile;
###reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /t REG_DWORD /v 1A10 /f /d 0

foreach ($row in $LEGOList)
{
    $content = $null;
    try
    {
        $setNumber = $($row.'Set #');
        $setName = $($row.Set);
        $setSeries = $($row.Series);

        $bricksetURL = "https://brickset.com/sets/{0}" -f ($setNumber);
        $bricklinkURL = "https://www.bricklink.com/v2/catalog/catalogitem.page?S={0}#T=P" -f ($setNumber);
        
        # Retrieve the web page for the set
        $content = (iwr -Uri $bricksetURL);

        # parse the section that contains the prices
        $innerText = ($content.ParsedHtml.getElementsByTagName('a') | Where{ $_.className -eq 'plain' -and $_.hostname -eq "www.bricklink.com"} ).textContent
        Write-Debug "Inner Text: $innerText"
        $newPrice = if (($innerText[0]) -and ($innerText[0] -contains "$")) {$innerText[0]} else {"n/a"}
        $usedPrice = if (($innerText[1]) -and ($innerText[1] -contains "$")) {$innerText[1]} else {"n/a"}

        Write-Host ("{0} ({1}): New: {2}; Used: {3}; Link: {4}" -f ($setName, $setNumber, $newPrice, $usedPrice, $bricklinkURL))
    }
    catch
    {
        '"{0}", "{1}", "{2}", "{3}", "{4}"' -f ($setName, $setSeries, $setNumber, $bricksetURL, $bricklinkURL) | Out-File -FilePath $errorFile -Append
        Write-Host ("Error retrieving price for {0} ({1}): {2}." -f ($setName, $setNumber, $_)) -ForegroundColor Red -BackgroundColor Black;
    }
}

$LEGOList = $null

###reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 1A10 /f

#if (!$content)
#{
#    $content = (iwr -Uri $bricksetURL);
#}
##$section = $content.ParsedHtml.getElementById('_idPGContents')
#$innerText = ($content.ParsedHtml.getElementsByTagName('a') | Where{ $_.className -eq 'plain' } ).innerText | Where{ $_ -contains "$"}
#"New: {0}; Used: {1}" -f ($innerText[2], $innerText[3])

#($content.ParsedHtml.getElementsByTagName('meta')) | % { $_.content; }
##$content | Out-File C:\temp\parsed.txt