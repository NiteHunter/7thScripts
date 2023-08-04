if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

function importHosts(){
    try{UpdateConsole -console $console -text "Browsing for Server List"}catch{}
    Add-Type -AssemblyName System.Windows.Forms
    $file_dialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{InitialDirectory = [Environment]::GetFolderPath('Desktop')}
    $file_path = $file_dialog.ShowDialog()
    if($file_dialog.FileName.Length -gt 0){return $(Import-Csv -Path $file_dialog.FileName)}else{return $false}
    # "" | Select-Object TLA | Export-Csv -Path ".\_server_list.csv" -NoTypeInformation;
}
$hosts = ""
$csv = $null
if(Test-Path ".\_server_list.csv"){
    $csv = Import-Csv -Path ".\_server_list.csv"
}else{
    $csv = importHosts
    $csv | Where-Object {$_.TLA -like "ACT*" -or $_.TLA -like "CNJ*" -or $_.TLA -like "CTL*" -or $_.TLA -like "DMS*"} | Select TLA, "MAC Address"  -Unique | Export-Csv ".\_server_list.csv" -NoTypeInformation
    $csv = Import-Csv -Path ".\_server_list.csv"
}
if($csv -ne $null){
    $csv | Where-Object {$_.TLA -like "ACT*" -or $_.TLA -like "CNJ*" -or $_.TLA -like "CTL*" -or $_.TLA -like "DMS*"} | Select TLA  -Unique | ForEach {$hosts += "$($_.TLA),"}
}
$hosts = $hosts.Trim()
$hosts = $hosts.TrimEnd(",")
Write-Host "$($hosts)"

Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
Enable-PSRemoting -Force
Set-Item WSMan:localhost\client\trustedhosts -value $hosts

Read-Host "Press Enter to Terminate..."