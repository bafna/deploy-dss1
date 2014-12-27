#!/bin/bash -xe

#Must have userdata.txt and machines.txt in the folder 

# Provisions machines mentioned in machines.txt file. 
while read p; do
 echo "Provisioning $p"
 scp ./userdata.txt ubuntu@$p:
 ssh ubuntu@$p sudo ./userdata.txt > results.txt
done < machines.txt
