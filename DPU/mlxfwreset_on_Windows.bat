@echo off
setlocal EnableExtensions EnableDelayedExpansion
setlocal ENABLEDELAYEDEXPANSION

echo.
echo Running mlxfwreset on Windows
timeout /NOBREAK 1
mlxfwreset r -d mt41686_pciconf0 -y
echo Rebooting, Please wait..

exit