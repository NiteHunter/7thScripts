@echo off
setlocal EnableExtensions EnableDelayedExpansion
setlocal ENABLEDELAYEDEXPANSION

echo.
echo Getting DPU Status
echo Please Wait..
echo.

::reading the Bus number
RshimCmd -EnumDevices > c:\DPU\MlxRshim_BUS_number.txt
set y=0
cd c:\DPU
for /f "delims=" %%b in (MlxRshim_BUS_number.txt) do (
set /a c+=1
set y[!c!]=%%b
)

for /f "tokens=3 delims== " %%b in ("%y[1]%") do (
  set MlxRshim_bus_num=%%b
)


::reading from configuration_file
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
echo %BlueField-2_tmfifo_net_IP%

for /f "tokens=2 delims=:" %%a in ("%x[2]%") do (
  set BlueField-2_Managment_IP=%%a
)
echo %BlueField-2_Managment_IP%

for /f "tokens=2 delims=:" %%a in ("%x[3]%") do (
  set BlueField-2_Managment_Gateway=%%a
)
echo %BlueField-2_Managment_Gateway%

for /f "tokens=2 delims=:" %%a in ("%x[4]%") do (
  set BlueField-2_PTP_IP_Interface_0=%%a
)
echo %BlueField-2_PTP_IP_Interface_0%

for /f "tokens=2 delims=:" %%a in ("%x[5]%") do (
  set BlueField-2_PTP_IP_Interface_0_Gateway=%%a
)
echo %BlueField-2_PTP_IP_Interface_0_Gateway%

for /f "tokens=2 delims=:" %%a in ("%x[6]%") do (
  set BlueField-2_Username=%%a
)
echo %BlueField-2_Username%

for /f "tokens=2 delims=:" %%a in ("%x[7]%") do (
  set BlueField-2_Password=%%a
)
echo %BlueField-2_Password%

for /f "tokens=2 delims=:" %%a in ("%x[8]%") do (
  set BlueField-2_Root_Password=%%a
)
echo %BlueField-2_Root_Password%

for /f "tokens=2 delims=:" %%a in ("%x[9]%") do (
  set Force_BFB_image_update=%%a
)
echo %Force_BFB_image_update%

for /f "tokens=2 delims=:" %%a in ("%x[10]%") do (
  set Connection_method=%%a
)
echo Connection Method:%Connection_method%

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

cd c:\Program Files\PuTTY



setx PLINK_PROTOCOL "ssh" /M
::these commands are for approving the prompt to update the cache key, without those commands we wil stuck on the prompt.
echo NOTE: "FATAL ERROR" and "Access Denied" messages are expected because the device cache key is being updated.

echo Please Wait..
echo.
rem echo y | plink -pw ubuntu root@%BlueField-2_IP% mkdir /root/example2
echo y | plink -pw %BlueField-2_Root_Password%  -ssh root@%BlueField-2_IP% mkdir /root/example2
echo y
rem echo y | plink -pw ubuntu root@%BlueField-2_IP% mkdir /root/example3
echo y | plink -pw %BlueField-2_Root_Password%  -ssh root@%BlueField-2_IP% rm -r -f /root/example2
echo y

set "FileName=C:\DPU\linux_scripts\setting_status.sh"
if not exist "%FileName%" goto FileNotExist

pscp.exe -pw %BlueField-2_Root_Password% -P 22 c:\DPU\linux_scripts\setting_status.sh root@%BlueField-2_IP%:/root

timeout /NOBREAK 3

echo y | plink %BlueField-2_IP% -l root -pw %BlueField-2_Root_Password% chmod 777 /root/setting_status.sh


cls
echo DPU Automation Version:%Automation_Version%
echo PCI Bus:%MlxRshim_bus_num%
echo.

IF "%MlxRshim_bus_num%" == "" ( 
	echo Bus number has not found.
)

echo y | plink %BlueField-2_IP% -l root -pw %BlueField-2_Root_Password% /root/setting_status.sh

echo.
echo Press any key to close the window
pause
exit

:FileNotExist
	echo ERROR: The file %FileName% does not exist.
	pause
	exit

