# pgsql-resource-agent

High-Availibility for Postgres, based on Pacemaker and Corosync.

This project gather two distinct Pacemaker resource agents for PostgreSQL:

  * a stateless agent (do not know what is a master or slave resource) from the
    Pacemaker point of view, very limited, simple, allowing only one failover
    then wait for an administrator action
  * a multi-state agent, more complete, able to deal with master and slave role,
    using the advanced feature of Pacemaker for promotion, demotion, switchover,
    etc.

Before choosing between both of them, please read ``stateless/README.md`` for
more information about the stateless agent, and ``multistate/docs/README.md``
for the multi-state agent.

