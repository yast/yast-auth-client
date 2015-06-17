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
    # Customise important parameters for a newly created domain/service.
    class InitialCustomisationDialog
        include Yast::UIShortcuts
        include Yast::I18n
        include Yast::Logger

        def initialize(param_categories)
            textdomain "auth-client"
            # Array of all parameter categories relevant to this new section
            # e.g. [ldap, krb] or [ipa, ipa]
            @param_categories = param_categories
            # Figure out the required and important parameters ready for customisation
            @custom_params = Hash[]
            param_categories.each { |cat_name|
                @custom_params.merge!(
                    Params.instance.get_by_category(cat_name).keep_if { |name, defi|
                        defi["req"] || defi["important"]
                    }
                )
            }
            @custom_param_vals = Hash[]
            # The already-customised or default value of the custom_params
            @custom_params.each { |name, defi|
                val = UIData.instance.get_param_val(name)
                if val == nil
                    @custom_param_vals[name] = defi["def"] # default value
                else
                    @custom_param_vals[name] = val # already-set value
                end
            }
        end

        def run
            return :ok if @custom_params.empty?
            return if !render_all
            begin
                return ui_event_loop
            ensure
                Yast::UI.CloseDialog()
            end
        end

        private
            # Create parameter editor controls (label, input, help text) and return them.
            def make_editor(param_names)
                if param_names.empty?
                    return [Left(Label(_("None.")))]
                end
                param_controls = []
                param_names.sort.each { |name|
                    defi = @custom_params[name]
                    param_val = @custom_param_vals[name]
                    # Make value input
                    input_control = nil
                    case defi["type"]
                        when "int"
                            input_control = IntField(Id("val-" + name), defi["desc"], 0, 10000000, param_val.to_i)
                        when "boolean"
                            input_control = CheckBox(Id("val-" + name), defi["desc"], !!/true/i.match(param_val.to_s))
                        else
                            if defi["vals"].empty?
                                input_control = InputField(Id("val-" + name), defi["desc"], param_val.to_s)
                            else
                                choices = defi["vals"].split(%r{[\s,]+})
                                input_control = ComboBox(Id("val-" + name), defi["desc"], choices.map { |val|
                                    Item(val, val == param_val)
                                })
                            end
                    end
                    param_controls.push(Left(HSquash(input_control)))
                    param_controls.push(VSpacing(0.2))
                }
                return param_controls
            end

            # Render controls for editing parameter values, according to parameter data type.
            def render_all
                Yast::UI.OpenDialog(
                    VBox(
                        VSpacing(0.5),
                        Frame(
                            _("Mandatory Parameters"),
                            VBox(*make_editor(@custom_params.select {
                                |name, defi| defi["req"] && !defi["no_init_customisation"]
                            }.keys))
                        ),
                        VSpacing(0.5),
                        Frame(
                            _("Optional Parameters"),
                            VBox(*make_editor(@custom_params.select {
                                |name, defi| defi["important"] && !defi["no_init_customisation"]
                            }.keys))
                        ),
                        ButtonBox(
                            PushButton(Id(:ok), Yast::Label.OKButton),
                            PushButton(Id(:cancel), Yast::Label.CancelButton)
                        )
                    )
                )
            end

            # Return :ok or :cancel depends user action.
            def ui_event_loop
                loop do
                    case Yast::UI.UserInput
                    when :ok
                        # Check that all mandatory parameters are set
                        missing = @custom_params.select {
                            |name, defi| defi["req"] && !defi["no_init_customisation"]
                        }.keys.select { |name|
                            Yast::UI.QueryWidget(Id("val-" + name), :Value).to_s.empty?
                        }
                        if !missing.empty?
                            descs = missing.map { |pname| @custom_params[pname]["desc"] }
                            Yast::Popup.Error(_("Please complete all of the following mandatory parameters:\n") + descs.join("\n"))
                            redo
                        end
                        # Save parameter values
                        @custom_params.each { |name, defi|
                            val = Yast::UI.QueryWidget(Id("val-" + name), :Value).to_s
                            if !val.empty?
                                sect_conf = UIData.instance.get_conf.fetch(UIData.instance.get_curr_section, Hash[])
                                sect_conf[name] = val
                                UIData.instance.get_conf[UIData.instance.get_curr_section] = sect_conf
                            end
                        }
                        UIData.instance.reload_section
                        return :ok

                    when :cancel
                        # Remove the section and return to main screen
                        UIData.instance.del_curr_section
                        return :cancel
                    end
                end
            end
    end
end
