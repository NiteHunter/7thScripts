param([string]$string="Error") 

Write-Host "This script can take a param of a Juggler hostname or screen role/position, and executes the update command by establishing an SSH session for each."
Write-Host "Acceptable input formats are: "
Write-Host "    JUGxx-xx        -this specifies the Juggler hostname to update."
# Write-Host "    A#              -this specifies the Bank A position of the Juggler to update. For instance: `"A1`" would update JUG02-01" # THIS functionality needs an update
# Write-Host "    B#              -this specifies the Bank B position of the Juggler to update. For instance: `"B1`" would update JUG02-04" # THIS functionality needs an update
Write-Host "    AA              -this specifies all Bank A Jugglers to update."
Write-Host "    BB              -this specifies all Bank B Jugglers to update."
Write-Host "    All             -this specifies all Jugglers to update."
Write-Host ""
Write-Host "This script can be run with a parameter during execution, or by using a prompt."

if($string -eq "Error"){
    $string = Read-Host "Specify which Juggler you wish to update based on the rules above"
}

# Grab the IP_Schedule for Juggler list
Set-Location -Path "C:\Batch Scripts"
$files = Get-ChildItem -Filter "IP_Schedule*.csv"
$csv = Import-csv $files[0].FullName


$IPs = @()
$Names = @()
$Sections = @()
# Juggler section process
switch ($string) {
    'All' {
        $IPCSV = $csv | Where-Object {($_.TLA -like "JUG*") -and ($_.'Network Port' -eq "eth1")} | Select-Object "IP ADDRESS", "TLA", "Role" -Unique
        $IPCSV | ForEach-Object{$IPs += "$($_.'IP ADDRESS')"}
        $IPCSV | ForEach-Object{$Names += "$($_.'TLA')"}
        $IPCSV | ForEach-Object{$Sections += "$($_.'Role')"}
    }
    'AA' {
        $IPCSV = $csv | Where-Object {($_.TLA -like "JUG*") -and ($_.'Network Port' -eq "eth1") -and ($_.'Bank' -eq "A")} | Select-Object "IP ADDRESS", "TLA", "Role" -Unique
        $IPCSV | ForEach-Object{$IPs += "$($_.'IP ADDRESS')"}
        $IPCSV | ForEach-Object{$Names += "$($_.'TLA')"}
        $IPCSV | ForEach-Object{$Sections += "$($_.'Role')"}
    }
    'BB' {
        $IPCSV = $csv | Where-Object {($_.TLA -like "JUG*") -and ($_.'Network Port' -eq "eth1") -and ($_.'Bank' -eq "B")} | Select-Object "IP ADDRESS", "TLA", "Role" -Unique
        $IPCSV | ForEach-Object{$IPs += "$($_.'IP ADDRESS')"}
        $IPCSV | ForEach-Object{$Names += "$($_.'TLA')"}
        $IPCSV | ForEach-Object{$Sections += "$($_.'Role')"}
    }
    Default {
        if($string.Substring(0,1) -eq "J"){
            $IPCSV = $csv | Where-Object {($_.TLA -like $string) -and ($_.'Network Port' -eq "eth1")} | Select-Object "IP ADDRESS", "TLA", "Role" -Unique
            $IPCSV | ForEach-Object{$IPs += "$($_.'IP ADDRESS')"}
            $IPCSV | ForEach-Object{$Names += "$($_.'TLA')"}
            $IPCSV | ForEach-Object{$Sections += "$($_.'Role')"}
        } else {
            $IPCSV = $csv | Where-Object {($_.TLA -like "JUG*") -and ($_.'Network Port' -eq "eth1") -and ($_.'Role' -eq $string)} | Select-Object "IP ADDRESS", "TLA", "Role" -Unique
            $IPCSV | ForEach-Object{$IPs += "$($_.'IP ADDRESS')"}
            $IPCSV | ForEach-Object{$Names += "$($_.'TLA')"}
            $IPCSV | ForEach-Object{$Sections += "$($_.'Role')"}
        }
    }
}

# Setup
# Path to Plink.exe - update this if necessary!
$plinkPath = "C:\Batch Scripts\"
$copyToPath = ":/7thApps/AssetLogistics/bin"
$sshPort = 22
$sshUser = "root"
$sshPassword = "7thJuggler"
$filepath = "C:\7thSense\compere\ML-settings.xml"
# Command to execute
$remoteCommand1 = "mkdir -p /nvdata/Watch"
$remoteCommand2 = "asset-logistics restart"

Set-Location $plinkPath

# Command
for ($i=0; $i -lt $IPs.Length; $i++){
    $hostname = $($Names[$i])
    $machineAd = $hostname.ToLower() + "-transfer"
    $ip = $($IPs[$i])
    $section = "section_" + $($Sections[$i])
    # Write-Host $hostname + ", " + $ip
    $xml = [xml](Get-Content $filepath)
    $xml.MediaLogisticsSettings.RemoveAttribute("useCouchDb")
    $xml.MediaLogisticsSettings.RemoveAttribute("machineId")
    $xml.MediaLogisticsSettings.RemoveAttribute("toggleAssetLocationDistribution")
    $xml.MediaLogisticsSettings.RemoveAttribute("remoteAgents")
    $xml.MediaLogisticsSettings.SetAttribute("databaseNodeAddresses", "")
    $xml.MediaLogisticsSettings.SetAttribute("databaseNodeAddressesFrom", "")
    $xml.MediaLogisticsSettings.SetAttribute("machineName", "$hostname")
    $xml.MediaLogisticsSettings.SetAttribute("machineAddress", "$machineAd")
    $xml.MediaLogisticsSettings.SetAttribute("watchFolder", "/nvdata/Watch")
    $xml.MediaLogisticsSettings.SetAttribute("assetVault", "/nvdata/Vault")
    $xml.MediaLogisticsSettings.SetAttribute("assetVaultTags", "juggler;$section")
    $xml.MediaLogisticsSettings.SetAttribute("databaseHostAddress", "192.168.3.14")

    New-Item -ItemType Directory -Path "C:\Batch Scripts\Temp\$hostname"
    $sourceFile = "C:\Batch Scripts\Temp\$hostname\ML-settings.xml"
    $xml.ChildNodes[0].Encoding = $null
    $xml.Save($sourceFile)

    Write-Host "Sending ML-Settings File to $hostname"
    .\pscp.exe -scp -l $sshUser -pw $sshPassword $sourceFile $sshUser@$ip$copyToPath
    Invoke-Expression -Command ".\plink.exe -ssh -P $sshPort -l $sshUser -pw $sshPassword $ip `"$remoteCommand1`""
    # Invoke-Expression -Command ".\plink.exe -ssh -P $sshPort -l $sshUser -pw $sshPassword $ip `"$remoteCommand2`""
}

# Remove the Temp Folder
Remove-Item -Path "C:\Batch Scripts\Temp\" -R