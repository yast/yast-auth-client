#!/usr/bin/env rspec
ENV['Y2DIR'] = File.expand_path('../../src', __FILE__)

require 'yast'
require 'yauthclient/uidata.rb'

Yast.import "AuthClient"

describe YAuthClient::Params do
    describe "Parameter database" do
        it "Contain parameter definitions" do
            params = YAuthClient::Params.instance
            expect(params.all_params["sssd"].length).to be > 5

            expect(params.all_params["services"].length).to be > 5
            expect(params.all_params["nss"].length).to be > 5
            expect(params.all_params["pam"].length).to be > 5
            expect(params.all_params["sudo"].length).to be > 0
            expect(params.all_params["autofs"].length).to be > 0
            expect(params.all_params["ssh"].length).to be > 0

            expect(params.all_params["domain"].length).to be > 5
            expect(params.all_params["local"].length).to be > 5
            expect(params.all_params["ldap"].length).to be > 5
            expect(params.all_params["krb5"].length).to be > 5
            expect(params.all_params["ipa"].length).to be > 5
        end

        it "Get parameter definition by parameter name" do
            params = YAuthClient::Params.instance
            defi = params.get_by_name("filter_users")
            expect(defi["desc"]).to eq("Exclude certain users from being fetched by SSS backend")
            expect(defi["sect"]).to eq("nss")
            expect(defi["type"]).to eq("string")
            expect(defi["def"]).to eq("root")
            expect(defi["req"]).to eq(false)
            expect(defi["important"]).to eq(true)
        end

        it "Get parameter definitions by category and provider" do
            params = YAuthClient::Params.instance
            expect(params.get_common_domain_params).to eq(params.get_by_category("domain"))
            expect(params.get_common_service_params).to eq(params.get_by_category("services"))

            ldap_and_krb5 = params.get_by_category("ldap").merge(params.get_by_category("krb5"))
            expect(params.get_by_provider("ipa")).to eq(params.get_by_category("ipa").merge(ldap_and_krb5))
            expect(params.get_by_provider("ad")).to eq(params.get_by_category("ad").merge(ldap_and_krb5))

            expect(params.get_by_provider("nss")).to eq(params.get_by_category("nss"))
            expect(params.get_by_provider("sssd")).to eq(params.get_by_category("sssd"))
        end
    end
end
