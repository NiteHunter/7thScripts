param([string]$string="Error") 

Write-Host "This script can take a param of a Juggler hostname or screen role/position, and executes the update command by establishing an SSH session for each."
Write-Host "Acceptable input formats are: "
Write-Host "    JUGxx-xx        -this specifies the Juggler hostname to update."
Write-Host "    A#              -this specifies the Bank A position of the Juggler to update. For instance: `"A1`" would update JUG02-01"
Write-Host "    B#              -this specifies the Bank B position of the Juggler to update. For instance: `"B1`" would update JUG02-04"
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
# Juggler section process
switch ($string) {
    'All' {
        $IPCSV = $csv | Where-Object {($_.TLA -like "JUG*") -and ($_.'Network Port' -eq "eth1")} | Select-Object "IP ADDRESS" -Unique
        $IPCSV | ForEach-Object{$IPs += "$($_.'IP ADDRESS')"}
    }
    'AA' {
        $IPCSV = $csv | Where-Object {($_.TLA -like "JUG*") -and ($_.'Network Port' -eq "eth1") -and ($_.'Bank' -eq "A")} | Select-Object "IP ADDRESS" -Unique
        $IPCSV | ForEach-Object{$IPs += "$($_.'IP ADDRESS')"}
    }
    'BB' {
        $IPCSV = $csv | Where-Object {($_.TLA -like "JUG*") -and ($_.'Network Port' -eq "eth1") -and ($_.'Bank' -eq "B")} | Select-Object "IP ADDRESS" -Unique
        $IPCSV | ForEach-Object{$IPs += "$($_.'IP ADDRESS')"}
    }
    Default {
        if($string.Substring(0,1) -eq "J"){
            $IPCSV = $csv | Where-Object {($_.TLA -like $string) -and ($_.'Network Port' -eq "eth1")} | Select-Object "IP ADDRESS" -Unique
            $IPCSV | ForEach-Object{$IPs += "$($_.'IP ADDRESS')"}
        } else {
            $IPCSV = $csv | Where-Object {($_.TLA -like "JUG*") -and ($_.'Network Port' -eq "eth1") -and ($_.'Role' -eq $string)} | Select-Object "IP ADDRESS" -Unique
            $IPCSV | ForEach-Object{$IPs += "$($_.'IP ADDRESS')"}
        }
    }
}

# Setup
# Path to Plink.exe - update this if necessary!
$plinkPath = "C:\Batch Scripts\"
$copyToPath = ":/7thApps/compere/bin"
$sshPort = 22
$sshUser = "root"
$sshPassword = "7thJuggler"
# Command to execute
$remoteCommand1 = "compere stop"
$remoteCommand2 = "jugglersw stop"
$remoteCommand3 = "jugglercontroller stop"

Set-Location $plinkPath

Write-Host "Select compere-atom, JugglerSW, or jugglercontroller file"
Add-Type -AssemblyName System.Windows.Forms
$fileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{InitialDirectory = [Environment]::GetFolderPath('Desktop')}
$filePath = $fileDialog.ShowDialog()
if($fileDialog.FileName.Length -gt 0) {
    $sourceFile = $fileDialog.FileName
}
Write-Host "selected filepath: $sourceFile"

# Command
ForEach($i in $IPs){
    Write-Host "Sending command to $i"
    Invoke-Expression -Command ".\plink.exe -ssh -P $sshPort -l $sshUser -pw $sshPassword $i `"$remoteCommand1`""
    Invoke-Expression -Command ".\plink.exe -ssh -P $sshPort -l $sshUser -pw $sshPassword $i `"$remoteCommand2`""
    Invoke-Expression -Command ".\plink.exe -ssh -P $sshPort -l $sshUser -pw $sshPassword $i `"$remoteCommand3`""
    .\pscp.exe -scp -l $sshUser -pw $sshPassword $sourceFile $sshUser@$i$copyToPath
}

Write-Host "Use the rebootJuggler.ps1 script on the same Juggler selection parameters to return the Jugglers to online status"