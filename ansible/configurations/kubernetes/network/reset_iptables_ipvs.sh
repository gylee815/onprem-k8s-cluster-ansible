#!/bin/bash

iptables --policy INPUT   ACCEPT
iptables --policy OUTPUT  ACCEPT
iptables --policy FORWARD ACCEPT

iptables -Z # zero counters
iptables -F # flush (delete) rules
iptables -X # delete all extra chains

iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X

ipvsadm -C
