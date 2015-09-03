Name:           openstack-macros
Version:        2015.2
Release:        0
Summary:        OpenStack Packaging - RPM Macros
License:        Apache-2.0
Group:          Development/Libraries/Python
Url:            https://wiki.openstack.org/wiki/Rpm-packaging
Source1:        suse-macros.openstack
Source2:        common-macros.openstack
BuildArch:      noarch

%description
This package provides OpenStack RPM macros. You need it to build OpenStack
packages.

%prep

%build

%install
%if 0%{?suse_version}
install -D -m644 %{SOURCE1} %{buildroot}%{_sysconfdir}/rpm/suse-macros.openstack
%endif
install -D -m644 %{SOURCE2} %{buildroot}%{_sysconfdir}/rpm/common-macros.openstack

%files
%defattr(-,root,root)
%if 0%{?suse_version}
%{_sysconfdir}/rpm/suse-macros.openstack
%endif
%{_sysconfdir}/rpm/common-macros.openstack

%changelog
