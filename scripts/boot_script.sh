#!/bin/bash

VM_IDS=(104 105 106)
VM_NAMES=("k3s-control" "k3s-worker-1" "k3s-worker-2")

echo "Booting the cluster"

# loop through the VMs
# for each of the vm ids assign the value at index i to ID and NAME
for i in "${!VM_IDS[@]}"; do       
    ID=${VM_IDS[$i]} 
    sleep 10
    NAME=${VM_NAMES[$i]}

	
# run qm start vmid to boot up the node
    echo "starting $NAME (VM $ID)"
    qm start $ID
# if ? the exit code of the last command is equal to 0 then the node booted successfully
    if [ $? -eq 0 ]; then
        echo " success $NAME started up"
    else
        echo "  error  $NAME failed to start"
    fi
done

echo "complete"
