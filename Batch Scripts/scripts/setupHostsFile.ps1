if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

$serverName = [system.net.DNS]::GetHostName()
IF($param -eq "Error"){  
    Set-Location "C:\Batch Scripts"
    $files = Get-ChildItem -Filter "IP_Schedule*.csv"
    $csv = Import-csv $files[0].FullName
} Else {
    $csv = Import-csv $param
}

$clients = @()
$virtualIPs = @()

$clientsCSV = $csv | Where-Object {(($_.TLA -like "ACT*") -or ($_.TLA -like "CTL*") -or ($_.TLA -like "DMS*")) -and ($_.'Network Port' -eq "Storage_01")} | Select-Object "TLA" -Unique
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

#Write-Host $clients
#Write-Host $virtualIPs

$IPForNDrive = $virtualIPs[$index]
$hostFile = "C:\Windows\System32\drivers\etc\hosts"

# Backup existing host file
Write-Host "Backing up host file and replacing with template"
$backup = $hostFile.Substring(0, $hostFile.Length - 4) + "_archived_" + $(Get-Date -Format "yyyy-MM-dd_hhmm") + ".txt"
Rename-Item -Path $output -NewName $backup -Force
Copy-Item -Path "C:\Batch Scripts\hoststemplate.txt" -Destination $hostFile -Force
Write-Host "Setting nas share to : $IPForNDrive"
Add-Content -Path $hostFile -Value "$IPForNDrive hsn00-01-transfer nas" -Force

#Read-Host "Press enter to terminate"

