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
            sssd_conf = exported['sssd']
            conf_struct = sssd_conf['conf']
            # Revert work-around of slash character in element names
            conf_struct.keys.select{ |key| /domain-/.match(key) }.each{ |key|
                conf_struct['domain/' + key.gsub(/domain-/, '')] = conf_struct[key]
                conf_struct.delete(key)
            }
            AuthConfInst.sssd_import(sssd_conf)
            AuthConfInst.ldap_import(exported['ldap'])
            AuthConfInst.krb_import(exported['krb'])
            AuthConfInst.aux_import(exported['aux'])
            AuthConfInst.ad_import(exported['ad'])
            AuthConfInst.autoyast_modified = true
            return true
        end

        # Return configuration parameters serialised in JSON, to be Imported and applied later.
        def export
            sssd_conf = AuthConfInst.sssd_export
            conf_struct = sssd_conf['conf']
            # Work-around slash character in element name
            conf_struct.keys.select{ |key| /domain\//.match(key) }.each { |key|
                conf_struct['domain-' + key.gsub(/domain\//, '')] = conf_struct[key]
                conf_struct.delete(key)
            }
            return {'sssd' => sssd_conf,
                'ldap' => AuthConfInst.ldap_export,
                'krb' => AuthConfInst.krb_export,
                'aux' => AuthConfInst.aux_export,
                'ad' => AuthConfInst.ad_export, }
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
            MainDialog.new.run
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
