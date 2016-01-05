#!/bin/sh -ex

export DRILL_VERSION=1.4.0
export PARCEL_VERSION=0.1
PACKAGE=apache-drill-${DRILL_VERSION}
TARBALL=${PACKAGE}.tar.gz
PARCEL_NAME=DRILL-${DRILL_VERSION}_${PARCEL_VERSION}
DOWNLOAD_URL=http://apache.cs.utah.edu/drill/drill-${DRILL_VERSION}/${TARBALL}
DISTROS="el6"
CLEAN="N"

if [ -d "${PARCEL_NAME}" ]
then
  rm -rf ${PARCEL_NAME}
fi

if [ ! -f "${TARBALL}" ]
then
  wget "${DOWNLOAD_URL}"
fi

tar xvzf ${TARBALL} 
mv ${PACKAGE} ${PARCEL_NAME}

mkdir -p ${PARCEL_NAME}/meta

cat meta/drill_env.sh | DOLLAR='$' envsubst > ${PARCEL_NAME}/meta/drill_env.sh
cat meta/parcel.json | DOLLAR='$' envsubst > ${PARCEL_NAME}/meta/parcel.json
cat meta/alternatives.json > ${PARCEL_NAME}/meta/alternatives.json

for DISTRO in ${DISTROS}
do
  tar cvzf ${PARCEL_NAME}-${DISTRO}.parcel ${PARCEL_NAME} --owner=root --group=root
done

if [ "${CLEAN}" = "Y" ]
then
  rm -rf ${PARCEL_NAME}
  rm -rf ${TARBALL}
fi

