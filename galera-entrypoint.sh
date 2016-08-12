#!/usr/bin/env bash

[ "$DEBUG" == 'true' ] && set -x

set -eo pipefail

COMMAND=${1:-'mysqld'}

echo '>> Creating Galera Config'
export MYSQL_INITDB_SKIP_TZINFO="yes"
export MYSQL_ALLOW_EMPTY_PASSWORD="yes"

cat <<- EOF > /etc/mysql/conf.d/galera-auto-generated.cnf
# Galera Cluster Auto Generated Config
[mysqld]
innodb_log_file_size=2048M
max_allowed_packet=1073741824

[server]
bind-address="0.0.0.0"
binlog_format="row"
default_storage_engine="InnoDB"
innodb_autoinc_lock_mode="2"
innodb_locks_unsafe_for_binlog="1"

[galera]
wsrep_on="on"
wsrep_provider="${WSREP_PROVIDER:-/usr/lib/libgalera_smm.so}"
wsrep_provider_options="${WSREP_PROVIDER_OPTIONS}"
wsrep_cluster_address="${WSREP_CLUSTER_ADDRESS}"
wsrep_cluster_name="${WSREP_CLUSTER_NAME:-my_wsrep_cluster}"
wsrep_sst_auth="${WSREP_SST_AUTH}"
wsrep_sst_method="${WSREP_SST_METHOD:-rsync}"
EOF

if [ -n "$WSREP_NODE_ADDRESS" ]; then
  echo wsrep_node_address="${WSREP_NODE_ADDRESS}" >> /etc/mysql/conf.d/galera-auto-generated.cnf
fi

if [ -n "${WSREP_SST_RECEIVE_ADDRESS}" ]; then
  echo wsrep_sst_receive_address="${WSREP_SST_RECEIVE_ADDRESS}" >> /etc/mysql/conf.d/galera-auto-generated.cnf
fi

exec /docker-entrypoint.sh "$@"
