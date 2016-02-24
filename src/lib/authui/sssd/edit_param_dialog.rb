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

require "yast"
require "auth/authconf.rb"
require "authui/sssd/uidata.rb"
require "authui/sssd/params.rb"

module SSSD
    # Change a parameter value for the current section.
    class EditParamDialog
        include Yast
        include Auth
        include UIShortcuts
        include I18n
        include Logger

        def initialize(param_name)
            textdomain "auth-client"
            @param_name = param_name
            @param_def = Params.instance.get_by_name(param_name)
            # Customised value of the parameter, or default if no customisation.
            @param_val = UIData.instance.get_param_val(param_name)
            if @param_val == nil
                @param_val = @param_def["def"]
            end
        end

        # Return :ok or :cancel depends on the user action.
        def run
            return if !render_all
            begin
                return ui_event_loop
            ensure
                UI.CloseDialog()
            end
        end

        private
            # Render controls for editing parameter value according to the parameter data type.
            def render_all
                input_control = nil
                case @param_def["type"]
                    when "int"
                        input_control = IntField(Id(:value), @param_name, 0, 1000000000, @param_val.to_i)
                    when "boolean"
                        input_control = CheckBox(Id(:value), @param_name, !!/true/i.match(@param_val.to_s))
                    else
                        if @param_def["vals"].empty?
                            input_control = InputField(Id(:value), Opt(:hstretch), @param_name, @param_val.to_s)
                        else
                            choices = @param_def["vals"].split(%r{[\s,]+})
                            input_control = ComboBox(Id(:value), @param_name, choices.map { |val|
                                Item(val, val == @param_val)
                            })
                        end
                end
                UI.OpenDialog(
                    VBox(
                        Left(Label(@param_def["desc"])),
                        Left(input_control),
                        ButtonBox(
                            PushButton(Id(:ok), Label.OKButton),
                            PushButton(Id(:cancel), Label.CancelButton)
                        )
                    )
                )
            end

            # Return :ok or :cancel depends on the user action.
            def ui_event_loop
                loop do
                    case UI.UserInput
                    when :ok
                        val = UI.QueryWidget(Id(:value), :Value)
                        AuthConfInst.sssd_conf[UIData.instance.get_curr_section][@param_name] = val.to_s
                        UIData.instance.reload_section
                        return :ok
                    when :cancel
                        return :cancel
                    end
                end
            end
    end
end
