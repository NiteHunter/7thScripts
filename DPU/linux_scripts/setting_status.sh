#!/bin/sh

# This script print the DPU status setting.

echo -------- Setting Status --------------
mst start
sleep 5
x=$(mst status -v | grep '/dev' |head -n2 | tr -s ' ' | cut -d ' ' -f 2 | sed -n 2p )

echo Real Time:
mlxconfig -d $x -e q | grep -i REAL

echo Loopback:
mlxconfig -d $x -e q | grep -i mpfs_mc

echo Tx Timestamp:
ethtool --show-priv-flags p0 | grep tx_port
ethtool --show-priv-flags p1 | grep tx_port

echo OVS:
ovs-vsctl show

echo device mode:
mlxconfig -d $x -e q | grep -i model

echo privilege:
mlxprivhost -d $x q 

#echo force_local_lb_disable:
#cat /sys/class/net/p0/settings/force_local_lb_disable

echo interface IP:
ifconfig p0

echo BFB version:
cat /etc/mlnx-release

echo FW version: 
mlxfwmanager --query

echo ---------  END ------------------
