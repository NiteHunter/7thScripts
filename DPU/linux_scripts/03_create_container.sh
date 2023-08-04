#!/bin/bash
#LOG_DIR_HOST=/var/log/
#PTP_DIR_HOST=/etc/ptp4l/
#IMAGE_NAME=nvcr.io/ea-rivermax/dpu-ptp-service/dpu-ptp-service:21.03-v1
#CONTAINER_NAME=ptp-service-container
#Create PTP Configuration File


Echo "Clean the journal"
journalctl --vacuum-time=1s

systemctl start kubelet
systemctl start containerd
systemctl enable kubelet
systemctl enable containerd

# Pull the entire resource as a *.zip file
#echo "Download all resources from NGC"
#wget --content-disposition https://api.ngc.nvidia.com/v2/resources/nvidia/doca/doca_container_configs/versions/1.5.0/zip -O doca_container_configs_1.5.0.zip
# Unzip the resource
unzip -o doca_container_configs_1.5.0.zip -d doca_container_configs_1.5.0 
#----- This is the place to change the yaml file or push a prepard one! ----- 

echo Remove previuos Firefly containers
rm /etc/kubelet.d/doca_firefly*.yaml
sleep 10

echo "Spawn The Firefly Container - using media yaml"

#Using the default yaml!  cp ~/doca_container_configs_1.5.0/configs/1.5.0/doca_firefly.yaml  /etc/kubelet.d
cp  ~/doca_firefly_media.yaml  /etc/kubelet.d

echo "View currently active pods"
crictl pods
echo -e
echo -e

echo "View available images"
crictl images    
echo -e
echo -e

echo "View currently active containers"
crictl ps -a
echo -e
echo -e

ptp_log_file=/var/log/doca/firefly/ptp4l.log
counter=24
echo "Waiting for PTP lock (up to 2min)"
while [ $counter -gt 0 ];
do	
	if [ ! -f "$ptp_log_file" ]; then
		sleep 5
		counter=$(( $counter -1))
		echo -n .
	else
		break
	fi
done

echo
if [ -f "$ptp_log_file" ]; then
	tail -f /var/log/doca/firefly/ptp4l.log | grep -E 'ptp|phc'
else
	echo "Warning! PTP didn't start yet - check paramaters and log"
fi



