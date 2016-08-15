#
# spec file for package yast2-auth-client
#
# Copyright (c) 2015 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast2-auth-client
Version:        3.3.10
Release:        0
Group:          System/YaST
License:        GPL-2.0
URL:            https://github.com/yast/yast-auth-client
Summary:        YaST2 - Centralised System Authentication Configuration

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Source0:        %{name}-%{version}.tar.bz2

BuildArch:      noarch
Requires:       yast2
Requires:       yast2 >= 2.21.22
Requires:       yast2-pam >= 2.20.0
Requires:       yast2-ruby-bindings >= 1.0.0
Requires:       net-tools
BuildRequires:  yast2
BuildRequires:  yast2-devtools >= 3.0.6
BuildRequires:  rubygem(yast-rake)
BuildRequires:  doxygen perl-XML-Writer update-desktop-files yast2 yast2-pam yast2-testsuite yast2-network

PreReq:         %fillup_prereq
Obsoletes:      yast2-ldap-client yast2-kerberos-client

%description
With this YaST2 module you may configure centralised system authentication, on a single or multipe network domains.

%prep
%setup -n %{name}-%{version}

%build

%install
rake install DESTDIR="%{buildroot}"

%files
%defattr(-,root,root)
%doc %{yast_docdir}
%{yast_libdir}/
%{yast_desktopdir}/
%{yast_clientdir}/
%{yast_libdir}/
%{yast_scrconfdir}/

