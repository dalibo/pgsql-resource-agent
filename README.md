pgsql-resource-agent
====================

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


