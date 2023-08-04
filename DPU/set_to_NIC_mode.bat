@echo off
setlocal EnableExtensions EnableDelayedExpansion
setlocal ENABLEDELAYEDEXPANSION

echo.
echo set to NIC mode 
mlxconfig -y -d mt41686_pciconf0 s INTERNAL_CPU_MODEL=1
mlxconfig -y -d mt41686_pciconf0 s INTERNAL_CPU_PAGE_SUPPLIER=1
mlxconfig -y -d mt41686_pciconf0 s INTERNAL_CPU_ESWITCH_MANAGER=1
mlxconfig -y -d mt41686_pciconf0 s INTERNAL_CPU_IB_VPORT0=1
mlxconfig -y -d mt41686_pciconf0 s INTERNAL_CPU_OFFLOAD_ENGINE=1

timeout /NOBREAK 1

exit