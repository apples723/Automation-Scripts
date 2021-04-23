#Script Name: Update-PTRs.ps1
#Author: gsiders
#Purpose: gets all DNS records for a certian AD stie(i.e UW1) and retroactivley adds PTR records for those hosts

#DNS zone to search
$ZoneName = "myzone.com"
#DC to use
$DC = "MY-DC-NAME"
#domain to append to PTR domain name
$Domain = ".myzone.com"
#Hostnames to look for based on naming convention (i.e servers in us-east-1 use the prefix UE1) 
$Filter = "UE*"
#Reverse zone being updated
$ReverseZone = "reverse.zone.in-addr.arpa"
#Gets all records like filter in given search zone
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


