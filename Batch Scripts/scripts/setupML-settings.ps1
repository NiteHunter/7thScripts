param([string]$string="Error") 

IF($string -eq "Error"){
    Set-Location "C:\Batch Scripts"
    $files = Get-ChildItem -Filter "IP_Schedule*.csv"
    $csv = Import-csv $files[0].FullName
} Else {
    $csv = Import-csv $string
}

$nodeIPs = @()
#$csv = importHosts
$nodes = $csv | Where-Object {$_.TLA -like "ACT01*" -or $_.TLA -like "ACT02*" -or $_.TLA -like "CTL*" -and $_.'Network Port' -eq "Storage_01"} | Select-Object TLA, "IP Address", "Bank", "Role" -Unique
$nodes | ForEach{$nodeIPs += "$($_.'IP Address')"}
$dateTime= Get-Date -Format yyyy-MM-dd_HH-mm
$dateTimeStr = $dateTime.ToString()
$hostname = $env:computername
$self = $csv | Where-Object {$_.TLA -like "$hostname" -and $_.'Network Port' -eq "Storage_01"} | Select-Object TLA, "IP Address", "Bank", "Role" -Unique
$self | ForEach{$ip += "$($_.'IP Address')"}
$self | ForEach{$bank += "$($_.'Bank')"}
$self | ForEach{$role += "$($_.'Role')"}
Write-Host $ip

########################
## local distribution ## 
########################

$filePath = "C:\7thSense\compere\ML-settings.xml"
$filepathBackup = "C:\7thSense\compere\ML-settings.xml_$dateTimeStr.xml"
if(Test-Path $filePath){Rename-Item -Path $filePath -NewName $filePathBackup -Force} 
Copy-Item -Path "$PSScriptRoot\ML-settings.xml" -Destination $filePath -Force

$nodeList = @()

ForEach($i in $nodeIPs){
    if($i -ne $ip){$nodeList += $i}
}
$ofs = ';'
[String]$nodeList
Write-Host $nodeList

$xml = [xml](Get-Content $filepath)
#$uuid = Get-Content -Path "C:\Users\7thSense Design Ltd\AppData\Local\Compere\machine-id.txt"
$section = "section_" + $role
$xml.MediaLogisticsSettings.SetAttribute("databaseNodeAddresses", "$nodeList")
$xml.MediaLogisticsSettings.RemoveAttribute("useCouchDb")
$xml.MediaLogisticsSettings.RemoveAttribute("machineId")
$xml.MediaLogisticsSettings.SetAttribute("machineName", "$hostname")
$xml.MediaLogisticsSettings.SetAttribute("machineAddress", "$ip")
$xml.MediaLogisticsSettings.RemoveAttribute("toggleAssetLocationDistribution")
$xml.MediaLogisticsSettings.RemoveAttribute("remoteAgents")
    
if($hostname -ne "CTL01-01") {
    $xml.MediaLogisticsSettings.SetAttribute("watchFolder", "E:\Watch")
    $xml.MediaLogisticsSettings.SetAttribute("assetVault", "E:\Vault")
    $xml.MediaLogisticsSettings.SetAttribute("assetVaultTags", "local;actor;$section")
} else {
    $xml.MediaLogisticsSettings.SetAttribute("watchFolder", "N:\Watch")
    $xml.MediaLogisticsSettings.SetAttribute("assetVault", "N:\Vault")
    $xml.MediaLogisticsSettings.SetAttribute("assetVaultTags", "nas")
}

$xml.ChildNodes[0].Encoding = $null
$xml.Save($filepath)

# Read-Host "Press Enter to Terminate"