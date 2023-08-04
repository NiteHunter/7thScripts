﻿if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

$adapters = @("Storage_01","Storage_02")
$netDriver = ""
$netDriver = Get-NetAdapter -Name $adapters[0] | Select DriverVersion
Write-Host $adapters
Write-Host "Current Driver version: $($netDriver.DriverVersion)"

If($netDriver.DriverVersion -ne "2.80.25134.0"){

    Write-Host "Installing driver 2.80.25134.0"
    Start-Process "C:\7thSense\Software & Drivers\Drivers\Network Adapter\Mellanox\ConnectX-6\MLNX_WinOF2-2_80_50000_All_x64.exe" -ArgumentList "/S /v/qn" -wait
    Write-Host "Installed driver 2.80.25134.0"

}

Foreach($adapter in $adapters){
    Write-Host "Setting $($adapter) properties..."
    Set-NetAdapterAdvancedProperty -Name $adapter -DisplayName "Jumbo Packet" -DisplayValue "9000"
    Set-NetAdapterAdvancedProperty -Name $adapter -DisplayName "NetworkDirect Technology" -DisplayValue "ROCEv2"
    Set-NetAdapterAdvancedProperty -Name $adapter -DisplayName "Maximum Number of RSS Queues" -DisplayValue "2"
    Set-NetAdapterAdvancedProperty -Name $adapter -DisplayName "Maximum Number of RSS Processors" -DisplayValue "8"
    Set-NetAdapterAdvancedProperty -Name $adapter -DisplayName "Receive Buffers" -DisplayValue "4096"
    Set-NetAdapterAdvancedProperty -Name $adapter -DisplayName "Send Buffers" -DisplayValue "4096"
    Mlx5Cmd.exe -QosConfig -SetupRoceQosConfig -Name $adapter -Configure 2
    Mlx5Cmd.exe -ZtRoce -Name $adapter -Enable
    Get-NetAdapterAdvancedProperty -Name $adapter
}

Read-Host "Press Enter to Terminate"