yast2-auth-client
=================

[![Workflow Status](https://github.com/yast/yast-auth-client/workflows/CI/badge.svg?branch=master)](
https://github.com/yast/yast-auth-client/actions?query=branch%3Amaster)
[![Jenkins Status](https://ci.opensuse.org/buildStatus/icon?job=yast-yast-auth-client-master)](
https://ci.opensuse.org/view/Yast/job/yast-yast-auth-client-master/)


With this YaST2 module you can configure the authentication on your machine

Features
--------

  * Configure single or multi-domain authentication via SSSD
  * Enroll a host at Microsoft Active Directory
  * Configure PAM/NSS for LDAP or Kerberos via SSSD

Installation
------------

To install the latest stable version on openSUSE or SLE, use zypper:

    $ sudo zypper install yast2-auth-client

Running
-------

To run the module, use the following command:

    $ sudo /usr/sbin/yast2 auth-client

This will run the module in text mode. For more options, including running in
your desktop environment, see section on [running YaST](https://en.opensuse.org/SDB:Starting_YaST) in the YaST documentation.


Development
-----------

You need to prepare your environment with:

```
ruby_version=$(ruby -e "puts RbConfig::CONFIG['ruby_version']")
zypper install -C "rubygem(ruby:$ruby_version:yast-rake)"
zypper install -C "rubygem(ruby:$ruby_version:rspec)"
zypper install git yast2-devtools yast2-testsuite yast2
```

You can then run a module with from `src/clients/` by calling it's module name as an argument
to rake run. For example, to run the default module call:

```
rake run
```

To specifically run the `auth-client` module:

```
rake run[auth-client]A
```
