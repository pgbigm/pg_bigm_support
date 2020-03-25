# pg_bigm_support

## Set up

Download pg_bigm_support repository.
```
$ git clone git@github.com:pgbigm/pg_bigm_support.git
$ cd pg_bigm_support
```
Put source tarball at rpmbuild/SOURCES.
```
/* Note that need to rename tarball in pg_bigm case. */
$ tar zxvf pg_bigm-pg_bigm-1.2-20200228.tar.gz
$ mv pg_bigm-pg_bigm-1.2-20200228 pg_bigm-1.2.20200228
$ tar zcf pg_bigm-1.2.20200228.tar.gz pg_bigm-1.2.20200228
/* Put source tarball */ 
$ mv pg_bigm-1.2.20200228.tar.gz rpmbuild/SOURCES/
```
Put following postgresql RPM files to `rpmtest/${WITHOUT_DOT_VERSION}` directory.
  - postgresqlXX
  - postgresqlXX-devel
  - postgresqlXX-libs
  - postgresqlXX-server
  - postgresqlXX-llvmjit(PostgreSQL 11~)

For example,
```
$ ls -1 rpmtest/12/
postgresql12-12.2-2PGDG.rhel7.x86_64.rpm
postgresql12-devel-12.2-2PGDG.rhel7.x86_64.rpm
postgresql12-libs-12.2-2PGDG.rhel7.x86_64.rpm
postgresql12-llvmjit-12.2-2PGDG.rhel7.x86_64.rpm
postgresql12-server-12.2-2PGDG.rhel7.x86_64.rpm
```

You can download RPM files using `yum install -downloadonly`.

```
# for VER in 11 12; do
  yum install --downloadonly --downloaddir=rpmtest/${VER}/ \
  postgresql${VER} postgresql${VER}-server postgresql${VER}-devel \
  postgresql${VER}-libs postgresql${VER}-llvmjit; done
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

## Directory Configuration
After set up, direcotry configuration shoule be as follows.

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
Set environmental variables in generate_rpm.sh according to what kind of RPMs you want. 
You can change the PostgreSQL version using ${PG_VERSIONS}.

```
PG_VERSIONS="9.4 9.5 9.6 10 11 12"
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
