#!/bin/sh
# Crude debian package creation with FPM

#Need fpm - and fpm needs (apt-get install ruby ruby-dev rubygems gcc make)
if ! hash fpm 2>/dev/null; then
	echo "Your missing fpm; attempting to install..."
	sudo apt-get install ruby ruby-dev rubygems gcc make
	sudo gem install --no-ri --no-rdoc fpm
	if ! hash fpm 2>/dev/null; then
		echo "Couldn't install fpm, ask an admin."
	fi
fi

VERSION=`pg_config | grep VERSION | cut -d ' ' -f 4 | awk -F. '{print $1"."$2}'`
if [ $# -eq 1 ]; then
	VERSION=$1
fi

if [ "$BUILD_NUMBERx" == "x" ]; then
	#%s is seconds since 1970-01-01 00:00:00 UTC
	BUILD_NUMBER=date +%s
fi 

make
mkdir tmpinstall
/bin/mkdir -p "tmpinstall/usr/lib/postgresql/${VERSION}/lib"
/bin/mkdir -p "tmpinstall/usr/share/postgresql/${VERSION}/extension"
/usr/bin/install -c -m 755 argm.so "tmpinstall/usr/lib/postgresql/${VERSION}/lib/argm.so"
/usr/bin/install -c -m 644 argm.control "tmpinstall/usr/share/postgresql/${VERSION}/extension/"
/usr/bin/install -c -m 644 argm--1.0.2.sql argm--1.0--1.0.2.sql "tmpinstall/usr/share/postgresql/${VERSION}/extension/"
fpm -s dir -t deb -n postgresql-argm-${VERSION} --description "Argm postgresql extension for PostgreSQL ${VERSION}" -C tmpinstall -v ${VERSION}-${BUILD_NUMBER} -p postgresql-argm_VERSION_ARCH.deb -d "postgresql-${VERSION}" usr
