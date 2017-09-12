$inputFile = "C:\Users\MBMETCAL\Downloads\LEGO Sets - Complete.csv"
$url = "https://brickset.com/sets/70001";
#$url = "https://www.bricklink.com/v2/catalog/catalogitem.page?S=70001-1#T=P"

$LEGOList = Import-Csv $inputFile
###reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /t REG_DWORD /v 1A10 /f /d 0


foreach ($row in $LEGOList)
{
    Write-Debug "Looking up price for $($row.Set)";
    $content = $null;
    $getContent = $null;
    try
    {
        # Retrieve the web page for the set
        $getContent = (iwr -Uri $url -UseBasicParsing);
        #$content = ConvertTo-Xml -InputObject $content.RawContent;
        [xml]$content = $getContent.Content;
        # parse the section that contains the prices
        $innerText = ($content.ParsedHtml.getElementsByTagName('a') | Where{ $_.className -eq 'plain' } ).innerText;
        ## //*[@id="_idStoreResultListSection"]/table/tbody/tr[3]/td[5]/text()


        "New: {0}; Used: {1}" -f ($innerText[2], $innerText[3])
    }
    catch
    {
        Write-Host "Error retrieving price for $($row.Set): $_.ErrorDetails.Message." -ForegroundColor Red -BackgroundColor Black;
        return;
    }
}

###reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 1A10 /f

#if (!$content)
#{
#    $content = (iwr -Uri $url);
#}
##$section = $content.ParsedHtml.getElementById('_idPGContents')
#$innerText = ($content.ParsedHtml.getElementsByTagName('a') | Where{ $_.className -eq 'plain' } ).innerText | Where{ $_ -contains "$"}
#"New: {0}; Used: {1}" -f ($innerText[2], $innerText[3])

#($content.ParsedHtml.getElementsByTagName('meta')) | % { $_.content; }
##$content | Out-File C:\temp\parsed.txt