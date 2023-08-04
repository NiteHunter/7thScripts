#!/bin/sh

# This script config the DPU according to the DPU Deployment Guide.

mst start
sleep 1
mst status -v

systemctl stop chronyd
systemctl disable chronyd
timedatectl set-ntp 0
service ntpd stop
systemctl stop ntp

sleep 3
echo Disable the OVS Bridge
ovs-vsctl del-port ovsbr1 p0
ovs-vsctl del-port ovsbr2 p1

ovs-vsctl list-br | xargs -r -l ovsvsctl del-br
systemctl stop openvswitch-switch.service
systemctl disable openvswitch-switch.service

x=$(mst status -v | grep '/dev' |head -n2 | tr -s ' ' | cut -d ' ' -f 2 | sed -n 2p )
mlxconfig -y -d $x s INTERNAL_CPU_MODEL=0
 
sudo echo y | mlxconfig -d $x s REAL_TIME_CLOCK_ENABLE=1

echo "mlxconfig -d  03:00.0 set MPFS_MC_LOOPBACK_DISABLE_P1=1  MPFS_MC_LOOPBACK_DISABLE_P2=1"
mlxconfig -y -d  $x set MPFS_MC_LOOPBACK_DISABLE_P1=1
mlxconfig -y -d  $x set MPFS_MC_LOOPBACK_DISABLE_P2=1

sleep 3

echo 
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo Rebooting...
echo NOTE: a fatal error is expected on the connnection during reboot
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo

reboot
