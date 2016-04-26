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
            if AuthConfInst.ldap_conf['bind_policy'] == 'soft'
                UI.ChangeWidget(Id(:ldap_bind_policy), :CurrentButton, :ldap_bind_policy_soft)
            else
                UI.ChangeWidget(Id(:ldap_bind_policy), :CurrentButton, :ldap_bind_policy_hard)
            end
        end

        def dialog_options
            Opt(:decorated)
        end

        def dialog_content
            MinWidth(80, VBox(
                Frame(_('In Case Of Connection Outage:'), RadioButtonGroup(Id(:ldap_bind_policy), VBox(
                    Left(RadioButton(Id(:ldap_bind_policy_hard), _('Retry The Operation Endlessly'))),
                    Left(RadioButton(Id(:ldap_bind_policy_soft), _('Do Not Retry And Fail The Operation'))),
                ))),
                IntField(Id(:ldap_bind_timelimit), Opt(:hstretch), _('Timeout for Bind Operations in Seconds'), 1, 600,
                           (AuthConfInst.ldap_conf['bind_timelimit'].to_s == '' ? '30' : AuthConfInst.ldap_conf['bind_timelimit']).to_i),
                IntField(Id(:ldap_timelimit), Opt(:hstretch), _('Timeout for Search Operations in Seconds'), 1, 600,
                           (AuthConfInst.ldap_conf['timelimit'].to_s == '' ? '30' : AuthConfInst.ldap_conf['timelimit']).to_i),
                VSpacing(1.0),
                PushButton(Id(:finish), Label.FinishButton)
            ))
        end

        def finish_handler
            case UI.QueryWidget(Id(:ldap_bind_policy), :CurrentButton)
            when :ldap_bind_policy_hard
                AuthConfInst.ldap_conf['bind_policy'] = 'hard'
            when :ldap_bind_policy_soft
                AuthConfInst.ldap_conf['bind_policy'] = 'soft'
            end
            AuthConfInst.ldap_conf['bind_timelimit'] = UI.QueryWidget(Id(:ldap_bind_timelimit), :Value)
            AuthConfInst.ldap_conf['timelimit'] = UI.QueryWidget(Id(:ldap_timelimit), :Value)
            finish_dialog(:finish)
        end
    end
end
