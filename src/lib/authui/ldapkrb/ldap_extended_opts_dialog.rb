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
    # Edit more configuration items for LDAP.
    class LdapExtendedOptsDialog < UI::Dialog
        include Yast
        include Auth
        include UIShortcuts
        include I18n

        def initialize
            super()
            textdomain "auth-client"
        end

        def create_dialog
            super
        end

        def dialog_options
            Opt(:decorated)
        end

        def dialog_content
            # The user cannot possibly understand the implication of 0 in search timeout if the user uses YaST
            MinWidth(80, VBox(
                IntField(Id(:ldap_bind_timelimit), Opt(:hstretch), _('Timeout for Bind Operations in Seconds'), 1, 600,
                           (AuthConfInst.ldap_conf['bind_timelimit'].to_s == '' ? '30' : AuthConfInst.ldap_conf['bind_timelimit']).to_i),
                IntField(Id(:ldap_timelimit), Opt(:hstretch), _('Timeout for Search Operations in Seconds'), 1, 600,
                           (AuthConfInst.ldap_conf['timelimit'].to_s == '' ? '30' : AuthConfInst.ldap_conf['timelimit']).to_i),
                VSpacing(1.0),
                PushButton(Id(:finish), Label.FinishButton)
            ))
        end

        def finish_handler
            # The user cannot possibly understand the implication of 'hard' policy if the user uses YaST
            AuthConfInst.ldap_conf['bind_policy'] = 'soft'
            AuthConfInst.ldap_conf['bind_timelimit'] = UI.QueryWidget(Id(:ldap_bind_timelimit), :Value)
            AuthConfInst.ldap_conf['timelimit'] = UI.QueryWidget(Id(:ldap_timelimit), :Value)
            finish_dialog(:finish)
        end
    end
end
