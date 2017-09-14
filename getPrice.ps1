$inputFile = "C:\Users\MBMETCAL\Downloads\LEGO Sets - Incomplete.csv";
$errorFile = $inputFile.Replace(".csv", " - Error.csv");
$outputFile = $inputFile.Replace(".csv", " - Revised.csv");

#$bricksetURL = "https://brickset.com/sets/70001";
#$bricksetURL = "https://www.bricklink.com/v2/catalog/catalogitem.page?S=70001-1#T=P"

if (!(Test-Path $inputFile))
{
    Write-Host ('Could not find input file "{0}".' -f ($inputFile)) -ForegroundColor Red -BackgroundColor Black;
    return;
}

if (Test-Path $errorFile)
{
    Remove-Item $errorFile;
}

###reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /t REG_DWORD /v 1A10 /f /d 0
# First get the number of lines
$numSets = (Import-Csv $inputFile | Measure-Object).Count;

$recordNumber = 0;
Write-Progress -Activity 'Getting prices...' -PercentComplete 0 -Status "0% completed"

Import-Csv $inputFile | 
ForEach-Object {
    $recordNumber++;
    $percentComplete = [math]::Round($(($recordNumber/$numSets)*100));

    $content = $null;
    try
    {
        $setNumber = $($_.'Set #');
        $setName = $($_.Set);
        $setSeries = $($_.Series);

        if (!$setNumber -or ($setNumber.Trim().length -eq 0)) { return; }

        $bricksetURL = "https://brickset.com/sets/{0}" -f ($setNumber);
        $bricklinkURL = "https://www.bricklink.com/v2/catalog/catalogitem.page?S={0}#T=P" -f ($setNumber);

        # Retrieve the web page for the set
        $content = (iwr -Uri $bricksetURL);

        # parse the section that contains the prices
        $innerText = ($content.ParsedHtml.getElementsByTagName('a') | Where{ $_.className -eq 'plain' -and $_.hostname -eq "www.bricklink.com"} ).textContent;
        
        if ($innerText -is [array])
        {
            $newPrice = if ($innerText[0]) {$innerText[0]} else {"0"};
            $usedPrice = if ($innerText[1]) {$innerText[1]} else {"0"};
        }
        else
        {
            $newPrice = if ($innerText) {$innerText} else {"0"};
            $usedPrice = "0";
        }
        $newPrice = $newPrice.Replace("~CA$", "");
        $usedPrice = $usedPrice.Replace("~CA$", "");
        #Write-Host ("{0} ({1}): New: {2}; Used: {3}; Link: {4}" -f ($setName, $setNumber, $newPrice, $usedPrice, $bricklinkURL));

        # Add new columns to the csv
        $_ | 
        Add-Member -MemberType NoteProperty -Name "New Price" -Value $newPrice -PassThru | 
        Add-Member -MemberType NoteProperty -Name "Used Price" -Value $usedPrice -PassThru |
        Add-Member -MemberType NoteProperty -Name "Brickset Link" -Value $bricksetURL -PassThru | 
        Add-Member -MemberType NoteProperty -Name "Bricklink Link" -Value $bricklinkURL -PassThru

        Write-Progress -Activity 'Getting prices...' -PercentComplete $percentComplete -Status "$percentComplete% completed"
    }
    catch
    {
        '"{0}", "{1}", "{2}", "{3}", "{4}"' -f ($setName, $setSeries, $setNumber, $bricksetURL, $bricklinkURL) | Out-File -FilePath $errorFile -Append
        Write-Host ("Error retrieving price for {0} ({1}): {2}." -f ($setName, $setNumber, $_)) -ForegroundColor Red -BackgroundColor Black;
    }
} |
Export-Csv $outputFile -NoTypeInformation

###reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 1A10 /f