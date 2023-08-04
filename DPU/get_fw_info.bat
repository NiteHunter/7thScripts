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
::mlxfwmanager -d mt41686_pciconf0 --query  > c:\DPU\fw_info.txt
::echo y | plink %BlueField-2_Managment_IP% -l %BlueField-2_Username% -pw %BlueField-2_Password% mlxfwmanager -d /dev/mst/mt41686_pciconf0 --query > c:\DPU\fw_info.txt
echo y | plink %BlueField-2_IP% -l root -pw %BlueField-2_Root_Password% mlxfwmanager -d /dev/mst/mt41686_pciconf0 --query > c:\DPU\fw_info.txt

::reading from fw_info file
echo.
set s=0
cd c:\DPU
for /f "delims=" %%a in (fw_info.txt) do (
echo %%a
set /a d+=1
set s[!d!]=%%a
)
echo.

echo Press any key to close this window.
pause
exit


:FileNotExist
	echo ERROR: The file %FileName% does not exist.
	pause
	exit
