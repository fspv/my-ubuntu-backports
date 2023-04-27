#!/bin/bash

set -uex

# Copy gnupg data into the right place
# NOTE: your local GPG keyring should be GPG2
cp -R /tmp/host_gnupg /root/.gnupg
chown -R root:root /root/.gnupg

apt-get install wget

backport_from_source () {
    NAME=$1
    VERSION_SHORT=$2
    VERSION=$3
    BUILD=$4
    DST_DIST=$5
    FILENAME_DEB=${NAME}_${VERSION}.debian.tar.xz
    URL_DEB="http://archive.ubuntu.com/ubuntu/pool/universe/${NAME::1}/${NAME}/${FILENAME_DEB}"

    mkdir /build/${NAME}/
    cd /build/${NAME}/

    wget ${URL_DEB}

    ls -lah

    tar Jxvf ${FILENAME_DEB}
    rm ${FILENAME_DEB}

    # Download orig file from github
    uscan --debug --verbose --extra-debug -dd

    # Unpack orig into the current directory
    tar Jxvf ../${NAME}*.orig.tar.xz --strip-components=1 -C .


    # Instal dependencies
    /usr/lib/pbuilder/pbuilder-satisfydepends

    # Create changelog
    export CHANGELOG=/build/${NAME}/debian/changelog
    export EDITOR=/bin/true

    debchange -v ${VERSION_SHORT}-${DST_DIST}${BUILD} \
              --package ${NAME} \
              -D ${DST_DIST} \
              "Version ${VERSION} from upstream"

    # Build
    debuild -i -us -uc -b

    # Sign
    debuild -S

    # Upload to ppa
    dput ${PPA} /build/${NAME}_$(dpkg-parsechangelog -S Version)_source.changes
}

backport () {
    backportpackage -s $2 -d $3 -u ${PPA} $1 || bash
}

backport_build () {
    backportpackage -b -s $2 -d $3 -u ${PPA} $1 || bash
}

backport sway lunar jammy
backport swayidle kinetic jammy
backport swaylock lunar jammy
backport waybar kinetic jammy
# backport_build neovim
# backport_from_source waybar 0.9.13 0.9.13-2 1 jammy || bash
