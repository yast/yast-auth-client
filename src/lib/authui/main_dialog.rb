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
#

require 'yast'
require 'ui/dialog'
require 'auth/authconf'
require 'authui/sssd/main_dialog'
require 'authui/ldapkrb/main_dialog'
Yast.import 'UI'
Yast.import 'Icon'
Yast.import 'Label'

module Auth
    # Main dialog displays an overview of authentication mechanisms enabled on the system.
    class MainDialog < UI::Dialog
        include Yast
        include Auth
        include UIShortcuts
        include I18n
        include Logger

        def initialize
            super()
            textdomain 'auth-client'
        end

        def dialog_options
            Opt(:decorated, :defaultsize)
        end

        def create_dialog
            return false unless super
            refresh_config_status
            return true
        end

        def dialog_content
            Left(VBox(
                   Left(Heading(_('System authentication and domain configuration'))),
              VSpacing(1),
              Left(HBox(
                     HWeight(10, Empty()),
                HWeight(80, VBox(
                              Left(Frame(_('Computer Name and Domain'),
                                VBox(
                                  Left(HBox(
                                         Label(Opt(:hstretch), _('Computer Name:')),
                                    Label(Id(:computer_name), '')
                                    )),
                                  Left(HBox(
                                         Label(Opt(:hstretch), _('Network Domain:')),
                                    Label(Id(:network_domain), '')
                                    )),
                                  Left(HBox(
                                         Label(Opt(:hstretch), _('Full Computer Name:')),
                                    Label(Id(:full_computer_name), '')
                                    )),
                                  Left(HBox(
                                         Label(Opt(:hstretch), _('IP Address:')),
                                    Label(Id(:ip_addresses), '')
                                    )),
                                  Left(HBox(
                                         Label(Opt(:hstretch), _('Authentication and User Identity Domain(s):')),
                                    Label(Id(:auth_domains), '')
                                    )),
                                  VSpacing(2.0),
                                  HBox(
                                    PushButton(Id(:manage_sssd), _('Manage Authentication Domains')),
                                    PushButton(Id(:manage_ldap_krb), _('Manage Kerberos and Legacy LDAP Options')),
                                    PushButton(Id(:finish), Label.FinishButton)
                                    )
                                  )
                              ))
                  )),
                HWeight(10, Empty())
              ))
            ))
        end

        def user_input
            UI.TimeoutUserInput(1000)
        end

        # Display the latest configuration and daemon status.
        def timeout_handler
            refresh_config_status
        end

        # Update widgets to reflect the current configuration and daemon status.
        def refresh_config_status
            net_facts = AuthConf.get_net_facts
            UI.ChangeWidget(Id(:computer_name), :Value, net_facts['computer_name'])
            UI.ChangeWidget(Id(:full_computer_name), :Value, net_facts['full_computer_name'] == '' ? _('(Name is not resolvable)') : net_facts['full_computer_name'])
            UI.ChangeWidget(Id(:network_domain), :Value, net_facts['network_domain'] == '' ? _('(Name is not resolvable)') : net_facts['network_domain'])
            UI.ChangeWidget(Id(:ip_addresses), :Value, net_facts['ip_addresses'].join(', '))
            UI.ChangeWidget(Id(:auth_domains), :Value, AuthConfInst.summary_text)
            UI.RecalcLayout
        end

        # Enter SSSD configuration dialog.
        def manage_sssd_handler
            SSSD::MainDialog.new.run
        end

        # Enter LDAP/Kerberos/Aux daemon configuration dialog.
        def manage_ldap_krb_handler
            LdapKrb::MainDialog.new.run
        end

        # Close the dialog
        def finish_handler
            finish_dialog(:finish)
        end
    end
end
