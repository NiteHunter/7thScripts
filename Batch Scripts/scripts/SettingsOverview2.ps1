param([int]$param=0) 

# Bitwise SUM isn't working!!!!! Grrr
<# Per device:
        To add ACT01s +256
        To add ACT02s +128
        To add CNJ01s +64
        To add CNJ02s +23
        To add CTL01s +16
        To add DMS01s +8
        To add JUG01s +4
        To add JUG02s +2
        To add JUG03s +1

    # Big Dome all devices: 340
    # Big Top all devices: 511
    # Big Dome sans CNJs: 276
    # Big Top sans CNJs & DMSs: 407
#>

$currentDirectory = $PWD.Path

IF($param -eq 0){  
    do {$IncludeACT01 = Read-Host "Enter 1 to include ACT01 servers, or 0 to exclude"} while ($IncludeACT01 -notin '0', '1')
    do {$IncludeACT02 = Read-Host "Enter 1 to include ACT02 servers, or 0 to exclude"} while ($IncludeACT02 -notin '0', '1')
    do {$IncludeCNJ01 = Read-Host "Enter 1 to include CNJ01 servers, or 0 to exclude"} while ($IncludeCNJ01 -notin '0', '1')
    do {$IncludeCNJ02 = Read-Host "Enter 1 to include CNJ02 servers, or 0 to exclude"} while ($IncludeCNJ02 -notin '0', '1')
    do {$IncludeCTL01 = Read-Host "Enter 1 to include CTL01 servers, or 0 to exclude"} while ($IncludeCTL01 -notin '0', '1')
    do {$IncludeDMS01 = Read-Host "Enter 1 to include DMS01 servers, or 0 to exclude"} while ($IncludeDMS01 -notin '0', '1')
    do {$IncludeJUG01 = Read-Host "Enter 1 to include JUG01 Jugglers, or 0 to exclude"} while ($IncludeJUG01 -notin '0', '1')
    do {$IncludeJUG02 = Read-Host "Enter 1 to include JUG02 Jugglers, or 0 to exclude"} while ($IncludeJUG02 -notin '0', '1')
    do {$IncludeJUG03 = Read-Host "Enter 1 to include JUG03 Jugglers, or 0 to exclude"} while ($IncludeJUG03 -notin '0', '1')
} Else {
    # Convert Bitwise value to binary array 
    $clientTypes = [Convert]::ToString($param,2).PadLeft(9,'0') 
    $clientTypeArray = $clientTypes.ToCharArray() 

    $IncludeACT01 = $clientTypeArray[8]
    $IncludeACT02 = $clientTypeArray[7]
    $IncludeCNJ01 = $clientTypeArray[6]
    $IncludeCNJ02 = $clientTypeArray[5]
    $IncludeCTL01 = $clientTypeArray[4]
    $IncludeDMS01 = $clientTypeArray[3]
    $IncludeJUG01 = $clientTypeArray[2]
    $IncludeJUG02 = $clientTypeArray[1]
    $IncludeJUG03 = $clientTypeArray[0]

    $IncludeACT01 = [Convert]::ToInt32($IncludeACT01)
    $IncludeACT02 = [Convert]::ToInt32($IncludeACT02)
    $IncludeCNJ01 = [Convert]::ToInt32($IncludeCNJ01)
    $IncludeCNJ02 = [Convert]::ToInt32($IncludeCNJ02)
    $IncludeCTL01 = [Convert]::ToInt32($IncludeCTL01)
    $IncludeDMS01 = [Convert]::ToInt32($IncludeDMS01)
    $IncludeJUG01 = [Convert]::ToInt32($IncludeJUG01)
    $IncludeJUG02 = [Convert]::ToInt32($IncludeJUG02)
    $IncludeJUG03 = [Convert]::ToInt32($IncludeJUG03)
}

# Write-Host $IncludeACT01
# Write-Host $IncludeACT02
# Write-Host $IncludeCNJ01
# Write-Host $IncludeCNJ02
# Write-Host $IncludeCTL01
# Write-Host $IncludeDMS01
# Write-Host $IncludeJUG01
# Write-Host $IncludeJUG02
# Write-Host $IncludeJUG03

# Retreive the IP_Schedule
Set-Location "C:\Batch Scripts"
$files = Get-ChildItem -Filter "IP_Schedule*.csv"
$csv = Import-csv $files[0].FullName

# Create the XML array
$xmlProperties = @()

# Juggler Access values
$pscpPath = "C:\Batch Scripts\"
$copyFromPath = ":/7thApps/compere/bin/Preferences.pref"
$sshPort = 22
$sshUser = "root"
$sshPassword = "7thJuggler"
Set-Location $pscpPath

$output = "C:\Batch Scripts\settingsOverview_preferences.csv"
# Define the properties you want to extract
$xmlProperties += "//PreferencesSet/Preferences/aliases[@value]"
$xmlProperties += "//PreferencesSet/Preferences/count-repeated-log-messages[@value]"
$xmlProperties += "//PreferencesSet/Preferences/open-comms-delay-ms[@value]"
$xmlProperties += "//PreferencesSet/Preferences/new-tree-usage-delay-ms[@value]"
$xmlProperties += "//PreferencesSet/Preferences/failover-score[@value]"
$xmlProperties += "//PreferencesSet/Preferences/failover-heartbeat-interval[@value]"
$xmlProperties += "//PreferencesSet/Preferences/failover-election-interval[@value]"
$xmlProperties += "//PreferencesSet/Preferences/failover-initial-grace-period[@value]"
$xmlProperties += "//PreferencesSet/Preferences/failover-heartbeat-port[@value]"
$xmlProperties += "//PreferencesSet/Preferences/compere-discovery-port[@value]"
$xmlProperties += "//PreferencesSet/Preferences/instance-colour[@value]"
$xmlProperties += "//PreferencesSet/Preferences/selected-nic-name[@value]"
$xmlProperties += "//PreferencesSet/Preferences/online[@value]"
$xmlProperties += "//PreferencesSet/Preferences/project-group[@value]"
$xmlProperties += "//PreferencesSet/Preferences/collated-system-reports-location[@value]"
$xmlProperties += "//PreferencesSet/Preferences/time-client-response-timeout-milliseconds[@value]"
$xmlProperties += "//PreferencesSet/Preferences/time-client-request-interval-milliseconds[@value]"
$xmlProperties += "//PreferencesSet/Preferences/time-client-num-failed-requests-before-reconnection[@value]"
$xmlProperties += "//PreferencesSet/Preferences/enablenetnet[@value]"
$xmlProperties += "//PreferencesSet/Preferences/preferredTree[@value]"
$xmlProperties += "//PreferencesSet/Preferences/externalControlUDPRxPort[@value]"
$xmlProperties += "//PreferencesSet/Preferences/externalControlUDPTxPort[@value]"
$xmlProperties += "//PreferencesSet/Preferences/externalControlTCPPort[@value]"
$xmlProperties += "//PreferencesSet/Preferences/external-control-adapter-tcp-port[@value]"
$xmlProperties += "//PreferencesSet/Preferences/externalControlTCPTimeoutTimeSecs[@value]"
$xmlProperties += "//PreferencesSet/Preferences/UDPdiscoveryPort[@value]"
$xmlProperties += "//PreferencesSet/Preferences/UDPremoteConfigPort[@value]"
$xmlProperties += "//PreferencesSet/Preferences/TCPconnectionPort[@value]"
$xmlProperties += "//PreferencesSet/Preferences/NumBcastPktsToProcessPerTick[@value]"
$xmlProperties += "//PreferencesSet/Preferences/CommsMode[@value]"
$xmlProperties += "//PreferencesSet/Preferences/CurrentProjectID[@value]"
$xmlProperties += "//PreferencesSet/Preferences/EnableDebug[@value]"
$xmlProperties += "//PreferencesSet/Preferences/UseLocalRenderSettings[@value]"
$xmlProperties += "//PreferencesSet/Preferences/mpcdiOutputDebugImages[@value]"
$xmlProperties += "//PreferencesSet/Preferences/EnableAudio[@value]"
$xmlProperties += "//PreferencesSet/Preferences/broadcast-logging-enabled[@value]"
$xmlProperties += "//PreferencesSet/Preferences/broadcast-logging-udp-port[@value]"
$xmlProperties += "//PreferencesSet/Preferences/ml-watch-folder-path[@value]"
$xmlProperties += "//PreferencesSet/Preferences/ml-vault-folder-path[@value]"
$xmlProperties += "//PreferencesSet/Preferences/ml-ip-address[@value]"
$xmlProperties += "//PreferencesSet/Preferences/asset-playback-location[@value]"
$xmlProperties += "//PreferencesSet/Preferences/lock-to-vsync[@value]"
$xmlProperties += "//PreferencesSet/Preferences/actor-show-stats[@value]"
$xmlProperties += "//PreferencesSet/Preferences/st2110-ip-address[@value]"
$xmlProperties += "//PreferencesSet/Preferences/use-st2110-sync[@value]"
$xmlProperties += "//PreferencesSet/Preferences/st2110-framerate[@value]"
$xmlProperties += "//PreferencesSet/Preferences/st2110-packet-burst-size[@value]"
$xmlProperties += "//PreferencesSet/Preferences/st2110-default-sdp-path[@value]"
$xmlProperties += "//PreferencesSet/Preferences/st2110-use-ptp-as-system-time[@value]"
$xmlProperties += "//PreferencesSet/Preferences/enable-time-sync[@value]"
$xmlProperties += "//PreferencesSet/Preferences/path-format[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-general[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-audio[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-comms[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-config[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-conjurer[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-events[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-external-control[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-failover[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-juggler[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-licensing[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-logic-nodes[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-media-library[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-network[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-rendering[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-timelines[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-timing[@value]"
$xmlProperties += "//PreferencesSet/Preferences/minimum-log-level-for-warp-mapping[@value]"
$xmlProperties += "//PreferencesSet/Preferences/enableRendererNatNetRx[@value]"
$xmlProperties += "//PreferencesSet/Preferences/enableWaitForPresent[@value]"
$xmlProperties += "//PreferencesSet/Preferences/framebufferFormat[@value]"
$xmlProperties += "//PreferencesSet/Preferences/defaultRenderBackGroundColour[@value]"
$xmlProperties += "//PreferencesSet/Preferences/set-property-over-time-delay[@value]"
$xmlProperties += "//PreferencesSet/Preferences/confirm-close[@value]"
$xmlProperties += "//PreferencesSet/Preferences/enabled[@value]"
$xmlProperties += "//PreferencesSet/Preferences/state[@value]"
$xmlProperties += "//PreferencesSet/Preferences/direction[@value]"
$xmlProperties += "//PreferencesSet/Preferences/icon[@value]"
$xmlProperties += "//PreferencesSet/Preferences/dynamicicon[@value]"

# Reformat the values to be csv headers
$xmlProperties2 = $xmlProperties -replace "//PreferencesSet/Preferences/"
$xmlProperties3 = $xmlProperties2 -replace "@value"
$header = "Hostname," + $($xmlProperties3 -join ",")
Write-Host "Searching for these properties from the $output file:"
Write-Host $header

# Backup existing CSV file
$backup = $output.Substring(0, $output.Length - 4) + "_archived_" + $(Get-Date -Format "yyyy-MM-dd_hhmmss") + ".csv"
Rename-Item -Path $output -NewName $backup -Force

# retrieve Client list
$clients = @()
$act01CSV = $csv | Where-Object {($_.TLA -like "ACT01*") -and ($_.'Network Port' -eq "Onboard_01")} | Select-Object "TLA" -Unique
$act02CSV = $csv | Where-Object {($_.TLA -like "ACT02*") -and ($_.'Network Port' -eq "Onboard_01")} | Select-Object "TLA" -Unique
$cnj01CSV = $csv | Where-Object {($_.TLA -like "CNJ01*") -and ($_.'Network Port' -eq "Onboard_01")} | Select-Object "TLA" -Unique
$cnj02CSV = $csv | Where-Object {($_.TLA -like "CNJ02*") -and ($_.'Network Port' -eq "Onboard_01")} | Select-Object "TLA" -Unique
$ctl01CSV = $csv | Where-Object {($_.TLA -like "CTL01*") -and ($_.'Network Port' -eq "Onboard_01")} | Select-Object "TLA" -Unique
$dms01CSV = $csv | Where-Object {($_.TLA -like "DMS01*") -and ($_.'Network Port' -eq "Onboard_01")} | Select-Object "TLA" -Unique
$jug01CSV = $csv | Where-Object {($_.TLA -like "JUG01*") -and ($_.'Network Port' -eq "eth1")} | Select-Object "TLA", 'IP ADDRESS' -Unique
$jug02CSV = $csv | Where-Object {($_.TLA -like "JUG02*") -and ($_.'Network Port' -eq "eth1")} | Select-Object "TLA", 'IP ADDRESS' -Unique
$jug03CSV = $csv | Where-Object {($_.TLA -like "JUG03*") -and ($_.'Network Port' -eq "eth1")} | Select-Object "TLA", 'IP ADDRESS' -Unique

#Filter accepted list into an array
If($IncludeACT01 -eq 1) {$act01CSV | ForEach-Object{$clients += "$($_.'TLA')"}}
If($IncludeACT02 -eq 1) {$act02CSV | ForEach-Object{$clients += "$($_.'TLA')"}}
If($IncludeCNJ01 -eq 1) {$cnj01CSV | ForEach-Object{$clients += "$($_.'TLA')"}}
If($IncludeCNJ02 -eq 1) {$cnj02CSV | ForEach-Object{$clients += "$($_.'TLA')"}}
If($IncludeCTL01 -eq 1) {$ctl01CSV | ForEach-Object{$clients += "$($_.'TLA')"}}
If($IncludeDMS01 -eq 1) {$dms01CSV | ForEach-Object{$clients += "$($_.'TLA')"}}
If($IncludeJUG01 -eq 1) {$jug01CSV | ForEach-Object{$clients += "$($_.'TLA')"}}
If($IncludeJUG02 -eq 1) {$jug02CSV | ForEach-Object{$clients += "$($_.'TLA')"}}
If($IncludeJUG03 -eq 1) {$jug03CSV | ForEach-Object{$clients += "$($_.'TLA')"}}

Write-Host "Finding these clients:"
Write-Host $clients

# Add header line to csv output
Add-Content -Value $header -Path $output

# Create Dump location
New-Item -ItemType Directory -Path "C:\Batch Scripts\temp"

# Iterate through each client
for ($i=0; $i -lt $clients.Length; $i++) {
    Write-Host "Gathering data from $($clients[$i])"
    $csvLine = @()
    if($($clients[$i]) -notlike "JUG*") {
        $xmlPath = "\\$($clients[$i])\7thSense Data\Additional Folders\Compere (Appdata)\preferences.pref"
        # Write-Host $xmlPath
        $xmlDoc = New-Object System.Xml.XmlDocument
        $xmlDoc.Load($xmlPath)
        # Iterate over each XML property and extract its value
        foreach ($property in $xmlProperties) {
            $targetNode = $xmlDoc.SelectSingleNode($property)
            try{$propertyValue = $targetNode.GetAttribute('value')} catch {$propertyValue = ""}

            # Add Property value to line array
            $csvLine += $propertyValue
        } 
        # Convert line array to individual array value and add to Lines array
        $csvValue = $($clients[$i]) + "," + $($csvLine -join ",")
        Add-Content -Value $csvValue -Path $output
    }
    if($($clients[$i]) -like "JUG*") {
        New-Item -ItemType Directory -Path "C:\Batch Scripts\temp\$($clients[$i])"
        $xmlPath = "C:\Batch Scripts\temp\$($clients[$i])\Preferences.pref"

        # Convert TLA to IP_ADDRESS
        if($($clients[$i]) -like "JUG01*"){$ipCSV = $jug01CSV | Where-Object { $_.TLA -eq $($clients[$i])} | Select-Object 'IP ADDRESS'}
        if($($clients[$i]) -like "JUG02*"){$ipCSV = $jug02CSV | Where-Object { $_.TLA -eq $($clients[$i])} | Select-Object 'IP ADDRESS'}
        if($($clients[$i]) -like "JUG03*"){$ipCSV = $jug03CSV | Where-Object { $_.TLA -eq $($clients[$i])} | Select-Object 'IP ADDRESS'}
        $ipCSV | ForEach-Object{$ip = "$($_.'IP ADDRESS')"}
        Write-Host $ipCSV
        Write-Host $ip

        Write-Host "$sshUser@$ip$copyFromPath"
        # Copy the preferences file local to the temp DUMP location
        .\pscp.exe -scp -l $sshUser -pw $sshPassword $sshUser@$ip$copyFromPath $xmlPath
        
        # Write-Host $xmlPath
        $xmlDoc = New-Object System.Xml.XmlDocument
        $xmlDoc.Load($xmlPath)
        # Iterate over each XML property and extract its value
        foreach ($property in $xmlProperties) {
            $targetNode = $xmlDoc.SelectSingleNode($property)
            try{$propertyValue = $targetNode.GetAttribute('value')} catch {$propertyValue = ""}

            # Add Property value to line array
            $csvLine += $propertyValue
        } 
        # Convert line array to individual array value and add to Lines array
        $csvValue = $($clients[$i]) + "," + $($csvLine -join ",")
        Add-Content -Value $csvValue -Path $output
    }
}

Remove-Item -Path "C:\Batch Scripts\temp" -Recurse
Set-Location $currentDirectory

# Read-Host "All done. Press Enter to terminate"