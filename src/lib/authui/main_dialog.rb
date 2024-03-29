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

        # Entry point can be :sssd, :ldapkrb, or :auto
        # In auto mode, there will be two change settings buttons.
        def initialize(entry_point)
            super()
            textdomain 'auth-client'
        end

        def dialog_options
            Opt(:decorated, :defaultsize)
        end

        def create_dialog
            return false unless super
            render_info_table
            return true
        end

        def dialog_content
            conf_buttons = [PushButton(Id(:change_settings), _('Change Settings')), PushButton(Id(:finish), Label.OKButton)]
            VBox(
                Left(Heading(_('User Logon Management'))),
                Left(HBox(
                    HWeight(10, Empty()),
                    HWeight(80, VBox(
                        VSquash(MinHeight(10, ReplacePoint(Id(:info_table), Empty()))),
                        VSpacing(3),
                        Right(HBox(*conf_buttons)),
                    )),
                    HWeight(10, Empty()),
                )),
            )
        end

        def render_info_table
            net_facts = AuthConf.get_net_facts
            UI.ReplaceWidget(Id(:info_table), Table(Opt(:keepSorting),
                Header(_('Name'), _('Value')),
                [
                    Item(_('Computer Name'), net_facts['computer_name']),
                    Item(_('Full Computer Name'), net_facts['full_computer_name'] == '' ? _('(Name is not resolvable)') : net_facts['full_computer_name']),
                    Item(_('Network Domain'), net_facts['network_domain'] == '' ? _('(Name is not resolvable)') : net_facts['network_domain']),
                    Item(_('IP Addresses'), net_facts['ip_addresses'].join(', ')),
                    Item(_('Identity Domains'), AuthConfInst.summary_text),
                ]
            ))
        end

        # Enter SSSD configuration dialog.
        def change_settings_handler
            SSSD::MainDialog.new.run
            render_info_table
        end

        # Close the dialog
        def finish_handler
            finish_dialog(:next)
        end
    end
end
