#!/usr/bin/env rspec
#
ENV['Y2DIR'] = File.expand_path('../../src', __FILE__)

require 'yast'
require 'yauthclient/uidata.rb'

Yast.import "AuthClient"

describe YAuthClient::UIData do
    describe "UI state changes and calculation" do
        preload_conf = {
            "nssldap"=>false, 
            "oes"=>false, "sssd"=>true,
            "sssd_conf"=>{
                "sssd"=>{"config_file_version"=>2, "services"=>"nss, pam", "domains"=>"dom2"},
                "auth_domains"=>[
                    {"domain_name"=>"dom1",
                    "ldap_uri"=>"ldap://ldap.suse.de",
                    "ldap_search_base"=>"dc=suse,dc=de",
                    "ldap_schema"=>"rfc2307bis",
                    "auth_provider"=>"krb5",
                    "id_provider"=>"ldap"
                    },
                    {"domain_name"=>"dom2",
                    "ldap_uri"=>"ldap://ldap.suse.de",
                    "ldap_search_base"=>"dc=suse,dc=de",
                    "id_provider"=>"ldap",
                    "auth_provider" => "local",
                    "ldap_service_object_class" => "ipService",
                    "ldap_netgroup_object_class" => "nisNetgroup",
                    "ldap_search_timeout" => 6,
                    "ldap_tls_reqcert" => "never"
                    }
                ]
            }
        }

        it "Load initial configuration - all sections" do
            expect(Yast::AuthClient.Import(preload_conf)).to eq(true)
            uidata = YAuthClient::UIData.instance
            expect(uidata.get_conf).to eq({
                "domain/dom1" => {"ldap_uri"=>"ldap://ldap.suse.de", "ldap_search_base"=>"dc=suse,dc=de", "ldap_schema"=>"rfc2307bis", "id_provider"=>"ldap", "auth_provider"=>"krb5"},
                "domain/dom2" => {"ldap_uri"=>"ldap://ldap.suse.de", "ldap_search_base"=>"dc=suse,dc=de", "id_provider"=>"ldap", "auth_provider"=>"local", "ldap_service_object_class"=>"ipService", "ldap_netgroup_object_class"=>"nisNetgroup", "ldap_search_timeout"=>6, "ldap_tls_reqcert"=>"never"},
                "sssd" => {"config_file_version"=>2, "services"=>"nss, pam", "domains"=>"dom2"}
            })
        end

        it "Initially look at section SSSD" do
            uidata = YAuthClient::UIData.instance
            # Section configuration is a list of ["name", "value", "desc"]
            match = [
                ["config_file_version", "2", "Indicates what is the syntax of the config file."], ["services", "nss, pam", "Comma separated list of services that are started when sssd itself starts.\nSupported services: nss, pam, sudo, autofs, ssh"],
                ["domains", "dom2", "SSSD can use more domains at the same time, but at least one must be configured or SSSD won't start.This parameter contains the list of domains in the order these will be queried."]
            ]
            expect(uidata.get_curr_section).to eq("sssd")
            expect(uidata.get_section_conf).to eq(match)
            expect(uidata.get_section_more_params.length).to be > 5
            uidata.reload_section
            expect(uidata.get_curr_section).to eq("sssd")
            expect(uidata.get_section_conf).to eq(match)
            expect(uidata.get_section_more_params.length).to be > 5
        end

        it "Switch section to look at domain/dom1" do
            uidata = YAuthClient::UIData.instance
            match = [
                ["ldap_uri", "ldap://ldap.suse.de", "URIs (ldap://) of LDAP servers (comma separated)"],
                ["ldap_search_base", "dc=suse,dc=de", "Base DN for LDAP search"],
                ["ldap_schema", "rfc2307bis", "LDAP schema type"],
                ["auth_provider", "krb5", "The authentication provider used for the domain"],
                ["id_provider", "ldap", "The identification provider used for the domain."]
            ]
            uidata.switch_section("domain/dom1")
            expect(uidata.get_curr_section).to eq("domain/dom1")
            expect(uidata.get_section_conf).to eq(match)
            expect(uidata.get_section_more_params.length).to be > 10
            expect(uidata.get_current_id_provider).to eq("ldap")
            expect(uidata.get_current_auth_provider).to eq("krb5")
            uidata.reload_section
            uidata.switch_section("domain/dom1")
            expect(uidata.get_curr_section).to eq("domain/dom1")
            expect(uidata.get_section_conf).to eq(match)
            expect(uidata.get_section_more_params.length).to be > 10
            expect(uidata.get_current_id_provider).to eq("ldap")
            expect(uidata.get_current_auth_provider).to eq("krb5")
        end

        it "Return the customised value of the current section" do
            uidata = YAuthClient::UIData.instance
            uidata.switch_section("domain/dom1")
            expect(uidata.get_param_val("ldap_uri")).to eq "ldap://ldap.suse.de"
            expect(uidata.get_param_val("id_provider")).to eq "ldap"
            expect(uidata.get_param_val("auth_provider")).to eq "krb5"
            expect(uidata.get_param_val("this_does_not_exist")).to eq nil
        end

        it "Detect enabled services domains" do
            uidata = YAuthClient::UIData.instance
            expect(uidata.get_all_domains).to eq ["domain/dom1", "domain/dom2"]
            expect(uidata.get_enabled_domains).to eq ["dom2"]

            expect(uidata.get_all_services).to eq ["nss", "pam"]
            expect(uidata.get_enabled_services).to eq ["nss", "pam"]
        end

        it "Detect unused services" do
            uidata = YAuthClient::UIData.instance
            expect(uidata.get_unused_svcs).to eq ["sudo", "autofs", "ssh"].sort
        end

        it "Get provider list" do
            uidata = YAuthClient::UIData.instance
            sorted = uidata.get_id_providers.uniq.sort
            expect(uidata.get_id_providers).to eq sorted
            sorted = uidata.get_auth_providers.uniq.sort
            expect(uidata.get_auth_providers).to eq sorted
        end

        it "Filter parameters by input" do
            uidata = YAuthClient::UIData.instance
            uidata.switch_section("domain/dom1")
            expect(uidata.get_section_params_with_filter("ldap timeout").keys).to eq ["ldap_enumeration_refresh_timeout", "ldap_purge_cache_timeout", "ldap_search_timeout", "ldap_enumeration_search_timeout", "ldap_network_timeout", "ldap_opt_timeout", "ldap_connection_expire_timeout"]
        end
    end
end
