#!/bin/sh

# This script config the DPU according to the DPU Deployment Guide.

mst start
sleep 3
x=$(mst status -v | grep '/dev' |head -n2 | tr -s ' ' | cut -d ' ' -f 2 | sed -n 2p )

sleep 2
echo "enable container service"
systemctl start kubelet
systemctl start containerd
systemctl enable kubelet
systemctl enable containerd

#systemctl enable container-auto.service
#systemctl enable docker.service
sleep 1
#systemctl enable containerd.service

#systemctl start containerd.service
sleep 1
#systemctl start container-auto.service
#systemctl start docker.service

sleep 4
#ovs-vsctl del-port ovsbr1 p0
#ovs-vsctl del-port ovsbr2 p1

ethtool --set-priv-flags p0 tx_port_ts on
ethtool --set-priv-flags p1 tx_port_ts on

systemctl restart networking
#ifconfig p0 172.20.0.11/16 up
echo "set p0 up"
ifconfig p0 $1 up
sleep 2
echo "set a default route for p0"
#ip route add default via $2 dev p0
ip route add $2 via 0.0.0.0 dev p0 metric 200
sleep 12

cd /root/
chmod +x 01_Install_DOCA_Firefly_Container.sh
chmod +x 02_Install_Docker_Pause.sh
chmod +x 03_create_container.sh
echo "set p0 up"
ifconfig p0 $1 up
echo
