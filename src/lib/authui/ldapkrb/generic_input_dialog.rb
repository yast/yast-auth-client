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
require 'auth/authconf'
Yast.import 'UI'
Yast.import 'Icon'
Yast.import 'Label'

module LdapKrb
    # A generic text input dialog.
    class GenericInputDialog
        include Yast
        include Auth
        include UIShortcuts
        include I18n
        include Logger

        def initialize(caption, default_text)
            @caption = caption
            @default_text = default_text
            textdomain "auth-client"
        end

        def run
            return if !render_all
            begin
                return ui_event_loop
            ensure
                UI.CloseDialog()
            end
        end

        def render_all
            UI.OpenDialog(
                VBox(
                    Left(Label(@caption)),
                    InputField(Id(:input), Opt(:hstretch), @default_text),
                    ButtonBox(
                        PushButton(Id(:ok), Label.OKButton),
                        PushButton(Id(:cancel), Label.CancelButton),
                    )
                )
            )
        end

        # Return text in the input field, or nil if the dialog is cancelled.
        def ui_event_loop
            loop do
                case UI.UserInput
                when :ok
                    return UI.QueryWidget(Id(:input), :Value)
                else
                    return nil
                end
            end
        end
    end
end
