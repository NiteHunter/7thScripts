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
echo BlueField-2_Managment_Internal_IP: %BlueField-2_tmfifo_net_IP%

for /f "tokens=2 delims=:" %%a in ("%x[2]%") do (
  set BlueField-2_Managment_IP=%%a
)
echo BlueField-2_Managment_External_IP:%BlueField-2_Managment_IP%

for /f "tokens=2 delims=:" %%a in ("%x[3]%") do (
  set BlueField-2_Managment_Gateway=%%a
)
echo BlueField-2_Managment_External_Gateway:%BlueField-2_Managment_Gateway%

for /f "tokens=2 delims=:" %%a in ("%x[4]%") do (
  set BlueField-2_PTP_IP_Interface_0=%%a
)
echo BlueField-2_PTP_IP_Interface: %BlueField-2_PTP_IP_Interface_0%

for /f "tokens=2 delims=:" %%a in ("%x[5]%") do (
  set BlueField-2_PTP_IP_Interface_0_Gateway=%%a
)
echo BlueField-2_PTP_IP_Interface_Gateway:%BlueField-2_PTP_IP_Interface_0_Gateway%

for /f "tokens=2 delims=:" %%a in ("%x[6]%") do (
  set BlueField-2_Username=%%a
)
echo BlueField-2_Username:%BlueField-2_Username%

for /f "tokens=2 delims=:" %%a in ("%x[7]%") do (
  set BlueField-2_Password=%%a
)
echo BlueField-2_Password:%BlueField-2_Password%

for /f "tokens=2 delims=:" %%a in ("%x[8]%") do (
  set BlueField-2_Root_Password=%%a
)
echo BlueField-2_Root_Password:%BlueField-2_Root_Password%

for /f "tokens=2 delims=:" %%a in ("%x[9]%") do (
  set Force_BFB_image_update=%%a
)
echo Force_BFB_image_update:%Force_BFB_image_update%

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

IF  "%Connection_method%" == "1" ( 
	echo setting static IP to internal Interface: %Interface_name% IP 192.168.100.1
	netsh interface ip set address name = "%Interface_name%" static 192.168.100.1 255.255.255.252


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

echo Check network connection to the DPU - Ping %BlueField-2_IP%
ping -n 8 %BlueField-2_IP% -w 10000 | findstr TTL && goto net_checker
echo.
echo Error: No connection to the DPU. make sure the correct IP is been used or try other method to connect (external/internal)
echo Closing the automation...
timeout /NOBREAK 5
pause
exit /B

:net_checker
	echo The network connection is working - continue with the automation 


setx PLINK_PROTOCOL "ssh" /M
::these commands are for approving the prompt to update the cache key, without those commands we wil stuck on the prompt.
echo NOTE: "FATAL ERROR" and "Access Denied" messages are expected because the device cache key is being updated.


echo.
rem echo y | plink -pw ubuntu root@%BlueField-2_IP% mkdir /root/example2
echo y | plink -pw %BlueField-2_Root_Password%  -ssh root@%BlueField-2_IP% mkdir /root/example2
echo y
rem echo y | plink -pw ubuntu root@%BlueField-2_IP% mkdir /root/example3
echo y | plink -pw %BlueField-2_Root_Password%  -ssh root@%BlueField-2_IP% rm -r -f /root/example2
echo y

echo.
::Copying files to the BlueField-2
echo Copying files to the BlueField-2

set "FileName=C:\DPU\linux_scripts\01_Install_DOCA_Firefly_Container.sh"
if not exist "%FileName%" goto FileNotExist
pscp.exe -pw %BlueField-2_Root_Password% -P 22 c:\DPU\linux_scripts\01_Install_DOCA_Firefly_Container.sh root@%BlueField-2_IP%:/root
timeout /NOBREAK 2

set "FileName=C:\DPU\linux_scripts\02_Install_Docker_Pause.sh"
if not exist "%FileName%" goto FileNotExist
pscp.exe -pw %BlueField-2_Root_Password% -P 22 c:\DPU\linux_scripts\02_Install_Docker_Pause.sh root@%BlueField-2_IP%:/root
timeout /NOBREAK 2

set "FileName=C:\DPU\linux_scripts\03_create_container.sh"
if not exist "%FileName%" goto FileNotExist
pscp.exe -pw %BlueField-2_Root_Password% -P 22 c:\DPU\linux_scripts\03_create_container.sh root@%BlueField-2_IP%:/root
timeout /NOBREAK 2

set "FileName=C:\DPU\Files\doca_container_configs_1.5.0.zip"
if not exist "%FileName%" goto FileNotExist
pscp.exe -pw %BlueField-2_Root_Password% -P 22 c:\DPU\Files\doca_container_configs_1.5.0.zip root@%BlueField-2_IP%:/root
timeout /NOBREAK 2

set "FileName=C:\DPU\Files\doca_firefly_container.tar"
if not exist "%FileName%" goto FileNotExist
pscp.exe -pw %BlueField-2_Root_Password% -P 22 c:\DPU\Files\doca_firefly_container.tar root@%BlueField-2_IP%:/root
timeout /NOBREAK 2

set "FileName=C:\DPU\Files\docker_pause_3_2.tar"
if not exist "%FileName%" goto FileNotExist
pscp.exe -pw %BlueField-2_Root_Password% -P 22 c:\DPU\Files\docker_pause_3_2.tar root@%BlueField-2_IP%:/root
timeout /NOBREAK 2

set "FileName=C:\DPU\linux_scripts\set_real_time_clock.sh"
if not exist "%FileName%" goto FileNotExist
pscp.exe -pw %BlueField-2_Root_Password% -P 22 c:\DPU\linux_scripts\set_real_time_clock.sh root@%BlueField-2_IP%:/root
timeout /NOBREAK 2

set "FileName=C:\DPU\linux_scripts\set_ip_and_container.sh"
if not exist "%FileName%" goto FileNotExist
pscp.exe -pw %BlueField-2_Root_Password% -P 22 c:\DPU\linux_scripts\set_ip_and_container.sh root@%BlueField-2_IP%:/root
timeout /NOBREAK 2

set "FileName=C:\DPU\linux_scripts\set_persistent_ip_to_p0.sh"
if not exist "%FileName%" goto FileNotExist
pscp.exe -pw %BlueField-2_Root_Password% -P 22 c:\DPU\linux_scripts\set_persistent_ip_to_p0.sh root@%BlueField-2_IP%:/root
timeout /NOBREAK 2

set "FileName=C:\DPU\linux_scripts\config_after_reboot.sh"
if not exist "%FileName%" goto FileNotExist
pscp.exe -pw %BlueField-2_Root_Password% -P 22 C:\DPU\linux_scripts\config_after_reboot.sh root@%BlueField-2_IP%:/etc/init.d/
timeout /NOBREAK 2

set "FileName=C:\DPU\linux_scripts\rc.local"
if not exist "%FileName%" goto FileNotExist
pscp.exe -pw %BlueField-2_Root_Password% -P 22 C:\DPU\linux_scripts\rc.local root@%BlueField-2_IP%:/etc/
timeout /NOBREAK 2

set "FileName=C:\DPU\linux_scripts\firefly_monitor.sh"
if not exist "%FileName%" goto FileNotExist
pscp.exe -pw %BlueField-2_Root_Password% -P 22 C:\DPU\linux_scripts\firefly_monitor.sh root@%BlueField-2_IP%:/root
timeout /NOBREAK 2


set "FileName=C:\DPU\Files\doca_firefly_media.yaml"
if not exist "%FileName%" goto FileNotExist
pscp.exe -pw %BlueField-2_Root_Password% -P 22 C:\DPU\Files\doca_firefly_media.yaml root@%BlueField-2_IP%:/root
timeout /NOBREAK 2

echo.
::Setting the IP Gateway to the BlueField-2 Management
echo Setting the IP Gateway to the BlueField-2 Management
echo y | plink -pw %BlueField-2_Root_Password% -ssh root@%BlueField-2_IP% ip route add %BlueField-2_Managment_Gateway% dev oob_net0
timeout /NOBREAK 24

set "FileName=C:\DPU\linux_scripts\remote_commands.txt"
if not exist "%FileName%" goto FileNotExist
echo y | plink %BlueField-2_IP% -l root -pw %BlueField-2_Root_Password% -m C:\DPU\linux_scripts\remote_commands.txt
echo y

echo.
echo Reboting the BlueField-2
timeout /NOBREAK 15

echo.
echo Waiting for BlueField-2 to be complete the reboot [~2min]
echo please wait..
rem timeout /NOBREAK 145
rem echo.
set counter=0
:loop
if "%counter%" == "30" (
	break
) Else (
set /a counter=%counter%+1
echo | set /p=.
timeout /NOBREAK 5 > nul
goto loop
)

:checkping
	ping -n 2 %BlueField-2_IP% -w 10000 | findstr TTL && goto ping_checker
	echo | set /p=.
	goto checkping

:ping_checker
	timeout /NOBREAK 5 > nul
	break

echo.
echo Setting IP to the BlueField-2 PTP IP Interface
echo.
echo y | plink %BlueField-2_IP% -l root -pw %BlueField-2_Root_Password% /root/set_ip_and_container.sh %BlueField-2_PTP_IP_Interface_0% %BlueField-2_PTP_IP_Interface_0_Gateway%
timeout /NOBREAK 5

echo.
echo Setting persistent IP to the BlueField-2 PTP Interface
echo y | plink %BlueField-2_IP% -l root -pw %BlueField-2_Root_Password% /root/set_persistent_ip_to_p0.sh %BlueField-2_PTP_IP_Interface_0% %BlueField-2_PTP_IP_Interface_0_Gateway%
timeout /NOBREAK 5

echo.
echo Fixing the DNS
set "FileName=C:\DPU\linux_scripts\remote_commands_dns_fix.txt"
if not exist "%FileName%" goto FileNotExist

echo y | plink %BlueField-2_IP% -l root -pw %BlueField-2_Root_Password% -m C:\DPU\linux_scripts\remote_commands_dns_fix.txt
echo y

echo.
echo Read DPU Configuration
echo.
cd C:\DPU\
start cmd.exe /k Read_DPU_Configuration.bat %this_dir% 

echo Open PuTTY window
cd c:\Program Files\PuTTY

timeout /NOBREAK 8
start /b putty -ssh root@%BlueField-2_IP% 22 -pw %BlueField-2_Root_Password%

 
echo.
echo Automation completed.
pause
exit /B


:FileNotExist
	echo ERROR: The file %FileName% does not exist.
	pause
	exit /B
