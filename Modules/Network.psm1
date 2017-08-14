<# 
    .SYNOPSIS 
    Measure the latency between two computers.

    .DESCRIPTION 
    This command can be used to measure the latency between a source computer and one or more other computers.
    If a source computer is specified, you must supply login credentials for that computer.

    .PARAMETER Target 
    One or more targets to test.

    .PARAMETER Source
    Source location to test.

    .PARAMETER PacketCount
    How many packets to send between the source and destination locations.

    .EXAMPLE 
    Measure-Latency -Target www.google.ca

    Measure the latency between your computer and www.google.ca

    .EXAMPLE 
    Measure-Latency -Target (Get-Content c:\targets.txt)

    Measure the latency between your computer and the computers listed in c:\targets.txt

    .EXAMPLE 
    Measure-Latency -Target www.google.ca -Source 192.168.0.4 -PacketCount 10

    Measure the latency betwen 192.168.0.4 and www.google.ca, sending 10 packets.
  
    .NOTES 
    Author: Michael Metcalfe
    Date: March 23, 2017
#>
Function Measure-Latency
{
    #Parameter Definition
    Param
    (
        [Parameter(position = 1, mandatory = $true)] $Target,
        [Parameter(Position = 0)] $Source,
        [Parameter(Position = 2)] $PacketCount = 4
    )

    if ($Target.count -gt 1)
    {
        Write-Progress -Activity 'Sending Packets to Target Computers and collecting Information' -PercentComplete 0 -Status "0% completed"
    }

    #Conditions to check if credentials are required
    if($Source -ne $null)
    {
        $creds = Get-Credential -Message "Credentials are mandatory to check latency from other Sources"
        $i=1

        $Target | %{
            #Tweaking Test-Connection cmdlet to get the desired output               
            $name = $_; Test-Connection -Source $source -ComputerName $_ -Count $PacketCount -Credential $creds| `
            Measure-Object ResponseTime -Maximum -Minimum -Average | select @{name='Source Computer';expression={$Source}}, `
            @{name='Target Computer';expression={$name}},  @{name='Packet Count';expression={$_.count}},`
            @{name='Maximum Time(ms)';expression={$_.Maximum}}, @{name='Minimum Time(ms)';expression={$_.Minimum}}, @{name='Average Time(ms)';expression={$_.Average}} 
        
            #Writing the progress of latency calculation
            Write-Progress -Activity 'Sending Packets to Target Computers and collecting Information' -PercentComplete $(($i/$Target.count)*100) -Status "$(($i/$Target.count)*100)% completed"

            $i++
        }|Format-Table * -auto
    }
    elseif ($source -eq $null)
    {
        $Source  = hostname
        $i=1

        $Target | %{
            #Tweaking Test-Connection cmdlet to get the desired output
            $name = $_; Test-Connection -Source $source -ComputerName $_ -Count $PacketCount| `
            Measure-Object ResponseTime -Maximum -Minimum -Average | select @{name='Source Computer';expression={$Source}},`
            @{name='Target Computer';expression={$name}},  @{name='Packet Count';expression={$_.count}},`
            @{name='Maximum Time(ms)';expression={$_.Maximum}}, @{name='Minimum Time(ms)';expression={$_.Minimum}}, @{name='Average Time(ms)';expression={$_.Average}}
        
            #Writing the Progress of Latency Calculation
            Write-Progress -Activity 'Sending Packets to Target Computers and collecting Information' -PercentComplete $(($i/$Target.count)*100) -Status "$(($i/$Target.count)*100)% completed"

            $i++
        }|Format-Table * -auto
    }
} 

Set-Alias ml Measure-Latency