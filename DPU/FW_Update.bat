@echo off
setlocal EnableExtensions EnableDelayedExpansion
setlocal ENABLEDELAYEDEXPANSION

echo.

::reading from configuration_file
echo Reading from configuration_file
echo.

set "FileName=C:\DPU\configuration_file.txt"
if not exist "%FileName%" goto FileNotExist

set x=0
cd c:\DPU
for /f "delims=" %%a in (configuration_file.txt) do (
set /a d+=1
set x[!d!]=%%a
)

for /f "tokens=2 delims=:" %%a in ("%x[1]%") do (
  set BlueField-2_tmfifo_net_IP=%%a
)

for /f "tokens=2 delims=:" %%a in ("%x[2]%") do (
  set BlueField-2_Managment_IP=%%a
)

for /f "tokens=2 delims=:" %%a in ("%x[3]%") do (
  set BlueField-2_Managment_Gateway=%%a
)

for /f "tokens=2 delims=:" %%a in ("%x[4]%") do (
  set BlueField-2_PTP_IP_Interface_0=%%a
)

for /f "tokens=2 delims=:" %%a in ("%x[5]%") do (
  set BlueField-2_PTP_IP_Interface_0_Gateway=%%a
)

for /f "tokens=2 delims=:" %%a in ("%x[6]%") do (
  set BlueField-2_Username=%%a
)

for /f "tokens=2 delims=:" %%a in ("%x[7]%") do (
  set BlueField-2_Password=%%a
)

for /f "tokens=2 delims=:" %%a in ("%x[8]%") do (
  set BlueField-2_Root_Password=%%a
)

for /f "tokens=2 delims=:" %%a in ("%x[9]%") do (
  set Force_BFB_image_update=%%a
)

for /f "tokens=2 delims=:" %%a in ("%x[10]%") do (
  set Connection_method=%%a
)

for /f "tokens=2 delims=:" %%a in ("%x[11]%") do (
  set Automation_Version=%%a
)
echo DPU Automation Version:%Automation_Version%

echo.

powershell -c "(get-netadapter| where {$_.InterfaceDescription -like 'Mellanox BlueField Management*'}).Name" > c:\DPU\Interface_name.txt
set a=0
cd c:\DPU
for /f "delims=" %%a in (Interface_name.txt) do (
set Interface_name=%%a
)

netsh interface ip set address name = "%Interface_name%" static 192.168.100.1 255.255.255.252

IF  "%Connection_method%" == "1" ( 
	echo "Connection Method:Internal_IP(tmfifo_net_IP)"
	set BlueField-2_IP=%BlueField-2_tmfifo_net_IP%
	echo Connection Method=1
)

IF  "%Connection_method%" == "2" ( 
	echo "Connection Method:External_IP(BlueField-2_Managment_IP)"
	set BlueField-2_IP=%BlueField-2_Managment_IP%
	echo Connection Method=2
)


echo.

::geting the current FW version
echo y | plink %BlueField-2_IP% -l root -pw %BlueField-2_Root_Password% mlxfwmanager -d /dev/mst/mt41686_pciconf0 --query > c:\DPU\fw_info.txt
timeout /NOBREAK 3

::reading from fw_info file
set "FileName=C:\DPU\fw_info.txt"
if not exist "%FileName%" goto FileNotExist

echo.
set s=0
cd c:\DPU
for /f "delims=" %%a in (fw_info.txt) do (
echo %%a
set /a d+=1
set s[!d!]=%%a
)

echo.
cd c:\Program Files\PuTTY

::these commands are for approving the prompt to update the cache key, without those commands we wil stuck on the prompt.
echo You will get "Access Denied" message because the device cache key is being updated.
echo.
echo y | plink -pw ubuntu root@%BlueField-2_IP% mkdir /root/example2
echo y
echo y | plink -pw ubuntu root@%BlueField-2_IP% mkdir /root/example3
echo y

echo.

::Updating the FW
echo Updating the FW Version
echo This process will take several minutes [~3min]
echo y | plink -pw %BlueField-2_Root_Password% root@%BlueField-2_IP% /opt/mellanox/mlnx-fw-updater/mlnx_fw_updater.pl --force-fw-update
REM for testing echo y | plink 10.237.0.167 -l root -pw 3tango@#$ /opt/mellanox/mlnx-fw-updater/mlnx_fw_updater.pl --force-fw-update
echo.

echo Finishes the update process [~2min]
set counter=0
:loop
if "%counter%" == "17" (
	break
) Else (
set /a counter+=1
echo | set /p=..
PING 127.0.0.1 -n 10> nul
goto loop
)

echo.
echo Please perform a manual power cycle to the Host server for the FW Version change to take place.
echo Press any key to close this window.
pause
exit

:FileNotExist
	echo ERROR: The file %FileName% does not exist.
	pause
	exit

::::The below is for the power cycle sulotion::::
REM echo Set Device to EMBEDDED_CPU
REM mlxconfig -y -d mt41686_pciconf0 s INTERNAL_CPU_MODEL=1
REM timeout /NOBREAK 5

REM mlxconfig -d mt41686_pciconf0 q | find "INTERNAL_CPU_PAGE_SUPPLIER" > c:\DPU\internal_cpu_page_supplier.txt
REM set a=0
REM cd c:\DPU\
REM for /f "delims=" %%a in (internal_cpu_page_supplier.txt) do (
REM set temp=%%a
REM )
REM for /f "tokens=1 delims= " %%a in ("%temp%") do (
  REM set internal_cpu_page_supplier=%%a
REM )

REM IF  NOT "%internal_cpu_page_supplier%" == "INTERNAL_CPU_PAGE_SUPPLIER" ( 
	REM echo.
	REM echo "Manual Power Cycle is necessary to load the new FW Version!"
	REM echo.
	REM timeout /NOBREAK 3
	REM start "" /wait cmd /c "echo Please perform a manual power cycle^!&echo(&pause"
	REM timeout /NOBREAK 3
	REM exit
REM )

REM echo.

REM taskkill /IM putty.exe /F
REM cls
REM echo.
REM echo Please close your CONSOLE app(Putty, Xshell, etc..) 
REM echo Press any key once your CONSOLE are closed.
REM echo.
REM pause
REM timeout /NOBREAK 3

REM echo set device to NIC mode
REM start cmd.exe /k set_to_NIC_mode.bat %this_dir% 
REM timeout /NOBREAK 2
REM echo Rebooting, Please wait..
REM start cmd.exe /k mlxfwreset_on_Windows.bat %this_dir% 
REM timeout /NOBREAK 103
REM echo set device to DPU mode
REM start cmd.exe /k set_to_DPU_mode.bat %this_dir% 
REM timeout /NOBREAK 2
REM echo Rebooting, Please wait..
REM start cmd.exe /k mlxfwreset_on_Windows.bat %this_dir% 
REM timeout /NOBREAK 103

REM echo.
REM echo FW Version has been updated!
REM echo Close this Window