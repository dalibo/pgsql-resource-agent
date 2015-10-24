pgsql-resource-agent
====================

pgsqlsr
-------

Simple Pacemaker OCF Agent for PostgreSQL servers in streaming replication.

This agent suppose PostgreSQL instances are already set up for replication:
one master and N standby. 

It has been designed to forbid more than **one** failover, so only one failover
could be automated. After a failover, an administrator actio is required to 
cleanup the situation.

To forbid more than one failover, the resource parameter "startable" is set to 
the hostname of the promoted standby. As soon as this parameter is created and 
set, the only instance able to start will be the one designated there.

After a failover, you will have to:
  * rebuild your standby(s) if needed (eg. rebuild the old master as a slave)
  * start PostgreSQL on standby(s)i
  * cleanup your Pacemaker ressources, eg.: ``crm resource cleanup pgsqld``, 
    ``crm resource cleanup pgsql-ip``
  * check that everything works fine
  * Allow a new automated failover: ``crm_resource --resource pgsqld --delete-parameter startable``

pgsqlms
--------

Pacemaker OCF multi-state resource agent for PostgreSQL in streaming replication.
This agent is able to track the status of PostgreSQL on each node (master or slave).

Here is a sample Pacemaker configuration for a two node cluster on CentOS 6.6:

```
pcs property set no-quorum-policy=ignore
pcs resource defaults migration-threshold=5
pcs resource defaults resource-stickiness=INFINITY

pcs cluster cib cluster1.xml

# Fencing
pcs -f cluster1.xml stonith create fence_virsh_ha1 fence_virsh action="off" \
  pcmk_host_list="ha1" port="ha1-centos6"                                   \
  ipaddr="10.10.10.1" login="root" identity_file="/root/.ssh/id_rsa"        \
  login_timeout=15
pcs -f cluster1.xml stonith create fence_virsh_ha2 fence_virsh action="off" \
  pcmk_host_list="ha2" port="ha2-centos6"                                   \
  ipaddr="10.10.10.1" login="root" identity_file="/root/.ssh/id_rsa"        \
  delay=15 login_timeout=15
pcs -f cluster1.xml constraint location fence_virsh_ha1 avoids ha1=INFINITY
pcs -f cluster1.xml constraint location fence_virsh_ha2 avoids ha2=INFINITY


# pgsqld
pcs -f cluster1.xml resource create pgsqld ocf:pgsql:pgsqlms bindir=/usr/pgsql-9.3/bin pgdata=/var/lib/pgsql/9.3/data \
         op monitor interval=9s role="Master" op monitor interval=10s role="Slave"

# pgsql-ha
pcs -f cluster1.xml resource master pgsql-ha pgsqld master-max=1 master-node-max=1 clone-max=2 clone-node-max=1 notify=true

# pgsql-master-ip
pcs -f cluster1.xml resource create pgsql-master-ip ocf:heartbeat:IPaddr2 \
        ip=10.10.10.55 cidr_netmask=24 op monitor interval=10s

pcs -f cluster1.xml constraint colocation add pgsql-master-ip with master pgsql-ha INFINITY 

pcs -f cluster1.xml constraint order promote pgsql-ha then start pgsql-master-ip symmetrical=false
pcs -f cluster1.xml constraint order demote pgsql-ha then stop pgsql-master-ip symmetrical=false

pcs -f cluster1.xml constraint location pgsqld prefers ha1=1

pcs cluster cib-push cluster1.xml

```


