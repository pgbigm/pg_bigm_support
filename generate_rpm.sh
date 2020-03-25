#!/bin/bash

PROGNAME=$(basename ${0})
RPMBUILD="./rpmbuild"
RPMTEST="./rpmtest"
PG_VERSIONS="9.4 9.5 9.6 10 11 12"
CURRENT=`pwd`
LOGDIR="log/`date +"%Y%m%d_%H%M%S"`"


info ()
{
    echo "[INFO]: " $* | tee -a ${LOGFILE}
}

elog ()
{
  [ -z "$1" ] || echo "$PROGNAME: ERROR: $1" 1>&2
  exit 1
}

usage ()
{
  cat <<EOF
Usage:
  ${PROGNAME} [OPTIONS] specfile

Options:
  -h hostname    hostname which is recorded as 'Build Host' on rpm
  -v version     target pg_bigm version
EOF
}


mkdir -p ${LOGDIR} || elog "Failed to make directory ${LOGDIR}."

while [ $# -gt 0 ]; do
  case "$1" in
    "-?" | --help)
      usage
      exit 0 ;;
    -h)
      BUILD_HOST="$2"
      shift ;;
    -v)
      BIGM_VERSION="$2"
      shift ;;
    -*)
      elog "invalid option: $1"
      shift ;;
    *)
      if [ -z "$SPECFILE_TEMPLATE" ]; then
        SPECFILE_TEMPLATE="$1"
      else
        elog "too many arguments."
      fi
      ;;
  esac
  shift
done

[ ! -z "$BUILD_HOST" ] || elog "hostname for package information must be specified. Use -h hostname."
[ ! -z "$BIGM_VERSION" ] || elog "target pg_bigm version must be specified. Use -v version."
[ ! -z "$SPECFILE_TEMPLATE" ] || elog "spec file template must be specified."

# rpm contains information about the hostname of the builder,
# so we use temporal hostname.
ORIGINAL_HOSTNAME=`hostname`
sudo hostname ${BUILD_HOST}

for VERSION in `echo $PG_VERSIONS`
do
    # Some names of files don't use "." in major version (e.g. pg96),
    # so we define ${WITHOUT_DOT_VERSION}.
    # ${WITHOUT_DOT_VERSION} is meaningful only for version less than 9.6,
    # which contains "." in major version.
    # It makes no difference from ${version} when the version is greater
    # than 10.
    WITHOUT_DOT_VERSION=`echo ${VERSION} | tr -d '.'`
    PGHOME="/usr/pgsql-${VERSION}"
    PGBIN="${PGHOME}/bin"

    LOGFILE=${LOGDIR}/${VERSION}.log

    info "Building version ${VERSION}  ..."
    
   # Install postgresql
    info "Installing postgresql"
    sudo yum install -y ${RPMTEST}/${WITHOUT_DOT_VERSION}/* 2>&1 | tee -a ${LOGFILE}

    # Update spec file
    specfile="${RPMBUILD}/SPECS/pg_bigm${WITHOUT_DOT_VERSION}.spec"
    sed "s/PLACEHOLDER_original_version/${VERSION}/" ${SPECFILE_TEMPLATE} | \
    sed "s/PLACEHOLDER_without_dot_version/${WITHOUT_DOT_VERSION}/" | \
    sed "s@PLACEHOLDER__topdir@${CURRENT}/rpmbuild@" | \
    sed "s/PLACEHOLDER_bigm_version/${BIGM_VERSION}/" \
    > ${specfile}

    # Building pg_bigm rpm
    info "Building pg_bigm rpm"
    rpmbuild -ba ${specfile} 2>&1 | tee -a ${LOGFILE}

    # Installing pg_bigm rpm
    rpmfile=`ls ${RPMBUILD}/RPMS/x86_64/pg_bigm*pg${WITHOUT_DOT_VERSION}*`
    info "Installing pg_bigm rpm : ${rpmfile}"
    sudo yum -y install ${rpmfile} 2>&1 | tee -a ${LOGFILE}

    # Confirm installation
    info "Confirm installation of pg_bigm"
    info "rpm -qip ${rpmfile}"
    rpm -qip ${rpmfile} 2>&1 | tee -a ${LOGFILE}
    info "rpm -qRp ${rpmfile}"
    rpm -qRp ${rpmfile} 2>&1 | tee -a ${LOGFILE}

    # Must be pg_bigm--1.0--1.1.sql, pg_bigm--1.1--1.2.sql, pg_bigm--1.2.sql, pg_bigm.control
    info "ls -l ${PGHOME}/share/extension | grep pg_bigm"
    ls -l ${PGHOME}/share/extension | grep pg_bigm 2>&1 | tee -a ${LOGFILE}
    # Must be pg_bigm.so
    info "ls -l ${PGHOME}/lib | grep pg_bigm"
    ls -l ${PGHOME}/lib | grep pg_bigm 2>&1 | tee -a ${LOGFILE}

    # Testing pg_bigm
    info "Testing installation of pg_bigm."
    ${PGBIN}/initdb -D ${VERSION} -E UTF8 --no-locale 2>&1 | tee -a ${LOGFILE}
    ${PGBIN}/pg_ctl start -D ${VERSION} -w -l ${LOGFILE}
    cat << EOF | ${PGBIN}/psql -d postgres 2>&1 | tee -a ${LOGFILE}
create extension pg_bigm;
\dx+ pg_bigm
create table hoge (c text);
insert into hoge values ('pg_bigmは全文検索モジュール');
insert into hoge values ('pg_trgmは全文検索モジュール');
create index hoge_idx on hoge using gin (c gin_bigm_ops);
set enable_seqscan to off;
explain (costs off) select * from hoge where c like '%pg_bigm%';
EOF
    ${PGBIN}/pg_ctl stop -D ${VERSION} -w
    rm -rf ${VERSION}

    # Unistall postgresql
    info "Uninstalling postgresql"
    sudo yum -y remove postgresql${WITHOUT_DOT_VERSION}*

    # Done
    info "Done"
done

hostname=`sudo hostname ${ORIGINAL_HOSTNAME}`

# Complete!!
info "    Complete!!"
