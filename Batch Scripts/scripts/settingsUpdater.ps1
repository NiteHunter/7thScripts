param([string]$param="Error") 

$xpath = "/PreferencesSet/Preferences/ml-vault-folder-path"
$xValueName = "value"
$xValueSet = "N:\Vault"
$filePathSubset = "7thSense Data\Additional Folders\Compere (Appdata)\preferences.pref"

#Gather clients
If ($param -eq "Error") {  
    Set-Location "C:\Batch Scripts"
    $files = Get-ChildItem -Filter "IP_Schedule*.csv"
    $csv = Import-csv $files[0].FullName
} Else {
    $csv = Import-csv $param
}
$clients = @()
Write-Host "Finding these servers:"
$clientsCSV = $csv | Where-Object {($_.TLA -like "ACT*") -and ($_.'Network Port' -eq "Onboard_01")} | Select-Object "TLA" -Unique
$clientsCSV | ForEach-Object{$clients += "$($_.'TLA')"}
Write-Host $clients

# Create a script block to update the XML file
For ($i=0; $i -lt $clients.Length; $i++) {
    $filePath = "\\$($clients[$i])\$filePathSubset"
    Write-Host "Writing to $filepath"
    $xml = [xml](Get-Content -Path $filePath)
    $node = $xml.SelectSingleNode($xpath)
    $node.SetAttribute($xValueName, $xValueSet)
    $xml.Save($filePath)
}

Read-Host "All done. Press Enter to terminate"