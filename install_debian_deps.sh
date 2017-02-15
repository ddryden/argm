#!/bin/sh

if [ -z "$PGVERSION" ]; then
	PGVERSION=9.6
fi

curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -sc`-pgdg main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install -y postgresql-${PGVERSION} postgresql-server-dev-${PGVERSION} 
export PATH=/usr/lib/postgresql/${PGVERSION}/bin:$PATH
sudo su postgres -c "pg_createcluster ${PGVERSION} main --start"
sudo service postgres start
sudo su postgres -c "createuser --superuser --createdb --createrole `id -un`"

