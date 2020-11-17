# pg_bigm_support

## Set up

### Prerequisite
pg_bigm_support needs following RPM packages for RHEL 7.

- gcc
- rpm-build
- llvm5.0
- llvm-toolset-7

You can install them using yum, but beware some of them are on epel and centos-release-scl repositories.

```
# yum install gcc rpm-build

# yum install epel-release
# yum install llvm5.0

# yum install centos-release-scl
# yum install llvm-toolset-7
```
`generate_rpm.sh` assumes that the user can sudo the following commands.

- yum
- hostname

The following is an example of registering sudoers.

```
# visudo
postgres ALL=NOPASSWD: /bin/yum
postgres ALL=NOPASSWD: /bin/hostname
```

### Setup pg_bigm_support

First, clone pg_bigm_support.

```
$ git clone https://github.com/pgbigm/pg_bigm_support.git
$ cd pg_bigm_support
```

Download pg_bigm source tarball from [GitHub releases](https://github.com/pgbigm/pg_bigm/releases) and rename it.
Then put it in `rpmbuild/SOURCES`.

```
/* Note that need to rename tarball in pg_bigm case. */
$ tar zxvf pg_bigm-1.2-20200228.tar.gz
$ mv pg_bigm-1.2-20200228 pg_bigm-1.2.20200228
$ tar zcvf pg_bigm-1.2.20200228.tar.gz pg_bigm-1.2.20200228

/* Put source tarball */
$ mv pg_bigm-1.2.20200228.tar.gz rpmbuild/SOURCES/

/* Remove original tarball */
$ rm pg_bigm-1.2-20200228.tar.gz
```

Put following postgresql RPM files to `rpmtest/${WITHOUT_DOT_VERSION}` directory.
  - postgresqlXX
  - postgresqlXX-devel
  - postgresqlXX-libs
  - postgresqlXX-server
  - postgresqlXX-llvmjit(PostgreSQL 11~)

For example, `rpmtest/12` should be as follows.
```
$ ls -1 rpmtest/12/
postgresql12-12.2-2PGDG.rhel7.x86_64.rpm
postgresql12-devel-12.2-2PGDG.rhel7.x86_64.rpm
postgresql12-libs-12.2-2PGDG.rhel7.x86_64.rpm
postgresql12-llvmjit-12.2-2PGDG.rhel7.x86_64.rpm
postgresql12-server-12.2-2PGDG.rhel7.x86_64.rpm
```

After you install the RPM repository, you can download RPM files using `yum install -downloadonly`.

```
# yum install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
# for VER in 11 12; do
  yum install --downloadonly --downloaddir=rpmtest/${VER}/ \
  postgresql${VER} postgresql${VER}-server postgresql${VER}-devel \
  postgresql${VER}-libs postgresql${VER}-llvmjit; done
```

## Directory Configuration
After set up, directory configuration shoule be as follows.

```
./pg_bigm_support
 ├─ generate_rpm.sh
 ├─ pg_bigm.spec
 ├─ README.md
 ├─　rpmbuild
 │   ├─ BUILD
 │   ├─ BUILDROOT
 │   ├─ SOURCES
 │   │   └─ pg_bpg_bigm-1.2.20200228.tar.gz
 │   ├─ SPECS
 │   └─ SRPMS
 └─ rpmtest
    |-- 12
    |   |-- postgresql12-12.2-2PGDG.rhel7.x86_64.rpm
    |   |-- postgresql12-devel-12.2-2PGDG.rhel7.x86_64.rpm
    |   |-- postgresql12-libs-12.2-2PGDG.rhel7.x86_64.rpm
    |   |-- postgresql12-llvmjit-12.2-2PGDG.rhel7.x86_64.rpm
    |   `-- postgresql12-server-12.2-2PGDG.rhel7.x86_64.rpm
 └─ rpmtest
    |-- 11
    |   |-- postgresql11-11.7-1PGDG.rhel7.x86_64.rpm
    |   |-- postgresql11-devel-11.7-1PGDG.rhel7.x86_64.rpm
    |   |-- postgresql11-libs-11.7-1PGDG.rhel7.x86_64.rpm
    |   |-- postgresql11-llvmjit-11.7-1PGDG.rhel7.x86_64.rpm
    |   `-- postgresql11-server-11.7-1PGDG.rhel7.x86_64.rp

(snip)
```

## Script Configuration
Set environmental variables in `generate_rpm.sh` according to what kind of RPMs you want. 
You can change the PostgreSQL version using ${PG_VERSIONS}.

```
PG_VERSIONS="9.4 9.5 9.6 10 11 12 13"
```

## Usage
```
$ ./generate_rpm.sh -h <build hostname> -v <pg_bigm version> <specfile>
```

### Example
```
$ ./generate_rpm.sh -h centos7-x86-64-pgbigmbuild -v 1.2.20200228 pg_bigm.spec
$ ls rpmbuild/RPMS/x86_64/
pg_bigm-1.2.20200228-1.pg12.el7.centos.x86_64.rpm
pg_bigm-1.2.20200228-1.pg94.el7.centos.x86_64.rpm
pg_bigm-debuginfo-1.2.20200228-1.pg12.el7.centos.x86_64.rpm
pg_bigm-debuginfo-1.2.20200228-1.pg94.el7.centos.x86_64.rpm
pg_bigm-llvmjit-1.2.20200228-1.pg11.el7.centos.x86_64.rpm
pg_bigm-llvmjit-1.2.20200228-1.pg12.el7.centos.x86_64.rpm
```
