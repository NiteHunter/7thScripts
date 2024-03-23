param([string]$string="Error") 

########################
##     Change Log     ## 
########################
<#
2023-xx-xx: Creation
2024-01-24: Change xml output format to target single replication master location (NAS) and use hostnames instead of hardcoded IPs
#>

IF($string -eq "Error"){
    Set-Location "C:\Batch Scripts"
    $files = Get-ChildItem -Filter "IP_Schedule*.csv"
    $csv = Import-csv $files[0].FullName
} Else {
    $csv = Import-csv $string
}

# $nodeIPs = @()
#$csv = importHosts
# $nodes = $csv | Where-Object {$_.TLA -like "ACT01*" -or $_.TLA -like "ACT02*" -or $_.TLA -like "CTL*" -and $_.'Network Port' -eq "Storage_01"} | Select-Object TLA, "IP Address", "Bank", "Role" -Unique
# $nodes | ForEach{$nodeIPs += "$($_.'IP Address')"}
# $nodeList = @()
# ForEach($i in $nodeIPs){
#     if($i -ne $ip){$nodeList += $i}
# }
# $ofs = ';'
# [String]$nodeList
# Write-Host $nodeList

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

########################
##    XML creation    ## 
########################

$xml = [xml](Get-Content $filepath)
#$uuid = Get-Content -Path "C:\Users\7thSense Design Ltd\AppData\Local\Compere\machine-id.txt"
$section = "section_" + $role
$xml.MediaLogisticsSettings.SetAttribute("databaseNodeAddresses", "$databaseLeader")
$xml.MediaLogisticsSettings.SetAttribute("databaseNodeAddressesFrom", "$databaseLeader")
$xml.MediaLogisticsSettings.RemoveAttribute("useCouchDb")
$xml.MediaLogisticsSettings.RemoveAttribute("machineId")
$xml.MediaLogisticsSettings.SetAttribute("machineName", "$hostname")
$xml.MediaLogisticsSettings.SetAttribute("machineAddress", "$hostname")
$xml.MediaLogisticsSettings.RemoveAttribute("toggleAssetLocationDistribution")
$xml.MediaLogisticsSettings.RemoveAttribute("remoteAgents")
    
if($hostname.Substring(0, 3) -eq "ACT") {
    $xml.MediaLogisticsSettings.SetAttribute("watchFolder", "E:\Watch")
    $xml.MediaLogisticsSettings.SetAttribute("assetVault", "E:\Vault")
    $xml.MediaLogisticsSettings.SetAttribute("assetVaultTags", "local;actor;$section")
} else if($hostname.Substring(0, 3) -eq "CNJ") {
    $xml.MediaLogisticsSettings.SetAttribute("watchFolder", "H:\Watch")
    $xml.MediaLogisticsSettings.SetAttribute("assetVault", "H:\Vault")
    $xml.MediaLogisticsSettings.SetAttribute("assetVaultTags", "local;conjurer;$section")
} else if($hostname.Substring(0, 3) -eq "CTL") {
    $xml.MediaLogisticsSettings.SetAttribute("watchFolder", "C:\Watch")
    $xml.MediaLogisticsSettings.SetAttribute("assetVault", "C:\Vault")
    $xml.MediaLogisticsSettings.SetAttribute("assetVaultTags", "control")
}


$xml.ChildNodes[0].Encoding = $null
$xml.Save($filepath)

# Read-Host "Press Enter to Terminate"