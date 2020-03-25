# SPEC file template for pg_bigm
# Portions Copyright (c) 2017-2020, pg_bigm Development Group
# Portions Copyright (c) 2016, Sawada Masahiko

## These varibales use place holders.
## generate_rpm.sh replaces strings which begin with 'PLACEHOLDER_'
## to concrete values.
%define original_version PLACEHOLDER_original_version
%define without_dot_version PLACEHOLDER_without_dot_version
%define pg_bigm_version PLACEHOLDER_bigm_version
%define _topdir PLACEHOLDER__topdir

%define _pgdir   /usr/pgsql-%{original_version}
%define _libdir  %{_pgdir}/lib
%define _datadir %{_pgdir}/share
%define _bcdir %{_libdir}/bitcode
%define _mybcdir %{_bcdir}/pg_bigm

## Set general information for pg_bigm.
Summary:    2-gram full text search for PostgreSQL
Name:       pg_bigm
Version:    %{pg_bigm_version}
Release:    1.pg%{without_dot_version}%{?dist}
License:    The PostgreSQL License
Group:      Applications/Databases
Source0:    %{name}-%{version}.tar.gz
URL:        https://pgbigm.osdn.jp/index_en.html
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)
Vendor:     pg_bigm Development Group

## We use postgresql-devel package
BuildRequires:  postgresql%{without_dot_version}-devel
Requires:  postgresql%{without_dot_version}-libs

## Description for "pg_bigm"
%description
The pg_bigm module provides full text search capability in PostgreSQL.
This module allows a user to create 2-gram (bigram) index for faster full text search.

Note that this package is available for only PostgreSQL %{original_version}.

## bitcode installation for llvmjit
%if %{without_dot_version} >= 11 && %{without_dot_version} < 90
%package llvmjit
Requires: postgresql%{without_dot_version}-server, postgresql%{without_dot_version}-llvmjit
Requires: pg_bigm = %{pg_bigm_version}
Summary:  Just-in-time compilation support for pg_bigm

%description llvmjit
Just-in-time compilation support for pg_bigm.
%endif

## pre work for build pg_bigm
%prep
%setup -q

## Set variables for build environment
%build
PATH=%{_pgdir}/bin:$PATH
make USE_PGXS=1 %{?_smp_mflags}

## Set variables for install
%install
PATH=%{_pgdir}/bin:$PATH
rm -rf %{buildroot}
make install USE_PGXS=1 DESTDIR=%{buildroot}

%clean
rm -rf %{buildroot}

%files
%defattr(0755,root,root)
%{_libdir}/pg_bigm.so
%defattr(0644,root,root)
%{_datadir}/extension/pg_bigm--1.2.sql
%{_datadir}/extension/pg_bigm--1.1--1.2.sql
%{_datadir}/extension/pg_bigm--1.0--1.1.sql
%{_datadir}/extension/pg_bigm.control

## bitcode installation for jit
%if %{without_dot_version} >= 11 && %{without_dot_version} < 90
%files llvmjit
%defattr(0644,root,root)
%{_bcdir}/pg_bigm.index.bc
%{_mybcdir}/bigm_gin.bc
%{_mybcdir}/bigm_op.bc
%endif

## History of pg_bigm
%changelog
* Wed Mar 25 2020 Torikoshi Atsushi <torikoshia@oss.nttdata.com>
* Fri Oct 20 2016 Sawada Masahiko <sawada.mshk@gmail.com>
