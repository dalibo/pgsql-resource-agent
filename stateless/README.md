# pgsql-resource-agent

Simple Pacemaker OCF Agent for PostgreSQL servers in streaming replication.

Supports PostgreSQL 9.0 and more.

## Description

This agent, called ``pgsqlsr``, suppose PostgreSQL instances are already set up
for replication: one master and N standby. 

It has been designed to forbid more than **one** failover, so only one failover
could be automated. After a failover, an administrator action is required to 
cleanup the situation.

Because this agent is stateless, Pacemaker does not monitor slaves and has no
clue about their situation. There is no logic whatsoever in case of
failover. Should a failover occurs, the agent is not able to hint Pacemaker
about the best standby to promote. The comportment is unpredictable.

That is why this resource agent is best used in two nodes clusters. With more
than 1 standby, the administrator is in charge to make sure the best standby
will be elected (using location constraints, synchronous replication,
cascading, ...).

To forbid more than one failover, the resource parameter ``startable`` is set to 
the hostname of the promoted standby. As soon as this parameter is created and 
set, the only instance able to start will be the one designated there.

After a failover, you will have to:

  * rebuild your standby(s) if needed (eg. rebuild the old master as a slave)
  * start PostgreSQL on standby(s)i
  * cleanup your Pacemaker ressources, eg.: ``crm resource cleanup pgsqld``, 
    ``crm resource cleanup pgsql-ip``
  * check that everything works fine
  * Allow a new automated failover: ``crm_resource --resource pgsqld --delete-parameter startable``

## Installation

Just copy the file ``pgsqlsr`` to your OCF_ROOT folder (usualy ``/usr/lib/ocf/resource.d/heartbeat/``). Make sure the file has the executable right and its owner is the same than the other scripts there.

## Configuration

This agent has been written to give to the administrator the maximum control
over their PostgreSQL configuration and architecture. Thus, you are 100%
responsible for the master/slave creations and their configuration. The agent
will NOT edit your setup. You just have to follow these pre-requisites:

  * you __must__ give the location of your master during your cluster setup 
  * the cluster resource manager is responsible to start and stop your
    PostgreSQL instances.

When setting up the resource in Pacemaker, here are the available parameters you
can set:

  * ``bindir``: location of the PostgreSQL binaries (default: ``/usr/bin``)
  * ``pgdata``: location of the PGDATA of your instance (default:
    ``/var/lib/pgsql/data``)
  * ``system_user``: the system owner of your instance's processus (default:
    postgres)
  * ``trigger_file``: the trigger file to use to promote the slave instance.
    This one is useful only for PostgreSQL 9.0, where ``pg_ctl promote`` does
    not exists.

## Cluster setup example

Here is a cluster setup example, based on CentOS 5.x, using the ``crm`` command:

```
crm <<EOF
configure erase
configure
  # Step 1
  rsc_defaults resource-stickiness="INFINITY"
  rsc_defaults migration-threshold=5

  # Step 2
  property stonith-enabled="true"
  property no-quorum-policy="ignore"

  # Step 3
  primitive pgsql-ip ocf:heartbeat:IPaddr2    \
    params ip="172.16.4.80" cidr_netmask="24" \
    op monitor interval="20s"

  # Step 4
  primitive pgsqld ocf:heartbeat:pgsqlsr                                \
    params bindir="/usr/pgsql-9.0/bin" pgdata="/var/lib/pgsql/9.0/data" \
    trigger_file="/var/lib/pgsql/9.0/data/promote"                      \
    op start timeout="120"                                              \
    op stop timeout="120"                                               \
    op monitor interval="5s"
  location prefer-pgsqld-on-srv1 pgsqld 10: srv1

  # Step 5
  colocation pgsqld_with_pgsql-ip inf: pgsql-ip pgsqld
  order ip-after-pgsqld inf: pgsqld pgsql-ip

  # Step 6
  primitive stonith_meatware stonith:meatware params hostlist="srv1 srv2"
  clone fencing stonith_meatware

  # Step 7
  commit
  show
bye
EOF
```


