#!/bin/sh
# Crude debian package creation with FPM

VERSION=`pg_config | grep VERSION | cut -d ' ' -f 4 | awk -F. '{print $1"."$2}'`
if [ $# == 1 ]; then
	VERSION=$1
fi

make
mkdir tmpinstall
/bin/mkdir -p "tmpinstall/usr/lib/postgresql/${VERSION}/lib"
/bin/mkdir -p "tmpinstall/usr/share/postgresql/${VERSION}/extension"
/usr/bin/install -c -m 755 argm.so "tmpinstall/usr/lib/postgresql/${VERSION}/lib/argm.so"
/usr/bin/install -c -m 644 argm.control "tmpinstall/usr/share/postgresql/${VERSION}/extension/"
/usr/bin/install -c -m 644 argm--1.0.2.sql argm--1.0--1.0.2.sql "tmpinstall/usr/share/postgresql/${VERSION}/extension/"
fpm -s dir -t deb -n postgresql-argm-${VERSION} --description "Argm postgresql extension for PostgreSQL ${VERSION}" -C tmpinstall -v ${VERSION}-${BUILD_NUMBER} -p postgresql-argm_VERSION_ARCH.deb -d "postgresql-${VERSION}" usr
