param([string]$param="Error") 


#Gather clients
If ($param -eq "Error") {  
    Set-Location "C:\Batch Scripts"
    $files = Get-ChildItem -Filter "IP_Schedule*.csv"
    $csv = Import-csv $files[0].FullName
} Else {
    $csv = Import-csv $param
}
$clients = @()
Write-Host "Finding these servers: $clients"
$clientsCSV = $csv | Where-Object {($_.TLA -like "ACT*") -and ($_.'Network Port' -eq "Onboard_01")} | Select-Object "TLA", "Role" -Unique
$clientsCSV | ForEach-Object{$clients += "$($_.'TLA')"}
$clientsCSV | ForEach-Object{$roles += "$($_.'Role')"}
Write-Host $clients
Write-Host $roles