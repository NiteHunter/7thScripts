#!/bin/sh
#!/bin/sh

# This script print the DPU status setting.

echo -------- Firefly Monitor --------------
echo -------- Version 1.0 -------------------


ContainerID=""




echo "Check if DOCA-Firefly is running"
sleep 1
crictl ps -a
ContainerID=$(crictl ps | grep doca-firefly | grep -o "^\w*\b")

echo "Firefly ContainerID= " $ContainerID
sleep 1

# Check of the ContainerID lenght is not zero (=> running)
if test -n "$ContainerID" # True if length is non-zero
then
        sudo watch -n 1 crictl logs --tail=18 $ContainerID
else
        echo "Error: DOCA-Firefly is not running or present!"
fi