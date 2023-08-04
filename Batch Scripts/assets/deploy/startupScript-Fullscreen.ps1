# Revision: 1.02
# Added MediaLogisticsApp.exe to end of file
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}
$os=(Get-WmiObject Win32_OperatingSystem).caption
if($os -like "*Windows 7*"){
    Read-Host 'Windows 7 Detected - Please use original BATCH scripts…' | Out-Null
    Exit
}
# 
cls
Write-Host 'Setting Windows DPI to be 96 (100%)'
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name LogPixels -Value 96 -Force -Confirm:$false
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Win8DpiScaling -Value 1 -Force -Confirm:$false
Write-Host 'Ensuring C: Drive is labelled Windows'
Set-Volume -DriveLetter C -NewFileSystemLabel "Windows"
Write-Host 'Removing any old shortcuts'
if(Test-Path -Path $env:APPDATA'\Microsoft\Windows\Start Menu\Programs\Startup\DeltaMonitor.lnk'){Remove-Item $env:APPDATA'\Microsoft\Windows\Start Menu\Programs\Startup\DeltaMonitor.lnk' -Force}
if(Test-Path -Path $env:APPDATA'\Microsoft\Windows\Start Menu\Programs\Startup\DeltaServer.lnk'){Remove-Item $env:APPDATA'\Microsoft\Windows\Start Menu\Programs\Startup\DeltaServer.lnk'-Force}
if(Test-Path -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\DeltaMonitor.lnk"){Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\DeltaMonitor.lnk" -Force}
if(Test-Path -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\DeltaServer.lnk"){Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\DeltaServer.lnk" -Force}
if(Test-Path -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\HWInfo.lnk"){Remove-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\HWInfo.lnk" -Force}

$processes=Get-Process
Write-Host 'Stopping any Delta instances'
forEach($p in $processes){
    if($p.ProcessName -eq 'DeltaServer'){Stop-Process -Name $p.ProcessName -Force}
    elseif($p.ProcessName -eq 'DeltaMonitor'){Stop-Process -Name $p.ProcessName -Force}
    elseif($p.ProcessName -eq 'HWInfo'){Stop-Process -Name $p.ProcessName -Force}
}
Start-Sleep 3
if(Test-Connection www.google.co.uk -Count 1){
    Write-Host 'Resyncing the Clock with Current Time'
    Set-Service W32Time -StartupType Manual
    Start-Service W32time
    W32tm /resync /force
    Stop-Service W32time
    Set-Service W32Time -StartupType Disabled
}
$registry="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace"
$children=Get-ChildItem $registry
forEach($child in $children){
    forEach($path in "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace","HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace"){
        if($child.Name -eq "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"){Remove-ItemProperty -Path $path -Name "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"}
        if($child.Name -eq "{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}"){Remove-ItemProperty -Path $path -Name "{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}"}
        if($child.Name -eq "{d3162b92-9365-467a-956b-92703aca08af}"){Remove-ItemProperty -Path $path -Name "{d3162b92-9365-467a-956b-92703aca08af}"}
        if($child.Name -eq "{374DE290-123F-4565-9164-39C4925E467B}"){Remove-ItemProperty -Path $path -Name "{374DE290-123F-4565-9164-39C4925E467B}"}
        if($child.Name -eq "{088e3905-0323-4b02-9826-5d99428e115f}"){Remove-ItemProperty -Path $path -Name "{088e3905-0323-4b02-9826-5d99428e115f}"}
        if($child.Name -eq "{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"){Remove-ItemProperty -Path $path -Name "{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"}
        if($child.Name -eq "{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"){Remove-ItemProperty -Path $path -Name "{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"}
        if($child.Name -eq "{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"){Remove-ItemProperty -Path $path -Name "{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"}
        if($child.Name -eq "{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"){Remove-ItemProperty -Path $path -Name "{24ad3ad4-a569-4530-98e1-ab02f9417aa8}"}
        if($child.Name -eq "{A0953C92-50DC-43bf-BE83-3742FED03C9C}"){Remove-ItemProperty -Path $path -Name "{A0953C92-50DC-43bf-BE83-3742FED03C9C}"}
        if($child.Name -eq "{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"){Remove-ItemProperty -Path $path -Name "{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"}
    }
}
if(Get-WmiObject Win32_PNPSignedDriver | Where-Object {$_.Description -like "*NVIDIA*"}){
    $preset=Get-WmiObject -NameSpace 'root\CIMV2\NV' -Class 'ProfileManager'
    $preset.InvokeMethod('setCurrentProfile3D','Workstation App - Dynamic Streaming') |Out-Null
    $performance=Get-WmiObject -class 'Profile' -namespace 'root\cimv2\nv' | Where-Object { $_.type -eq 1 }
    Invoke-WmiMethod -Path $performance.__PATH -Name 'SetValueById' -ArgumentList '274197361','00000001' |Out-Null

}
$curDir=Get-Location
$motherboard=Get-WmiObject Win32_Baseboard
if(($motherboard.Product -eq "X99-E WS")-or($motherboard.Product -eq "Z170-WS")-or($motherboard.Product -eq "Z270-WS")){
    Import-Module -Name "C:\Program Files\Intel\IntelNetCmdlets\IntelNetCmdlets.psd1"
    $nics=Get-IntelNetAdapter
    forEach($nic in $nics){
        Write-Host 'Settting up'$nic.Name
        Set-IntelNetAdapterSetting -Name $nic.Name -DisplayName "Wake on Magic Packet from power off state" -RegistryValue 1 |out-Null
        Set-IntelNetAdapterSetting -Name $nic.Name -DisplayName "Wake on Magic Packet" -RegistryValue 1 |out-Null
        Set-IntelNetAdapterSetting -Name $nic.Name -DisplayName "Wake on Pattern Match" -RegistryValue 1 |out-Null
        Set-IntelNetAdapterSetting -Name $nic.Name -DisplayName "Reduce link speed during system idle" -RegistryValue 1 |out-Null
        Set-IntelNetAdapterSetting -Name $nic.Name -DisplayName "Wake on Link Settings" -RegistryValue 1 |out-Null
    }
}

Stop-Process "MediaLogisticsApp.exe" -Force
#if(Test-Path -Path "C:\Program Files\7thSense\Delta\Utilities\DeltaMonitor.exe"){Write-Host "Starting Delta Monitor";Start-Process -FilePath "C:\Program Files\7thSense\Delta\Utilities\DeltaMonitor.exe"}
#if(Test-Path -Path "C:\7thSense\HWInfo\HWInfo.exe"){CD "C:\7thSense\HWInfo";Write-Host "Starting HWInfo";Start-Process -FilePath "C:\7thSense\HWInfo\HWInfo.exe"}
if(Test-Path -Path "C:\7thSense\Watchdog\bin\WatchDog.exe"){Write-Host "Starting WatchDog";Start-Process -FilePath "C:\7thSense\Watchdog\bin\WatchDog.exe"}
#if(Test-Path -Path "C:\Program Files\NDI\NDI 5 Tools\Screen Capture\Application.Network.ScanConverter2.x64.exe"){Write-Host "Starting NDI Stream";Start-Process -FilePath "C:\Program Files\NDI\NDI 5 Tools\Screen Capture\Application.Network.ScanConverter2.x64.exe"}
if(Test-Path -Path "C:\7thSense\compere\Compere.exe"){Write-Host "Starting Actor";Start-Process -FilePath "C:\7thSense\compere\Compere.exe" -ArgumentList "codemeter actor actorgui --useiocp --chunksize=1024768 --loaderThreads=3"}
if(Test-Path -Path "C:\7thSense\compere\MediaLogisticsApp.exe"){Write-Host "Starting Media Logistics";Start-Process -FilePath "C:\7thSense\compere\MediaLogisticsApp.exe" -WorkingDirectory "C:\7thSense\compere"}
