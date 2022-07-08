#!/bin/bash

# essential port for control-plane and worker node
for port in 6443 2379-2380 6783 6784 10248 10250-10252 10255 30000-32767 179 4789 80 443 4149 9099
do
        firewall-cmd --add-port=$port/tcp --permanent
done

# essential port for lge-cpl thinq
for port in 1883 8883 8083 8084
do
        firewall-cmd --add-port=$port/tcp --permanent
done

# udp port for calico(if use vxlan)
for port in 8472
do
        firewall-cmd --add-port=$port/udp --permanent
done

# add masquerade
firewall-cmd --add-masquerade --permanent

# allow all interanal traffic

for source in K8S_LOCAL_IP_RANGE 10.96.0.0/12 10.244.0.0/16
do
        firewall-cmd --zone=trusted --add-source=$source --permanent
done

firewall-cmd --reload
