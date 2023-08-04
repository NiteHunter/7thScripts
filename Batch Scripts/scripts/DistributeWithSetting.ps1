param([string]$param="Error") 

$filePathSubset = "7thSense Data\7thSense (C)\web\data\app\"
$sourceFiles = "C:\Batch Scripts\notch"
$propertyName = "carve"

#Gather clients
If ($param -eq "Error") {  
    Set-Location "C:\Batch Scripts"
    $files = Get-ChildItem -Filter "IP_Schedule*.csv"
    $csv = Import-csv $files[0].FullName
} Else {
    $csv = Import-csv $param
}
$clients = @()
$roles = @()
Write-Host "Finding these servers:"
$clientsCSV = $csv | Where-Object {($_.TLA -like "ACT*") -and ($_.'Network Port' -eq "Onboard_01")} | Select-Object "TLA", "Role" -Unique
$clientsCSV | ForEach-Object{$clients += "$($_.'TLA')"}
$clientsCSV | ForEach-Object{$roles += "$($_.'Role')"}
Write-Host $clients
Write-Host $roles

# Create a script block to update the XML file
For ($i=0; $i -lt $clients.Length; $i++) {
    Remove-Item -Path "\\$($clients[$i])\$filePathSubset\notch" -Recurse
    $filePath = "\\$($clients[$i])\$filePathSubset"
    Write-Host "Copying to $filepath"
    Copy-Item -Path "$sourcefiles" -Destination "$filePath" -Force -Recurse
    $newValue = $($roles[$i])
    $jsonContent = Get-Content -Raw -Path "$filePath\notch\assets\notch.json" | ConvertFrom-Json
    $jsonContent.notch.$propertyName = $newValue
    Write-Host "New JSON property value: $newValue"
    $updatedJson = $jsonContent | ConvertTo-Json -Depth 10
    $updatedJson | Out-File -FilePath "$filePath\notch\assets\notch.json" -Force
}

Read-Host "All done. Press Enter to terminate"