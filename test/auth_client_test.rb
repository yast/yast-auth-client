#!/usr/bin/env rspec
#
ENV['Y2DIR'] = File.expand_path('../../src', __FILE__)

require 'yast'

Yast.import "AuthClient"

describe Yast::AuthClient do
  describe "importing autoyast values" do

    it "importing correct value with no sssd" do
      settings = {"nssldap"=>false, "oes"=>false, "sssd"=>false}
      expect(Yast::AuthClient.Import(settings)).to eq(true)
      expect(Yast::AuthClient.Export).to eq(settings)
    end

    it "importing correct value with sssd and sssd_conf" do
      settings = {
        "nssldap"=>false, 
        "oes"=>false, "sssd"=>true,
        "sssd_conf"=>{
          "sssd"=>{"config_file_version"=>2, "services"=>"nss, pam"},
          "auth_domains"=>[
            {"domain_name"=>"default",
             "ldap_uri"=>"ldap://ldap.suse.de",
             "ldap_search_base"=>"dc=suse,dc=de",
             "ldap_schema"=>"rfc2307bis",
             "id_provider"=>"ldap",
             "ldap_id_use_start_tls"=>true,
             "enumerate"=>false,
             "cache_credentials"=>false,
             "chpass_provider"=>"ldap",
             "auth_provider"=>"ldap"
            }]
        }       
      }
      expect(Yast::AuthClient.Import(settings)).to eq(true)
      expect(Yast::AuthClient.Export).to eq(settings)
    end

    it "importing wrong value (sssd but not defined sssd_conf)" do
      settings = {"nssldap"=>false, "oes"=>false, "sssd"=>true}
      expect(Yast::AuthClient.Import(settings)).to eq(false)
    end

    it "importing wrong value (sssd,sssd_conf but not defined auth_domains)" do
      settings = {
        "nssldap"=>false, 
        "oes"=>false, "sssd"=>true,
        "sssd_conf"=>{
          "sssd"=>{"config_file_version"=>2, "services"=>"nss, pam"}
        }       
      }
      expect(Yast::AuthClient.Import(settings)).to eq(false)
    end

  end
end
