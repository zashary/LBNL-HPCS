#!/bin/bash
##Author: Zashary Maskus-Lavin
##Date 3/20/2019
##IPMI setup for Dell PowerEdge C6420 servers

NETWORK=10
CLUSTER_OCTET=41
NODE_START=71
NODE_END=71
CLUSTER_NAME='lr6'
USER_NAME='username'
PASSWORD='password'

for node in $(seq $NODE_START $NODE_END); do
     NODE_NUM=$(printf %04d $node)
       echo Setting up basic network configuration for n$NODE_NUM.$CLUSTER_NAME
       ssh n$NODE_NUM.$CLUSTER_NAME ipmitool lan set 1 ipsrc static
       
       ssh n$NODE_NUM.$CLUSTER_NAME ipmitool lan set 1 access on    

       ssh n$NODE_NUM.$CLUSTER_NAME ipmitool lan set 1 ipaddr $NETWORK.2.$CLUSTER_OCTET.$node
       
       ssh n$NODE_NUM.$CLUSTER_NAME ipmitool lan set 1 netmask 255.255.0.0
       
       ssh n$NODE_NUM.$CLUSTER_NAME ipmitool lan print|grep $NETWORK.2.$CLUSTER_OCTECT

       ssh n$NODE_NUM.$CLUSTER_NAME ipmitool delloem lan set shared with lom1

       ssh n$NODE_NUM.$CLUSTER_NAME ipmitool delloem lan get active

       echo Setting up IPMI user for n$NODE_NUM.$CLUSTER_NAME
       ssh n$NODE_NUM.$CLUSTER_NAME ipmitool user set name 2 $USER_NAME
       
       ssh n$NODE_NUM.$CLUSTER_NAME ipmitool user set password 2 $PASSWORD
       
       ssh n$NODE_NUM.$CLUSTER_NAME ipmitool user enable 2
       
       ssh n$NODE_NUM.$CLUSTER_NAME ipmitool user priv 2 4 1

       echo Setting up SOL for n$NODE_NUM.$CLUSTER_NAME 
       ssh n$NODE_NUM.$CLUSTER_NAME ipmitool sol set volatile-bit-rate 115.2 1

       ssh n$NODE_NUM.$CLUSTER_NAME ipmitool sol set non-volatile-bit-rate 115.2 1 
       
       ssh n$NODE_NUM.$CLUSTER_NAME ipmitool sol payload enable 1 2

       echo Resetting the BMC
       ssh n$NODE_NUM.$CLUSTER_NAME ipmitool mc reset cold
done
