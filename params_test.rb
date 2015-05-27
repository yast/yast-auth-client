#!/usr/bin/env rspec
ENV['Y2DIR'] = File.expand_path('../../src', __FILE__)

require 'yast'
require 'yauthclient/uidata.rb'

Yast.import "AuthClient"

describe YAuthClient::Params do
    describe "Parameter database" do
        it "Contain parameter definitions"
            params = YAuthClient::Params.instance
            expect(params.all_params["sssd"].length).to be > 5

            expect(params.all_params["services"].length).to be > 5
            expect(params.all_params["nss"].length).to be > 5
            expect(params.all_params["pam"].length).to be > 5
            expect(params.all_params["sudo"].length).to be > 1
            expect(params.all_params["autofs"].length).to be > 1
            expect(params.all_params["ssh"].length).to be > 1

            expect(params.all_params["domain"].length).to be > 5
            expect(params.all_params["local"].length).to be > 5
            expect(params.all_params["ldap"].length).to be > 5
            expect(params.all_params["krb5"].length).to be > 5
            expect(params.all_params["ipa"].length).to be > 5
        end

        it "Get parameter definition by parameter name"
            params = YAuthClient::Params.instance
            defi = params.get_by_name("filter_users")
            expect(defi["desc"]).to eq("Exclude certain users from being fetched from the sss NSS database.")
            expect(defi["sect"]).to eq("nss")
            expect(defi["type"]).to eq("string")
            expect(defi["def"]).to eq("root")
            expect(defi["req"]).to eq(false)
            expect(defi["important"]).to eq(true)
        end
    end
end
