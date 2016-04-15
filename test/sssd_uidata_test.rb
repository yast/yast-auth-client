#!/usr/bin/env rspec
#
ENV['Y2DIR'] = File.expand_path('../../src', __FILE__)

require 'yast'
require 'auth/authconf'
require 'authui/sssd/uidata'

uidata = SSSD::UIData.instance

describe SSSD::UIData do
    describe "UI state changes and calculation" do
        preload_conf = {'conf'=>
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
            'extra_svcs'=>[],
            'enabled'=>false}
        # AuthConfInst is the backbone of uidata
        AuthConf::AuthConfInst.sssd_import(preload_conf)

        it "Retrieve global options from section sssd that does not yet have parameters " do
            # Section configuration is a list of ["name", "value", "desc"]
            expect(uidata.get_curr_section).to eq("sssd")
            expect(uidata.get_section_conf).to eq([])
            expect(uidata.get_section_more_params.length).to be > 5
            uidata.reload_section
            expect(uidata.get_curr_section).to eq("sssd")
            expect(uidata.get_section_conf).to eq([])
            expect(uidata.get_section_more_params.length).to be > 5
        end

        it "Switch section to look at domain/abc" do
             match = [
               ["id_provider", "ldap", "The identification provider used for the domain."],
               ["auth_provider", "krb5", "The authentication provider used for the domain"],
               ["ldap_schema", "rfc2307bis", "LDAP schema type"],
               ["enumerate", "true", "Read all entities from backend database (increase server load)"],
               ["cache_credentials", "true", "Cache credentials for offline use"],
               ["ldap_tls_reqcert", "hard", "Validate server certification in LDAP TLS session"],
               ["krb5_realm", "ABC.ZZZ", "Kerberos realm (e.g. EXAMPLE.COM)"]
             ]
            uidata.switch_section("domain/abc")
            expect(uidata.get_curr_section).to eq("domain/abc")
            expect(uidata.get_section_conf).to eq(match)
            expect(uidata.get_section_more_params.length).to be > 10
            expect(uidata.get_current_id_provider).to eq("ldap")
            expect(uidata.get_current_auth_provider).to eq("krb5")
        end

        it "Return the customised value of the current section" do
            uidata.switch_section("domain/abc")
            expect(uidata.get_param_val("id_provider")).to eq "ldap"
            expect(uidata.get_param_val("auth_provider")).to eq "krb5"
            expect(uidata.get_param_val("this_does_not_exist")).to eq nil
        end

        it "Filter parameters by input" do
            uidata.switch_section("domain/abc")
            expect(uidata.get_section_params_with_filter("ldap timeout").keys).to eq ["ldap_enumeration_refresh_timeout", "ldap_purge_cache_timeout", "ldap_search_timeout", "ldap_enumeration_search_timeout", "ldap_network_timeout", "ldap_opt_timeout", "ldap_connection_expire_timeout"]
        end
    end
end
