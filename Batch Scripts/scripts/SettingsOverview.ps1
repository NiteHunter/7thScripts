param([string]$param="Error") 

IF($param -eq "Error"){  
    Set-Location "C:\Batch Scripts"
    $files = Get-ChildItem -Filter "IP_Schedule*.csv"
    $csv = Import-csv $files[0].FullName
} Else {
    $csv = Import-csv $param
}


$xmlProperties = @()

# Begin Switch Case "choices"
do {
    $choice = Read-Host "Enter 1 for ML-settings.xml, 2 for preferences.pref, 0 to exit"
} while ($choice -notin '0', '1', '2')
switch ($choice) {
    '0' {
        Write-Host "You selected 0, exiting."
        Start-Sleep -seconds 3
        Exit
    }
    '1' {
        $output = "C:\Batch Scripts\settingsOverview_ML-settings.csv"
        # Define the properties you want to extract
        $xmlProperties += "watchFolder" 
        $xmlProperties += "assetVault"
        $xmlProperties += "assetVaultTags"
        $xmlProperties += "machineId"
        $xmlProperties += "machineName"
        $xmlProperties += "machineAddress"
        $xmlProperties += "toggleAssetLocationDistribution"

        $header = "Hostname," + $($xmlProperties -join ",")
        Write-Host "Searching for these properties from the $output file:"
        Write-Host $header
    }
    '2' {
        $output = "C:\Batch Scripts\settingsOverview_preferences.csv"
        # Define the properties you want to extract
        $xmlProperties += "//PreferencesSet/Preferences/preferredTree[@value]"  
        $xmlProperties += "//PreferencesSet/Preferences/externalControlUDPRxPort[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/externalControlUDPTxPort[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/externalControlTCPPort[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/external-control-adapter-tcp-port[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/externalControlTCPTimeoutTimeSecs[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/NetworkBindingNIC[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/UDPdiscoveryPort[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/UDPremoteConfigPort[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/TCPconnectionPort[@value]"      
        $xmlProperties += "//PreferencesSet/Preferences/CommsMode[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/CurrentProjectName[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/CurrentProjectID[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/Comment[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/EnableDebug[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/EnableAudio[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/UseLocalRenderSettings[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/ml-watch-folder-path[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/ml-vault-folder-path[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/ml-ip-address[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/rivermax-ip-address[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/lock-to-vsync[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/actor-show-stats[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/use-rivermax-sync[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/rivermax-framerate[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/use-direct-addressing[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/enableVisualiseRenderer[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/enableWaitForPresent[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/enabled[@value]" 
        $xmlProperties += "//PreferencesSet/Preferences/framebufferFormat"

        $xmlProperties2 = $xmlProperties -replace "//PreferencesSet/Preferences/"
        $header = "Hostname," + $($xmlProperties2 -join ",")
        Write-Host "Searching for these properties from the $output file:"
        Write-Host $header
    }
    Default {
        Write-Host "Invalid choice! Try again"
        Read-Host "Press Enter to Terminate"
    }
}

# Backup existing CSV file
$backup = $output.Substring(0, $output.Length - 4) + "_archived_" + $(Get-Date -Format "yyyy-MM-dd_hhmm") + ".csv"
Rename-Item -Path $output -NewName $backup -Force

$clients = @()
$clientsCSV = $csv | Where-Object {(($_.TLA -like "ACT*") -or ($_.TLA -like "CTL*") -or ($_.TLA -like "CNJ*") -or ($_.TLA -like "DMS*")) -and ($_.'Network Port' -eq "Onboard_01")} | Select-Object "TLA" -Unique
$clientsCSV | ForEach-Object{$clients += "$($_.'TLA')"}
# $clients += "ACT01-01" #test servers
# $clients += "ACT01-02" #test servers
Write-Host "Finding these servers:"
Write-Host $clients

# Add header line to csv output
Add-Content -Value $header -Path $output

# Iterate through each client
for ($i=0; $i -lt $clients.Length; $i++) {
    Write-Host "Gathering data from $($clients[$i])"
    $csvLine = @()
    if($choice -eq "1") {
        $xmlPath = "\\$($clients[$i])\7thSense Data\7thSense (C)\Compere\ML-settings.xml"
        #Write-Host $xmlPath
        $xmlDoc = New-Object System.Xml.XmlDocument
        $xmlDoc.Load($xmlPath)
        # Iterate over each XML property and extract its value
        foreach ($property in $xmlProperties) {
            $targetNode = $xmlDoc.SelectSingleNode("MediaLogisticsSettings")
            try{$propertyValue = $targetNode.GetAttribute($property)} catch {$propertyValue = ""}
            #Write-Host $propertyValue

            # Add Property value to line array
            $csvLine += $propertyValue
            #Write-Host $csvLine
        }
        # convert line array to individual array value and add to Lines array
        $csvValue = $($clients[$i]) + "," + $($csvLine -join ",")
        Add-Content -Value $csvValue -Path $output  
    }
    if($choice -eq "2") {
        $xmlPath = "\\$($clients[$i])\7thSense Data\Additional Folders\Compere (Appdata)\preferences.pref"
        #Write-Host $xmlPath
        $xmlDoc = New-Object System.Xml.XmlDocument
        $xmlDoc.Load($xmlPath)
        # Iterate over each XML property and extract its value
        foreach ($property in $xmlProperties) {
            $targetNode = $xmlDoc.SelectSingleNode($property)
            try{$propertyValue = $targetNode.GetAttribute('value')} catch {$propertyValue = ""}
            #Write-Host $propertyValue

            # Add Property value to line array
            $csvLine += $propertyValue
            #Write-Host $csvLine
        } 
        # convert line array to individual array value and add to Lines array
        $csvValue = $($clients[$i]) + "," + $($csvLine -join ",")
        Add-Content -Value $csvValue -Path $output
    }
}

Read-Host "All done. Press Enter to terminate"