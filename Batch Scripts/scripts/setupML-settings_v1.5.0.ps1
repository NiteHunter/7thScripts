param([string]$string="Error") 

########################
##     Change Log     ## 
########################
<#
2023-xx-xx: v1.0 Creation
2023-xx-xx: v1.1 Update 1 with new ML-settings parameter list
2024-01-24: v1.2 Change xml output format to target single replication master location (NAS) and use hostnames instead of hardcoded IPs
2024-01-26: v1.3 Change $databaseLeader to match Hosts file value of node 1 Virtual IP.
2024-02-22: v1.4 
2024-03-19: v1.5 Removal of Juggler Database replication from the CTL01-xx machines. Database replication will be handled by the NAS control links, with redundancy via first 4 nodes.
#>

IF($string -eq "Error"){
    Set-Location "C:\Batch Scripts"
    $files = Get-ChildItem -Filter "IP_Schedule*.csv"
    $csv = Import-csv $files[0].FullName
} Else {
    $csv = Import-csv $string
}

# Grab the IP_Schedule for Juggler list
# Set-Location -Path "C:\Batch Scripts"
# $files = Get-ChildItem -Filter "IP_Schedule*.csv"
# $csv = Import-csv $files[0].FullName
# $IPCSV = $csv | Where-Object {($_.TLA -like "JUG*") -and ($_.'Network Port' -eq "eth1")} | Select-Object "IP ADDRESS", "TLA", "Role" -Unique
# $Names = @()
# $IPCSV | ForEach-Object{$Names += $($_.'TLA')}
# $Names2 = @()
# $dataBaseLeader = "hsn01-14"
# $Names2 += $databaseLeader
# # Write-Host "Names: $Names"
# for ($i=0; $i -lt $Names.Length; $i++){
#     $hostname = $($Names[$i])
#     $machineAd = $hostname.ToLower() + "-transfer"
#     $Names2 += $machineAd
# }
# Write-Host "Names2: $Names2"
# $databaseSet = $Names2 -join ';'
# Write-Host "DatabaseSet: $databaseSet"

$dateTime= Get-Date -Format yyyy-MM-dd_HH-mm
$dateTimeStr = $dateTime.ToString()
$hostname = $env:computername
$hostlower = $hostname.ToLower() + "-transfer"
$self = $csv | Where-Object {$_.TLA -like "$hostname"} | Select-Object TLA, "Bank", "Role" -Unique
$self | ForEach{$bank += "$($_.'Bank')"}
$self | ForEach{$role += "$($_.'Role')"}



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
$xml.MediaLogisticsSettings.RemoveAttribute("useCouchDb")
$xml.MediaLogisticsSettings.RemoveAttribute("machineId")
$xml.MediaLogisticsSettings.RemoveAttribute("toggleAssetLocationDistribution")
$xml.MediaLogisticsSettings.RemoveAttribute("remoteAgents")
$xml.MediaLogisticsSettings.SetAttribute("databaseNodeAddresses", "hsn01-01-control;hsn01-02-control;hsn01-03-control;hsn01-04-control")
$xml.MediaLogisticsSettings.SetAttribute("databaseNodeAddressesFrom", "hsn01-01-control;hsn01-02-control;hsn01-03-control;hsn01-04-control")
$xml.MediaLogisticsSettings.SetAttribute("machineName", "$hostname")
$xml.MediaLogisticsSettings.SetAttribute("machineAddress", "$hostlower")

    
if($hostname.Substring(0, 3) -eq "ACT") {
    $xml.MediaLogisticsSettings.SetAttribute("watchFolder", "E:\Watch")
    $xml.MediaLogisticsSettings.SetAttribute("assetVault", "E:\Vault")
    $xml.MediaLogisticsSettings.SetAttribute("assetVaultTags", "local;actor;$section")
}
if($hostname.Substring(0, 3) -eq "CNJ") {
    $xml.MediaLogisticsSettings.SetAttribute("watchFolder", "H:\Watch")
    $xml.MediaLogisticsSettings.SetAttribute("assetVault", "H:\Vault")
    $xml.MediaLogisticsSettings.SetAttribute("assetVaultTags", "local;conjurer;$section")
}
if($hostname.Substring(0, 3) -eq "CTL") {
    $xml.MediaLogisticsSettings.SetAttribute("watchFolder", "C:\Watch")
    $xml.MediaLogisticsSettings.SetAttribute("assetVault", "C:\Vault")
    $xml.MediaLogisticsSettings.SetAttribute("assetVaultTags", "control")
}


$xml.ChildNodes[0].Encoding = $null
$xml.Save($filepath)

Write-Host "All set"
# Read-Host "Press Enter to Terminate"