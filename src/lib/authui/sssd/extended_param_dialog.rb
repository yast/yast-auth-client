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
require 'authui/sssd/uidata'
require 'auth/authconf'
Yast.import 'UI'
Yast.import 'Label'

module SSSD
    # Let user choose one additional parameter to customise for domain.
    class ExtendedParamDialog < UI::Dialog
        include Yast
        include Auth
        include UIShortcuts
        include I18n
        include Logger

        def initialize(sect_name_caption)
            super()
            textdomain "auth-client"
            @sect_name_caption = sect_name_caption
        end

        def create_dialog
            return false unless super
            render_table('')
            return true
        end

        def dialog_options
            Opt(:decorated, :defaultsize)
        end

        def render_table(filter_val)
            UI.ReplaceWidget(Id(:param_table_point), Table(
                Id(:param_table),
                Header(_("Name"), _("Description")),
                UIData.instance.get_section_params_with_filter(filter_val).map { |name, detail|
                    desc = detail["desc"].lines[0]
                    desc = desc && desc.strip || ""
                    Item(name, desc)
                }
            ))
        end

        def dialog_content
            VBox(
                Left(Label(Opt(:boldFont), _("Extended options") + ' - ' + @sect_name_caption)),
                HBox(
                    VBox(
                        InputField(Id(:param_filter), Opt(:hstretch, :notify), _("Name filter:"), ""),
                        ReplacePoint(Id(:param_table_point), Empty()),
                    ),
                ),
                HBox(
                    PushButton(Id(:add), Label.AddButton),
                    PushButton(Id(:cancel), Label.CancelButton),
                ),
            )
        end

        # Reload parameter table according to the filter
        def param_filter_handler
            render_table(UI.QueryWidget(Id(:param_filter), :Value))
        end

        def add_handler
            param_name = UI.QueryWidget(Id(:param_table), :CurrentItem)
            return if param_name.nil?
            if EditParamDialog.new(param_name).run == :ok
                finish_dialog(:ok)
            end
        end

        def cancel_handler
            finish_dialog(nil)
        end
    end
end
