#!/usr/bin/env rspec
# ------------------------------------------------------------------------------
# Copyright (c) 2016 SUSE LINUX GmbH, Nuernberg, Germany.
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact SUSE Linux GmbH.
#
# ------------------------------------------------------------------------------
#
# Summary: Test the functions of AuthClient module.
# Authors: Howard Guo <hguo@suse.com>

require_relative "test_helper.rb"

require 'pp'
require 'auth/authconf'

describe Auth::AuthConf do
    before(:all) do
        change_scr_root(File.expand_path('../authconf_chroot', __FILE__))
    end
    after(:all) do
        reset_scr_root
    end
    authconf = Auth::AuthConfInst

    describe 'SSSD' do
        it 'Read, lint, and export SSSD configuration' do
            authconf.sssd_read
            expect(authconf.sssd_export).to eq('conf'=>
                {'sssd'=>
                    {'config_file_version'=>'2', 'services'=>['pam', 'nss'], 'domains'=>['abc']},
                    'nss'=>{'filter_users'=>'root', 'filter_groups'=>'root'},
                    'domain/abc'=>
                        {'id_provider'=>'ldap',
                        'auth_provider'=>'krb5',
                        'ldap_schema'=>'rfc2307bis',
                        'enumerate'=>'true',
                        'cache_credentials'=>'true',
                        'ldap_tls_reqcert'=>'hard',
                        'krb5_realm'=>'ABC.ZZZ'},
                'pam'=>{}},
                'pam'=>false,
                'nss'=>[],
                'enabled'=>false)
        end
        it 'Create SSSD configuration file' do
            expect(authconf.sssd_make_conf).to eq('[sssd]
config_file_version = 2
services = pam,nss
domains = abc

[nss]
filter_users = root
filter_groups = root

[domain/abc]
id_provider = ldap
auth_provider = krb5
ldap_schema = rfc2307bis
enumerate = true
cache_credentials = true
ldap_tls_reqcert = hard
krb5_realm = ABC.ZZZ

[pam]

')
        end
        it 'Import and recreate the same configuration' do
            conf =  {'conf'=>
                        {'sssd'=>
                            {'config_file_version'=>'2', 'services'=>['pam', 'nss'], 'domains'=>['abc']},
                            'nss'=>{'filter_users'=>'root', 'filter_groups'=>'root'},
                            'domain/abc'=>
                                {'id_provider'=>'ldap',
                                'auth_provider'=>'krb5',
                                'ldap_schema'=>'rfc2307bis',
                                'enumerate'=>'true',
                                'cache_credentials'=>'true',
                                'ldap_tls_reqcert'=>'hard',
                                'krb5_realm'=>'ABC.ZZZ'},
                            'pam'=>{}},
                        'pam'=>true,
                        'nss'=>['passwd', 'group'],
                        'enabled'=>true}
            authconf.sssd_import(conf)
            expect(authconf.sssd_export).to eq(conf)
        end
        it 'Enable and disable services' do
            authconf.sssd_enable_svc('ssh')
            authconf.sssd_enable_svc('autofs')
            expect(authconf.sssd_conf['sssd']['services']).to eq(['pam', 'nss', 'ssh', 'autofs'])
            authconf.sssd_disable_svc('ssh')
            authconf.sssd_disable_svc('autofs')
            expect(authconf.sssd_conf['sssd']['services']).to eq(['pam', 'nss'])
        end
        it 'List domain and services' do
            expect(authconf.sssd_get_services).to eq(['pam', 'nss'])
            expect(authconf.sssd_get_domains).to eq(['abc'])
            expect(authconf.sssd_get_inactive_domains).to eq([])
        end
    end

    describe 'LDAP' do
        it 'Read, lint, and export LDAP configuration' do
            authconf.ldap_read
            expect(authconf.ldap_export).to eq(
                'conf'=>{
                    'host'=>'127.0.0.1',
                    'base'=>'dc=example,dc=com',
                    'bind_policy'=>'soft',
                    'pam_lookup_policy'=>'yes',
                    'pam_password'=>'exop',
                    'nss_initgroups_ignoreusers'=>'root,ldap',
                    'nss_schema'=>'rfc2307bis',
                    'nss_map_attribute'=>'uniqueMember member',
                    'ssl'=>'start_tls'},
                'pam'=>false,
                'nss'=>[])
        end
        it 'Create LDAP configuration file' do
            expect(authconf.ldap_make_conf).to eq('host 127.0.0.1
base dc=example,dc=com
bind_policy soft
pam_lookup_policy yes
pam_password exop
nss_initgroups_ignoreusers root,ldap
nss_schema rfc2307bis
nss_map_attribute uniqueMember member
ssl start_tls
')
        end
        it 'Import and recreate the same configuration' do
            conf = {'conf'=>{
                    'host'=>'127.0.0.1',
                    'base'=>'dc=example,dc=com',
                    'bind_policy'=>'soft',
                    'pam_lookup_policy'=>'yes',
                    'pam_password'=>'exop',
                    'nss_initgroups_ignoreusers'=>'root,ldap',
                    'nss_schema'=>'rfc2307bis',
                    'nss_map_attribute'=>'uniqueMember member',
                    'ssl'=>'start_tls'},
                'pam'=>true,
                'nss'=>['passwd', 'group']}
            authconf.ldap_import(conf)
            expect(authconf.ldap_export).to eq(conf)
        end
    end

    describe 'Kerberos' do
        it 'Read, lint, and export Kerberos configuration' do
            # The first example is very simple
            authconf.krb_parse_set('
[libdefaults]
    default_realm = ABC.ZZZ

[realms]
        ABC.ZZZ = {
            kdc = howie.suse.de
            admin_server = howie.suse.de
            auth_to_local = RULE:[2:$1](johndoe)s/^.*$/guest/
        }
')
            expect(authconf.krb_export).to eq("conf"=>{
                    "include"=>[],
                    "libdefaults"=>{"default_realm"=>"ABC.ZZZ"},
                    "realms"=>{
                        "ABC.ZZZ"=>{
                            "kdc"=>["howie.suse.de"],
                            "admin_server"=>"howie.suse.de",
                            "auth_to_local"=>["RULE:[2:$1](johndoe)s/^.*$/guest/"]
                        },
                    },
                    "domain_realm"=>{}, "logging"=>{}
                }, "pam"=>false)
            # The second tests for cruft in the section names
            authconf.krb_parse_set('
[libdefaultsXXXXXXXXX]
    default_realm = ABC.ZZZ

[realmsYYYZZZZXXXXX]
        ABC.ZZZ = {
            kdc = howie.suse.de
            admin_server = howie.suse.de
            auth_to_local = RULE:[2:$1](johndoe)s/^.*$/guest/
        }
')
            expect(authconf.krb_export).to eq("conf"=>{
                    "include"=>[],
                    "libdefaults"=>{"default_realm"=>"ABC.ZZZ"},
                    "realms"=>{
                        "ABC.ZZZ"=>{
                            "kdc"=>["howie.suse.de"],
                            "admin_server"=>"howie.suse.de",
                            "auth_to_local"=>["RULE:[2:$1](johndoe)s/^.*$/guest/"]
                        },
                    },
                    "domain_realm"=>{}, "logging"=>{}
                }, "pam"=>false)
            # The third example is very comprehensive
            authconf.krb_parse_set('include a/b/c.d
includedir e/f/g.h
module i/j/k.l:RESIDUAL

[libdefaults]
#       default_realm = EXAMPLE.COM 
        default_realm = ABC.ZZZ
    forwardable = true
    default_ccache_name = FILE:/tmp/krb5cc_%{uid}

[realms]
#       EXAMPLE.COM = {
#                kdc = kerberos.example.com
#               admin_server = kerberos.example.com
#       }
        ABC.ZZZ = {
            kdc = howie.suse.de
            kdc = backup.howie.suse.de
            admin_server = howie.suse.de
            auth_to_local = {
                RULE:[2:$1](johndoe)s/^.*$/guest/
                RULE:[2:$1;$2](^.*;admin$)s/;admin$//
                RULE:[2:$2](^.*;root)s/^.*$/root/
                DEFAULT
            }
            auth_to_local_names = {
                apple = pineapple
                peach = avocado
            }
        }
        ABD.ZZZ = {
            kdc = howie2.suse.de
            admin_server = howie2.suse.de
        }
        EMPTY.NET = {
        }

[domain_realm]
.suse.de = ABC.ZZZ
suse.de = ABC.ZZZ

[logging]
        kdc = FILE:/var/log/krb5/krb5kdc.log
        admin_server = FILE:/var/log/krb5/kadmind.log
        default = SYSLOG:NOTICE:DAEMON

[dbmodules]
        openldap_ldapconf = {
                db_library = kldap
                ldap_kdc_dn = "cn=admin,dc=example,dc=com"

                # this object needs to have read rights on
                # the realm container, principal container and realm sub-trees
                ldap_kadmind_dn = "cn=admin,dc=example,dc=com"

                # this object needs to have read and write rights on
                # the realm container, principal container and realm sub-trees
                ldap_service_password_file = /etc/krb5kdc/service.keyfile
                ldap_servers = ldaps://ldap01.example.com ldaps://ldap02.example.com
                ldap_conns_per_server = 5
        }
')
            expect(authconf.krb_export).to eq("conf"=>{
                "include"=>["include a/b/c.d", "includedir e/f/g.h", "module i/j/k.l:RESIDUAL"],
                    "libdefaults"=>{"default_realm"=>"ABC.ZZZ", "forwardable"=>"true", "default_ccache_name"=>"FILE:/tmp/krb5cc_%{uid}"},
                    "realms"=>{
                        "ABC.ZZZ"=>{
                            "kdc"=>["howie.suse.de", "backup.howie.suse.de"],
                            "admin_server"=>"howie.suse.de",
                            "auth_to_local_names"=>{"apple"=>"pineapple", "peach"=>"avocado"},
                            "auth_to_local"=>["RULE:[2:$1](johndoe)s/^.*$/guest/", "RULE:[2:$1;$2](^.*;admin$)s/;admin$//", "RULE:[2:$2](^.*;root)s/^.*$/root/", "DEFAULT"]
                        },
                        "ABD.ZZZ"=>{
                            "kdc"=>["howie2.suse.de"], "admin_server"=>"howie2.suse.de"
                        },
                        "EMPTY.NET"=> {},
                    },
                    "domain_realm"=>{".suse.de"=>"ABC.ZZZ", "suse.de"=>"ABC.ZZZ"},
                    "logging"=>{"kdc"=>"FILE:/var/log/krb5/krb5kdc.log", "admin_server"=>"FILE:/var/log/krb5/kadmind.log", "default"=>"SYSLOG:NOTICE:DAEMON"},
                    "dbmodules"=>{
                        "openldap_ldapconf"=>{
                            "db_library"=>"kldap",
                            "ldap_kdc_dn"=>"\"cn=admin,dc=example,dc=com\"",
                            "ldap_kadmind_dn"=>"\"cn=admin,dc=example,dc=com\"",
                            "ldap_service_password_file"=>"/etc/krb5kdc/service.keyfile",
                            "ldap_servers"=>"ldaps://ldap01.example.com ldaps://ldap02.example.com",
                            "ldap_conns_per_server"=>"5"
                        }
                    }
                }, "pam"=>false)
            expect(authconf.krb_conf_get(['realms', 'ABC.ZZZ', 'kdc'], [])).to eq(["howie.suse.de", "backup.howie.suse.de"])
            expect(authconf.krb_conf_get(['realms', 'doesntexist', 'kdc'], [])).to eq([])
        end
        it 'Create Kerberos configuration file' do
            expect(authconf.krb_make_conf).to eq('include a/b/c.d
includedir e/f/g.h
module i/j/k.l:RESIDUAL

[libdefaults]
    default_realm = ABC.ZZZ
    forwardable = true
    default_ccache_name = FILE:/tmp/krb5cc_%{uid}

[domain_realm]
    .suse.de = ABC.ZZZ
    suse.de = ABC.ZZZ

[logging]
    kdc = FILE:/var/log/krb5/krb5kdc.log
    admin_server = FILE:/var/log/krb5/kadmind.log
    default = SYSLOG:NOTICE:DAEMON

[dbmodules]
    openldap_ldapconf = {
        db_library = kldap
        ldap_kdc_dn = "cn=admin,dc=example,dc=com"
        ldap_kadmind_dn = "cn=admin,dc=example,dc=com"
        ldap_service_password_file = /etc/krb5kdc/service.keyfile
        ldap_servers = ldaps://ldap01.example.com ldaps://ldap02.example.com
        ldap_conns_per_server = 5
    }

[realms]
    ABC.ZZZ = {
        kdc = howie.suse.de
        kdc = backup.howie.suse.de
        admin_server = howie.suse.de
        auth_to_local = {
            RULE:[2:$1](johndoe)s/^.*$/guest/
            RULE:[2:$1;$2](^.*;admin$)s/;admin$//
            RULE:[2:$2](^.*;root)s/^.*$/root/
            DEFAULT
        }
        auth_to_local_names = {
            apple = pineapple
            peach = avocado
        }
    }
    ABD.ZZZ = {
        kdc = howie2.suse.de
        admin_server = howie2.suse.de
    }
    EMPTY.NET = {
    }
')
        end
        it 'Import and recreate the same configuration' do
            conf = {"conf"=>
              {"realms"=>
                {"ABC.ZZZ"=>{"kdc"=>["howie.suse.de"], "admin_server"=>"howie.suse.de"},
                 "ABD.ZZZ"=>{"kdc"=>["howie2.suse.de"], "admin_server"=>"howie2.suse.de"}},
               "libdefaults"=>{"default_realm"=>"ABC.ZZZ", "forwardable"=>"true"},
               "domain_realm"=>{".suse.de"=>"ABC.ZZZ", "suse.de"=>"ABC.ZZZ"},
               "logging"=>
                {"kdc"=>"FILE:/var/log/krb5/krb5kdc.log",
                 "admin_server"=>"FILE:/var/log/krb5/kadmind.log",
                 "default"=>"SYSLOG:NOTICE:DAEMON"}},
             "pam"=>true}
            authconf.krb_import(conf)
            expect(authconf.krb_export).to eq(conf)
        end
        it 'Create/update realm' do
            conf = {"conf"=>
              {"realms"=>{},
               "libdefaults"=>{},
               "domain_realm"=>{},
               "logging"=>
                {"kdc"=>"FILE:/var/log/krb5/krb5kdc.log",
                 "admin_server"=>"FILE:/var/log/krb5/kadmind.log",
                 "default"=>"SYSLOG:NOTICE:DAEMON"}},
             "pam"=>true}
            authconf.krb_import(conf)
            authconf.krb_add_update_realm('abc.zzz', 'howie.suse.de', 'howie2.suse.de', true, true)
            expect(authconf.krb_export).to eq("conf"=>
              {"realms"=>
                {"ABC.ZZZ"=>{"kdc"=>"howie.suse.de", "admin_server"=>"howie2.suse.de"}},
               "libdefaults"=>{"default_realm"=>"ABC.ZZZ"},
               "domain_realm"=>{".abc.zzz"=>"ABC.ZZZ", "abc.zzz"=>"ABC.ZZZ"},
               "logging"=>
                {"kdc"=>"FILE:/var/log/krb5/krb5kdc.log",
                 "admin_server"=>"FILE:/var/log/krb5/kadmind.log",
                 "default"=>"SYSLOG:NOTICE:DAEMON"}, "include" => []},
             "pam"=>true)
            authconf.krb_add_update_realm('abc.zzz', '3.suse.de', '4.suse.de', false, false)
            expect(authconf.krb_export).to eq("conf"=>
              {"realms"=>
                {"ABC.ZZZ"=>{"kdc"=>"3.suse.de", "admin_server"=>"4.suse.de"}},
               "libdefaults"=>{"default_realm"=>"ABC.ZZZ"},
               "domain_realm"=>{},
               "logging"=>
                {"kdc"=>"FILE:/var/log/krb5/krb5kdc.log",
                 "admin_server"=>"FILE:/var/log/krb5/kadmind.log",
                 "default"=>"SYSLOG:NOTICE:DAEMON"}, "include" => []},
             "pam"=>true)
        end
    end

    describe 'Auxiliary daemons/PAM' do
        it 'Read, lint, and export auxiliary configuration' do
            authconf.aux_read
            expect(authconf.aux_export).to eq('autofs' => false, 'nscd' => false, 'mkhomedir' => false)
        end
        it 'Import and recreate the same configuration' do
            conf = {'autofs' => true, 'nscd' => true, 'mkhomedir' => true}
            authconf.aux_import(conf)
            expect(authconf.aux_export).to eq(conf)
        end
    end

    describe 'Network facts' do
        it 'Read host name and network facts' do
            facts = Auth::AuthConf.get_net_facts
            # No value can be nil
            expect(facts.any?{ |_k, v| v.nil? }).to eq(false)
            # There has to be at least one value that is present
            expect(facts.any?{ |_k, v| v != '' }).to eq(true)
        end
    end

    describe 'PAM' do
        it 'Fix pam authentication configuration' do
            expect(authconf.pam_fix_auth("
# comment
auth    required        pam_env.so
auth    optional        pam_gnome_keyring.so
auth    sufficient      pam_unix.so     try_first_pass
auth    sufficient      pam_krb5.so     use_first_pass
auth    sufficient      pam_sss.so      use_first_pass
auth    required        pam_ldap.so     use_first_pass
".split("\n"))).to eq [
                "",
                "# comment",
                "auth    required        pam_env.so",
                "auth    optional        pam_gnome_keyring.so",
                "auth    sufficient    pam_unix.so    try_first_pass",
                "auth    sufficient    pam_krb5.so    use_first_pass",
                "auth    sufficient    pam_sss.so    use_first_pass",
                "auth    sufficient    pam_ldap.so    use_first_pass",
                "auth    required    pam_deny.so"
            ]
        end

        it 'Fix pam authentication configuration (unix2)' do
            expect(authconf.pam_fix_auth("
# comment
auth    required        pam_env.so
auth    optional        pam_gnome_keyring.so
auth    sufficient      pam_unix2.so     try_first_pass
auth    sufficient      pam_krb5.so     use_first_pass
auth    sufficient      pam_sss.so      use_first_pass
auth    required        pam_ldap.so     use_first_pass
".split("\n"))).to eq [
                "",
                "# comment",
                "auth    required        pam_env.so",
                "auth    optional        pam_gnome_keyring.so",
                "auth    sufficient    pam_unix2.so    try_first_pass",
                "auth    sufficient    pam_krb5.so    use_first_pass",
                "auth    sufficient    pam_sss.so    use_first_pass",
                "auth    sufficient    pam_ldap.so    use_first_pass",
                "auth    required    pam_deny.so"
            ]
        end

        it 'Fix pam account configuration' do
            expect(authconf.pam_fix_account("
# comment
account requisite       pam_unix.so     try_first_pass
account required        pam_krb5.so     use_first_pass
account sufficient      pam_localuser.so
account sufficient      pam_sss.so      use_first_pass
account required        pam_ldap.so     use_first_pass
".split("\n"))).to eq [
                "",
                "# comment",
                "account    requisite    pam_unix.so    try_first_pass",
                "account    sufficient    pam_localuser.so",
                "account required        pam_krb5.so     use_first_pass",
                "account sufficient      pam_sss.so      use_first_pass",
                "account required        pam_ldap.so     use_first_pass"
            ]
        end

        it 'Fix pam account configuration (unix2)' do
            expect(authconf.pam_fix_account("
# comment
account requisite       pam_unix2.so     try_first_pass
account required        pam_krb5.so     use_first_pass
account sufficient      pam_localuser.so
account sufficient      pam_sss.so      use_first_pass
account required        pam_ldap.so     use_first_pass
".split("\n"))).to eq [
                "",
                "# comment",
                "account    requisite    pam_unix2.so    try_first_pass",
                "account    sufficient    pam_localuser.so",
                "account required        pam_krb5.so     use_first_pass",
                "account sufficient      pam_sss.so      use_first_pass",
                "account required        pam_ldap.so     use_first_pass"
            ]
        end
    end
end
