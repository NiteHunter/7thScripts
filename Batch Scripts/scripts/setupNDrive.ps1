param([string]$string="Error") 

$serverName = [system.net.DNS]::GetHostName()
#$serverName = "ACT01-01" #Test Host
IF($string -eq "Error"){
    Set-Location "C:\Batch Scripts"
    $files = Get-ChildItem -Filter "IP_Schedule*.csv"
    $csv = Import-csv $files[0].FullName
} Else {
    $csv = Import-csv $string
}

$clients = @()
$virtualIPs = @()

$clientsCSV = $csv | Where-Object {(($_.TLA -like "ACT*") -or ($_.TLA -like "CTL*")) -and ($_.'Network Port' -eq "Storage_01")} | Select-Object "TLA" -Unique
$clientsCSV | ForEach-Object{$clients += "$($_.'TLA')"}
$virtualCSV = $csv | Where-Object {$_.TLA -eq "HSN00-01"} | Select-Object "IP Address" -Unique
$virtualCSV | ForEach-Object{$virtualIPs += "$($_.'IP Address')"}

# Loop through the array and check each element for the search value
for ($i=0; $i -lt $clients.Length; $i++) {
    if ($clients[$i] -eq $serverName) {
        # If the search value is found, return the index
        Write-Host "The index of '$serverName' is $i"
        $index = $i
        break
    }
}

Write-Host $clients
Write-Host $virtualIPs

$IPForNDrive = $virtualIPs[$index]
$username = "7th"
$password = "7th"
#$password = ConvertTo-SecureString "7th" -AsPlainText -Force
#$credential = New-Object System.Management.Automation.PSCredential ($username, $password)

$driveLetter = "N:"
# if (Get-PSDrive -Name $driveLetter -ErrorAction SilentlyContinue) {
#     # The mapped drive already exists, so remove it
#     Write-Host "Removing Stale Drive"
#     net use $driveLetter /delete
# }

net use $driveLetter /delete

Write-Host "Mapping Drive to $IPForNDrive"
#New-PSDrive -Name $driveLetter -PSProvider "FileSystem" -Root "\\$IPForNDrive\videos" -Persist -Credential $credential
net use $driveLetter \\$IPForNDrive\videos /persistent:yes /user:$username $password
