# pgsql-resource-agent

Advanced and powerful Pacemaker OCF Agent for PostgreSQL servers in streaming
replication.

Supports PostgreSQL 9.3 and more.

## Description

Pacemaker OCF multi-state resource agent for PostgreSQL in streaming
replication. This agent is able to track the status of PostgreSQL on each node
(master or slave). After installation, you will find it under the name
``pgsqlms``. For information about how to install this agent, see
``multistate/docs/INSTALL.md``.

For each node, this resource agent expose to Pacemaker what is the current
status of the PostgreSQL instance: master or slave. In case of failure on the
master, the slaves are able to elect the best of them (the closest one to the
old master) to promote it as the new master.

Because this agent is able to promote a slave as master or demote a master as a
slave, it allows you to move the master rôle to another node, aka. switchover.

## Configuration

This agent has been written to give to the administrator the maximum control
over their PostgreSQL configuration and architecture. Thus, you are 100%
responsible for the master/slave creations and their configuration. The agent
will NOT edit your setup. You just have to follow these pre-requisites:

  * slave __must__ be in hot_standby (accessible in read-only)
  * you __must__ provide a template file on each node which will be copied as
    the local ``recovery.conf`` when needed by the agent
  * the recovery template file must contain ``standby_mode = on``
  * the recovery template file must contain ``recovery_target_timeline = 'latest'``
  * in the ``primary_conninfo`` parameter of your ``recovery.conf`` template
    file you __must__ set ``application_name`` to the node name as seen in
    Pacemaker (usually, the hostname)

When setting up the resource in Pacemaker, here are the available parameters you
can set:

  * ``bindir``: location of the PostgreSQL binaries (default: ``/usr/bin``)
  * ``pgdata``: location of the PGDATA of your instance (default:
    ``/var/lib/pgsql/data``)
  * ``pghost``: the socket directory or IP address to use to connect to the
    local instance (default: ``/tmp``)
  * ``pgport``:  the port to connect to the local instance (default: ``5432``)
  * ``recovery_tpl``: the local template that will be copied as the
    ``PGDATA/recovery.conf`` file. This template file must exists on all node. Note
    that its ``primary_conninfo`` parameter must be different on each node as
    explained earlier (default: ``$PGDATA/recovery.conf.pcmk``).
  * ``system_user``: the system owner of your instance's processus (default:
    ``postgres``)

For a demonstration about how to setup a cluster, see
``multistate/docs/Quick_Start.md``.

