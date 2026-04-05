#!/bin/bash

ALL_VMS=$(/usr/sbin/qm list | grep -v VMID | awk '{print $1}')

for vm in $ALL_VMS; do
  if /usr/sbin/qm config $vm | grep -iqE "not_always_on|ondemand"; then
    if /usr/sbin/qm status $vm | grep -q "running"; then
      echo "VM $vm (has not_always_on or ondemand tag) is running. Shutting down now..."
      /usr/sbin/qm shutdown $vm
    elif /usr/sbin/qm status $vm | grep -q "stopped"; then
      echo "VM $vm (has not_always_on or ondemand tag) is stopped. Starting now..."
      /usr/sbin/qm start $vm
    fi
  fi
done
