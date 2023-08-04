@echo off
setlocal EnableExtensions EnableDelayedExpansion
setlocal ENABLEDELAYEDEXPANSION


echo.
echo Starting DPU Installation
echo This process will take up to 15 minutes. 
echo Please wait!
timeout /NOBREAK 2
echo.

::reading the Bus number
RshimCmd -EnumDevices > c:\DPU\MlxRshim_BUS_number.txt
set y=0
cd c:\DPU
for /f "delims=" %%b in (MlxRshim_BUS_number.txt) do (
echo %%b
set /a c+=1
set y[!c!]=%%b
)

for /f "tokens=3 delims== " %%b in ("%y[1]%") do (
  set MlxRshim_bus_num=%%b
)
echo %MlxRshim_bus_num%
echo.

IF "%MlxRshim_bus_num%" == "" ( 
	echo Bus number has not found.
	echo Closing the automation...
	timeout /NOBREAK 5
	pause
	exit /B
)

::reading from configuration_file
echo Reading from configuration_file
echo.

set "FileName=C:\DPU\configuration_file.txt"
if not exist "%FileName%" goto FileNotExist

set x=0
cd c:\DPU
for /f "delims=" %%a in (configuration_file.txt) do (
echo %%a
set /a d+=1
set x[!d!]=%%a
)

echo.

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
echo Installing needed packages..
echo y | pip3 install setuptools C:/DPU/Files/setuptools-67.6.1.tar.gz
echo y | pip3 install pexpect C:/DPU/Files/pexpect-4.8.0.tar.gz
echo y | pip3 install fexpect C:/DPU/Files/fexpect-0.2.post17.tar.gz
echo y | pip3 install wexpect C:/DPU/Files/wexpect-4.0.0.tar.gz
echo y | pip3 install spawn C:/DPU/Files/spawn-0.3.0.tar.gz
echo y | pip3 install wheel C:/DPU/Files/wheel-0.40.0.tar.gz
echo y | pip3 install crypto C:/DPU/Files/crypto-1.4.1.tar.gz
echo y | pip3 install popen C:/DPU/Files/popen-0.1.20.tar.gz
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

echo Check network connection to the DPU - Ping %BlueField-2_IP%
ping -n 8 %BlueField-2_IP% -w 10000 | findstr TTL && goto net_checker
echo.
echo Error: No connection to the DPU. make sure the correct IP is been used or try other method to connect (external/internal)
echo.
@echo off
echo Press Y to continue with the automation (force programe the image)
set input=""
set /p input=""
IF "%input%" == "Y" ( 
	goto skip_checker
)
echo Closing the automation...
timeout /NOBREAK 5
pause
exit /B
:net_checker
	echo The network connection is working - continue with the automation 
:skip_checker


echo.
cd C:\DPU\BFB\

for %%f in (*.bfb) do (
    if "%%~xf"==".bfb" set bfb_image=%%f
)
echo Using this BFB file:
REM remove the .bfb from the file name
set trimmed_bfb_image=%bfb_image:.bfb=%

echo %bfb_image%

if not exist "%bfb_image%" goto FileNotExist

echo.

::yes - install the bfb , no - will skip the bfb
set need_to_burn_bfb=yes
set current_bfb_image_name=empty 
:: Read the user request - force BFB burn or only if it was changed and required 
echo Checking if BFB installtion is required...
IF "%Force_BFB_image_update%" == "y" ( 
	echo Force BFB image program
	set need_to_burn_bfb=yes
 )

if "%Force_BFB_image_update%"=="n" ( 
	echo Read the installed BFB image 
	del/f c:\DPU\temp_bfb_version.txt
	echo y | plink -batch %BlueField-2_IP% -l %BlueField-2_Username% -pw %BlueField-2_Password% cat /etc/mlnx-release  > c:\DPU\temp_bfb_version.txt
	set/p current_bfb_image_name=< c:\DPU\temp_bfb_version.txt
	del/f c:\DPU\temp_bfb_version.txt	
	
)
REM timeout /NOBREAK 8
echo Installed BFB Version = %current_bfb_image_name%
REM install a new BFB only if it's different from the existing one and if forced
if  not "%current_bfb_image_name%"=="empty"  if  "%current_bfb_image_name%"=="%trimmed_bfb_image%" (
	echo No Need to program a new BFB [it's already installed]
	set need_to_burn_bfb=no
)


if "%need_to_burn_bfb%" == "yes" (
	echo Starting the BFB installation..
	echo This process will take several minutes with no progress indication [~10min]
	echo y | RshimCmd -PushImage c:\DPU\BFB\%bfb_image% -BusNum %MlxRshim_bus_num%
	echo.
	timeout /NOBREAK 5
	echo BFB Image Programming in progress [~10min]
	set counter=0

	:checkping
		ping -n 2 %BlueField-2_IP% -w 10000 | findstr TTL && goto ping_checker
		echo | set /p=.
		set /a counter=%counter%+1
		if "%counter%" == "350" (
			echo BFB installation Timeout!!! no Ping! 
			break
		) Else (
			goto checkping
		)

	:ping_checker
		echo The BFB installation is complete
		echo please wait..
		break
) Else (
	if "%need_to_burn_bfb%" == "no" (
		echo Skipping the BFB installation
	)
)


timeout /NOBREAK 15

echo.

::these commands are for approving the prompt to update the cache key, without those commands we wil stuck on the prompt.
echo You will get "Access Denied" message because the device Putty Cache key is being updated.
setx PLINK_PROTOCOL "ssh" /M
echo.
rem use the default password after BFB programming
echo y | plink -pw ubuntu  -ssh root@%BlueField-2_IP% mkdir /root/example2
echo y
echo y | plink -pw ubuntu  -ssh root@%BlueField-2_IP% rm -r -f /root/example2
echo y


::#changing password:
echo.
timeout /NOBREAK 4

cd c:\DPU

set "FileName=C:\DPU\linux_scripts\reset_password.py"
echo "%FileName%"
if not exist "%FileName%" goto FileNotExist

if "%need_to_burn_bfb%" == "yes" (
    echo Changing Password:
	python c:\DPU\linux_scripts\reset_password.py %BlueField-2_IP% %BlueField-2_Password% %BlueField-2_Root_Password%
	timeout /NOBREAK 22
) ELSE (
	echo Skipping password change
)
timeout /NOBREAK 5
echo.
echo.
echo.


::Updating the FW
echo Updating the FW Version
echo This process will take several minutes [~5min]
echo y | plink -pw %BlueField-2_Root_Password% root@%BlueField-2_IP% /opt/mellanox/mlnx-fw-updater/mlnx_fw_updater.pl --force-fw-update
echo.

echo Finishes the update process [~2min]
set counter=0
:loop
if "%counter%" == "25" (
	break
) Else (
set /a counter=%counter%+1
echo | set /p=.
timeout /NOBREAK 5 > nul
goto loop
)

echo.
echo Please perform a manual power cycle to the Host server for the FW Version change to take place.
echo Press any key to close this window.
pause
exit

:FileNotExist
	echo "ERROR: The file %FileName% does not exist."
	pause
	exit /B