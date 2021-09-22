Param (            
    $srcServer,            
    $srcZone,            
    $destServer,            
    $destZone            
)
if ($destZone -like "10.in-addr.arpa"){
	$zonePrefix = $srcZone -replace ".in-addr.arpa",""
	$zoneChop = ($zonePrefix).Remove(($zonePrefix.LastIndexOf('.')))
}
else {
	$zonePrefix = $srcZone -replace ".168.192.in-addr.arpa",""
	#$zoneChop = ($zonePrefix).Remove(($zonePrefix.LastIndexOf('.')))
	$zoneChop = $zonePrefix
}


$zoneRecords = Get-DnsServerResourceRecord -ZoneName $srcZone -RRType Ptr -ComputerName $srcServer | Select-Object Hostname, TimeToLive, TimeStamp, @{Name='RecordData';Expression={$_.RecordData.PtrDomainName}}
Write-Host "Number of Collected Records:" $zoneRecords.Count

$count = 0

foreach ($i in $zoneRecords) {
	#Write-Host $i.Hostname
	$ptrName = $i.Hostname + "." + $zoneChop
	
	if ($i.TimeStamp -like "") {
		Write-Host "Add records" $ptrName ":" $i.RecordData -ForegroundColor Yellow
		Add-DnsServerResourceRecordPtr -Name $ptrName -ComputerName $destServer -ZoneName $destZone -AllowUpdateAny -TimeToLive $i.TimeToLive -PtrDomainName $i.RecordData -Verbose
	}
	else {
		Write-Host "(AGE) Add records" $ptrName ":" $i.RecordData -ForegroundColor Yellow
		Add-DnsServerResourceRecordPtr -Name $ptrName -ComputerName $destServer -ZoneName $destZone -AllowUpdateAny -AgeRecord -TimeToLive $i.TimeToLive -PtrDomainName $i.RecordData -Verbose
	}
	
	$count = $count + 1
	
}

Write-Host "Number of processed records:" $count




