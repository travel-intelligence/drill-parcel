#!/bin/sh -x

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

# build parcel repo
RC=$(which make_manifest.py)
if [ "${RC}" -ne "0" ]
then
  echo "Make sure make_manifest.py (cf cm_ext) is in your PATH"
  exit 1
fi

rm -rf parcel-repo
mkdir -p parcel-repo

for DISTRO in ${DISTROS}
do
  cp ${PARCEL_NAME}-${DISTRO}.parcel parcel-repo
done

cd parcel-repo
make_manifest.py

cd -
tar cvzf parcel-repo.tar.gz parcel-repo

if [ "${CLEAN}" = "Y" ]
then
  rm -rf ${PARCEL_NAME}
  rm -rf ${TARBALL}
  rm -rf parcel-repo
fi

