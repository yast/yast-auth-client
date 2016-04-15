yast2-auth-client
=================

[![Travis Build](https://travis-ci.org/yast/yast-auth-client.svg?branch=master)](https://travis-ci.org/yast/yast-auth-client)
[![Jenkins Build](http://img.shields.io/jenkins/s/https/ci.opensuse.org/yast-auth-client-master.svg)](https://ci.opensuse.org/view/Yast/job/yast-auth-client-master/)


With this YaST2 module you can configure the authentication on your machine

Features
--------

  * Configure single or multi-domain authentication via SSSD
  * Enroll a host at Microsoft Active Directory
  * Configure PAM/NSS for LDAP
  * Configure Kerberos client

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

