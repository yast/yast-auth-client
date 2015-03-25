# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2015 SUSE LINUX GmbH, Nuernberg, Germany.
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
require "yauthclient/uidata.rb"
require "yauthclient/params.rb"

module YAuthClient
    # Change a parameter value for the current section.
    class EditParamDialog
        include Yast::UIShortcuts
        include Yast::I18n
        include Yast::Logger

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
                Yast::UI.CloseDialog()
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
                Yast::UI.OpenDialog(
                    VBox(
                        Left(Label(@param_def["desc"])),
                        Left(input_control),
                        ButtonBox(
                            PushButton(Id(:ok), Yast::Label.OKButton),
                            PushButton(Id(:cancel), Yast::Label.CancelButton)
                        )
                    )
                )
            end

            # Return :ok or :cancel depends on the user action.
            def ui_event_loop
                loop do
                    case Yast::UI.UserInput
                    when :ok
                        val = Yast::UI.QueryWidget(Id(:value), :Value)
                        sect_conf = UIData.instance.get_conf.fetch(UIData.instance.get_curr_section, Hash[])
                        sect_conf[@param_name] = val.to_s
                        UIData.instance.get_conf[UIData.instance.get_curr_section] = sect_conf
                        return :ok
                    when :cancel
                        return :cancel
                    end
                end
            end
    end
end
