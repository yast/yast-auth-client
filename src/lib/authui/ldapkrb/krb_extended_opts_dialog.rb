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

require 'yast'
require 'ui/dialog'
require 'auth/authconf'
Yast.import 'UI'
Yast.import 'Label'

module LdapKrb
    # Edit more configuration items for Kerberos.
    class KrbExtendedOptsDialog < UI::Dialog
        include Yast
        include Auth
        include UIShortcuts
        include I18n

        def initialize
            super()
            textdomain "auth-client"
        end

        def create_dialog
            return super
        end

        def dialog_options
            Opt(:decorated)
        end

        def dialog_content
            MinWidth(80, VBox(
                InputField(Id(:default_keytab_name), Opt(:hstretch), _('Default Location of Keytab File'),
                    AuthConfInst.krb_conf_get(['libdefaults', 'default_keytab_name'], '/etc/krb5.keytab')),
                InputField(Id(:default_tgs_enctypes), Opt(:hstretch), _('Encryption Types for TGS (Space separated)'),
                    AuthConfInst.krb_conf_get(['libdefaults', 'default_tgs_enctypes'], AuthConfInst.krb_get_default(:default_tgs_enctypes))),
                InputField(Id(:default_tkt_enctypes), Opt(:hstretch), _('Encryption Types for Ticket (Space separated)'),
                    AuthConfInst.krb_conf_get(['libdefaults', 'default_tkt_enctypes'], AuthConfInst.krb_get_default(:default_tkt_enctypes))),
                InputField(Id(:permitted_enctypes), Opt(:hstretch), _('Encryption Types for Sessions (Space separated)'),
                    AuthConfInst.krb_conf_get(['libdefaults', 'permitted_enctypes'], AuthConfInst.krb_get_default(:permitted_enctypes))),
                InputField(Id(:extra_addresses), Opt(:hstretch), _('Additional Addresses to be put in Ticket (Comma separated)'),
                    AuthConfInst.krb_conf_get(['libdefaults', 'extra_addresses'], '')),
                VSpacing(1.0),
                HBox(PushButton(Id(:reset), _('Reset')), PushButton(Id(:finish), Label.OKButton)),
            ))
        end

        def reset_handler
            [:default_keytab_name, :default_tgs_enctypes, :default_tkt_enctypes, :permitted_enctypes].each { |key|
                UI.ChangeWidget(Id(key), :Value, AuthConfInst.krb_get_default(key))
            }
        end

        def finish_handler
            AuthConfInst.krb_conf['libdefaults']['default_keytab_name'] = UI.QueryWidget(Id(:default_keytab_name), :Value)
            AuthConfInst.krb_conf['libdefaults']['default_tgs_enctypes'] = UI.QueryWidget(Id(:default_tgs_enctypes), :Value)
            AuthConfInst.krb_conf['libdefaults']['default_tkt_enctypes'] = UI.QueryWidget(Id(:default_tkt_enctypes), :Value)
            AuthConfInst.krb_conf['libdefaults']['permitted_enctypes'] = UI.QueryWidget(Id(:permitted_enctypes), :Value)
            AuthConfInst.krb_conf['libdefaults']['extra_addresses'] = UI.QueryWidget(Id(:extra_addresses), :Value)
            finish_dialog(:finish)
        end
    end
end
