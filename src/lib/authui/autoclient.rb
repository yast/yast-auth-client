# encoding: utf-8

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
# Authors:      Howard Guo <hguo@suse.com>

require 'json'
require 'installation/auto_client'
require 'auth/authconf'
require 'authui/main_dialog'
Yast.import 'Summary'

module Auth
    # The AutoYast interface for authentication client module.
    class AutoClient < ::Installation::AutoClient
        include Logger
        def initialize
            textdomain 'auth-client'
        end

        def run
            progress_orig = Progress.set(false)
            ret = super
            Progress.set(progress_orig)
            ret
        end

        # Import configuration parameters saved by Export operation.
        def import(exported)
            if exported.has_key?('sssd')
                # Import legacy XML configuration from SLE 12 SP0 or SP1
                sssd = exported
                if sssd.has_key?('listentry')
                    sssd = sssd['listentry']
                end

                sssd_enabled = sssd.fetch('sssd', nil)
                if sssd_enabled == 'yes' || sssd_enabled == 'true'
                    sssd_enabled = true
                elsif sssd_enabled == 'no' || sssd_enabled == 'false'
                    sssd_enabled = false
                end

                mkhomedir_enabled = sssd.fetch('mkhomedir', nil)
                if mkhomedir_enabled == 'yes' || mkhomedir_enabled == 'true'
                    mkhomedir_enabled = true
                elsif mkhomedir_enabled == 'no' || mkhomedir_enabled == 'false'
                    mkhomedir_enabled = false
                end

                daemon = sssd.fetch('sssd_conf', {}).fetch('sssd', nil)
                auth_domain = sssd.fetch('sssd_conf', {}).fetch('auth_domains', {})

                if auth_domain.is_a?(Array)
                    domain = auth_domain[0]
                else
                    domain = auth_domain.fetch('domain', {})
                end

                domain_name = domain.fetch('domain_name', nil)
                if !sssd_enabled || daemon.nil? || domain_name.nil?
                    log.info('legacy configuration is empty or disabled')
                    return true
                end
                AuthConfInst.clear
                AuthConfInst.sssd_lint_conf # make a basic config structure
                AuthConfInst.sssd_enabled = sssd_enabled
                AuthConfInst.sssd_pam = true
                AuthConfInst.mkhomedir_pam = mkhomedir_enabled
                AuthConfInst.sssd_nss = ['passwd', 'group']
                AuthConfInst.sssd_conf['sssd'] = daemon
                domain.delete('domain_name')
                AuthConfInst.sssd_conf['domain/' + domain_name] = domain
                AuthConfInst.sssd_lint_conf # break "domains" and "services" into arrays
            else
                # Import JSON configuration from SLE 12 SP2
                record = JSON.parse(exported['conf_json'])
                AuthConfInst.sssd_import(record['sssd'])
                AuthConfInst.ldap_import(record['ldap'])
                AuthConfInst.krb_import(record['krb'])
                AuthConfInst.aux_import(record['aux'])
                AuthConfInst.ad_import(record['ad'])
                AuthConfInst.autoyast_modified = true
            end

            return true
        end

        # Return configuration parameters serialised in JSON, to be imported and applied later.
        def export
            return {
                'conf_json' => JSON.generate('sssd' => AuthConfInst.sssd_export,
                    'ldap' => AuthConfInst.ldap_export,
                    'krb' => AuthConfInst.krb_export,
                    'aux' => AuthConfInst.aux_export,
                    'ad' => AuthConfInst.ad_export)
            }
        end

        def modified?
            return AuthConfInst.autoyast_modified
        end

        def modified
            AuthConfInst.autoyast_modified = true
        end

        # Return rich text summary for all VPN gateways and connections.
        def summary
            return AuthConfInst.summary_text
        end

        # Bring up the main dialog to let user work on the configuration.
        def change
            MainDialog.new(:auto).run
            AuthConfInst.autoyast_modified = true
            return :finish
        end

        # Apply all configuration.
        def write
            AuthConfInst.autoyast_editor_mode = false
            AuthConfInst.ldap_apply
            AuthConfInst.krb_apply
            AuthConfInst.aux_apply
            # If there is an AD domain, it has to join before SSSD is started
            success, output = AuthConfInst.ad_join_domain
            if !success
                AuthConfInst.autoyast_editor_mode = true
                Yast::Report.Error 'AD domain enrollment failed! Output is: ' + output.to_s
            end
            AuthConfInst.sssd_apply
            AuthConfInst.autoyast_editor_mode = true
            return true
        end

        # Load authentication configuration from the current running system.
        def read
            AuthConfInst.read_all
            # Reset AD enrollment parameters
            AuthConfInst.ad_domain = ''
            AuthConfInst.ad_user = ''
            AuthConfInst.ad_ou = ''
            AuthConfInst.ad_pass = ''
            AuthConfInst.ad_overwrite_smb_conf = false
            AuthConfInst.autoyast_modified = true
            return true
        end

        # Packages will be installed when configuration is saved.
        def pacakges
            return {"install" => AuthConfInst.calc_pkg_deps, "remove" => []}
        end

        # Clear all configuration objects.
        def reset
            AuthConfInst.clear
            AuthConfInst.autoyast_modified = false
            return true
        end
    end
end
