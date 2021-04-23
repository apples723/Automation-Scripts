#Script Name: Update-PTRs.ps1
#Author: gsiders
#Purpose: gets all DNS records for a certian AD stie(i.e UW1) and retroactivley adds PTR records for those hosts

#DNS zone to search
$ZoneName = "2tor.net"
#DC to use
$DC = "UW1DC01"
#domain to append to PTR domain name
$Domain = ".2tor.net"
#Hostnames to look for
$Filter = "UW1*"
#Reverse zone being updated
$ReverseZone = "72.10.in-addr.arpa"
#Get all records like filter in 2tor zone
$Collection = Get-DnsServerResourceRecord -ZoneName $Zone -RRType A -ComputerName $DC |
Where {($_.Hostname -ne '@') -and ($_.Hostname -ne 'ForestDnsZones') -and ($_.Hostname -ne 'DomainDnsZones') -and $_.Hostname -like $Filter };
Write-Host "PTR Records will be created for the following records:"
$Collection.HostName
#cycles through all records and adds/generates data needed to create ptr record
foreach ($Record in $Collection)
{
	#Reverse Lookup Domain Name
	$PTRDomain = $Record.HostName + $Domain

	#Creates the ip address for the PRT record. 
  #PS will auto append the first two octects and in-addr.arpa based on the selected reverse zone
  #Uses regex to replaced full ip with last two octets 
  #Class C PRT records use the last two octets as /19 prefix requires only one reverse zone that is using the first two octets 
  #Regex Explained: 
  #   () = capture expressions 
  #   \d = select all numbers 0-9
  #   ^ and $ = these explain what parts of the string to capture, ^ is line beggining and $ is end of line
  #   In english the regex expresssion is saying search the whole line from start(^) to end($) and capture(capture statements are in ()) all digits(\d) of each octet (denoted by the . between each capture expression)  
  #The "-replace" powershell operater uses the regex expression and outputs the captured items to $1,$2,$3,$4(these aren't variables and are only availble in the replacement string)
  #After the regex expression denoted with a comma you tell PS your replacement string 
  #So in this case I want the last two octets so captured items 3 & 4 
	$Name = ($Record.RecordData.IPv4Address.ToString() -replace '^(\d+)\.(\d+)\.(\d+).(\d+)$','$4.$3');
	# Add the new PTR record
	Add-DnsServerResourceRecordPtr -Name $Name -ZoneName $ReverseZone -ComputerName $DC -PtrDomainName $PTRDomain -AgeRecord
}


