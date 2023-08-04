if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

$ips = @()
$gws = @()

Add-Type -AssemblyName System.Windows.Forms
$file_dialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{InitialDirectory = [Environment]::GetFolderPath('Desktop')}
$file_path = $file_dialog.ShowDialog()
$csv = Import-Csv -Path $file_dialog.FileName

ForEach($server in $csv){
    if($server.'TLA' -eq $env:COMPUTERNAME){
    #if($server.'TLA' -eq "ACT01-01"){
        if($server.'Network Port' -eq "Bluefield_01"){
            $ips += $server.'IP Address'
            $gws += $server.'GW Full'
        }
    }
}

ncpa.cpl
Write-Host "Check Bluefield Card Ethernet Mode before proceeding"
$ethModeChange=Read-Host "If Bluefield is in IPoIB Mode, enter 'y'"

if($ethModeChange -eq "y"){
    mlxconfig -d /dev/mst/mt41686_pciconf0 reset
    Start-sleep 3s
    mlxconfig -d /dev/mst/mt41686_pciconf0 set LINK_TYPE_P1=2 LINK_TYPE_P2=2

    Read-Host "Shutdown Host and pull power"
}
else{
    $lines ="BlueField-2_Internal_IP:192.168.100.2",
            "BlueField-2_External_IP:000.000.000.000",
            "BlueField-2_External_Gateway:000.000.000.000",
            "BlueField-2_PTP_IP_Interface_0:$($ips[1])/29",
            "BlueField-2_PTP_IP_Interface_0_Gateway:$($gws[1])",
            "BlueField-2_Username:ubuntu",
            "BlueField-2_Password:7thS3ns3",
            "BlueField-2_Root_Password:7thS3ns3",
            "Force_BFB_image_update(y/n):y",
            "Connection_Method(1-Internal_IP/2-External_IP):1",
            "Automation_Version:2.21_NHspecial",
            "",
            "",
            "",
            "*NOTES:",
            "+  All Fields are mandatory (the default can be used) - the IP settings are based on your network configuration",
            "+  Username and root password are important - modify it per your previously settings or keep the default",
            "+  For first time deployment or forgotten password - force_BFB_image = y",
            "+  For further details please review the deployment guide"

    Set-Content -Path "C:\DPU\configuration_file.txt" -Value $lines

    Start-Process "C:\DPU\automation.bat"
}

pause

