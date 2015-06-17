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
require "yauthclient/initial_customisation_dialog.rb"

module YAuthClient
    # Create a new section, whether a Service or Domain.
    class NewSectionDialog
        include Yast::UIShortcuts
        include Yast::I18n
        include Yast::Logger

        def initialize
            textdomain "auth-client"
        end

        # Return name of the new section if it was created. :cancel otherwise.
        def run
            return if !render_all
            begin
                return ui_event_loop # return string or :cancel
            ensure
                Yast::UI.CloseDialog()
            end
        end

        private
            # Render input box and dropdowns for service/domain creation
            def render_all
                Yast::UI.OpenDialog(
                    VBox(
                        Left(Label(_("Would you like to enable another service or join a domain?"))),
                        RadioButtonGroup(
                            Id(:section_type),
                            VBox(
                                # New service
                                Left(RadioButton(Id(:type_svc), Opt(:notify), _("Service"), )),
                                SelectionBox(Id(:svc_name), "", UIData.instance.get_unused_svcs),
                                VSpacing(1),
                                # New domain and provider types
                                Left(RadioButton(Id(:type_dom), Opt(:notify), _("Domain"))),
                                VBox(
                                    Id(:section_dom),
                                    InputField(Id(:dom_name), Opt(:hstretch), _("Domain name (example.com):"),""),
                                    SelectionBox(
                                        Id(:id_provider),
                                        _("Identification provider:"),
                                        UIData.instance.get_id_providers
                                    ),
                                    SelectionBox(
                                        Id(:auth_provider),
                                        _("Authentication provider:"),
                                        ["(same as ID provider)"] + UIData.instance.get_auth_providers
                                    ),
                                    Left(CheckBox(Id(:activate), _("Activate Domain"), true))
                                )
                            )
                        ),
                        ButtonBox(
                            PushButton(Id(:ok), Yast::Label.OKButton),
                            PushButton(Id(:cancel), Yast::Label.CancelButton)
                        )
                    )
                )
                # Choose Service by default
                Yast::UI.ChangeWidget(Id(:section_dom), :Enabled, false)
                Yast::UI.ChangeWidget(Id(:section_type), :CurrentButton, :type_svc)
            end

            # Switch to new section and return :ok if section was created, or :cancel otherwise.
            def ui_event_loop
                loop do
                    case Yast::UI.UserInput
                    when :type_svc
                        # Enable service input & disable domain input
                        Yast::UI.ChangeWidget(Id(:svc_name), :Enabled, true)
                        Yast::UI.ChangeWidget(Id(:section_dom), :Enabled, false)
                    when :type_dom
                        # Enable domain input & enable domain input
                        Yast::UI.ChangeWidget(Id(:svc_name), :Enabled, false)
                        Yast::UI.ChangeWidget(Id(:section_dom), :Enabled, true)
                    when :ok
                        type = Yast::UI.QueryWidget(Id(:section_type), :CurrentButton)
                        sect_name = Yast::UI.QueryWidget(Id(:svc_name), :Value).to_s
                        if type == :type_svc
                            # Create new service
                            if sect_name == ""
                                Yast::Popup.Error(_("There are no more services to be enabled."))
                                redo
                            end
                            UIData.instance.get_conf[sect_name] = Hash[]
                            UIData.instance.get_conf["sssd"]["services"] = (UIData.instance.get_enabled_services + [sect_name]).join(",")
                            # Swtich to this new section
                            UIData.instance.switch_section(sect_name)
                            # Instruct user to create initial customisation
                            if InitialCustomisationDialog.new(["services", sect_name]).run != :ok
                                return :cancel
                            end
                        else
                            # Create new domain
                            sect_name = Yast::UI.QueryWidget(Id(:dom_name), :Value).to_s.strip
                            id_provider = Yast::UI.QueryWidget(Id(:id_provider), :Value).to_s
                            auth_provider = Yast::UI.QueryWidget(Id(:auth_provider), :Value).to_s
                            activate_dom = Yast::UI.QueryWidget(Id(:activate), :Value)
                            if sect_name == ""
                                Yast::Popup.Error(_("Please enter a name for the new domain."))
                                redo
                            elsif UIData.instance.get_all_domains.include?(sect_name)
                                Yast::Popup.Error(_("The domain name is already in-use."))
                                redo
                            end
                            if auth_provider == "(same as ID provider)"
                                auth_provider = id_provider
                            end
                            # Activate the new domain in SSSD daemon config
                            if activate_dom
                                UIData.instance.get_conf["sssd"]["domains"] = (UIData.instance.get_enabled_domains + [sect_name]).uniq.join(",")
                            end
                            # Create config in domain section
                            sect_name = "domain/" + sect_name
                            sect_conf = UIData.instance.get_conf.fetch(sect_name, Hash[])
                            sect_conf["id_provider"] = id_provider
                            sect_conf["auth_provider"] = auth_provider
                            if id_provider == "ldap" && sect_conf["ldap_schema"] == nil
                                sect_conf["ldap_schema"] = "rfc2307bis"
                            end
                            # Swtich to this new section
                            UIData.instance.get_conf[sect_name] = sect_conf
                            UIData.instance.switch_section(sect_name)
                            # Instruct user to create initial customisation
                            if InitialCustomisationDialog.new(["domain", sect_conf["id_provider"], sect_conf["auth_provider"]]).run != :ok
                                return :cancel
                            end
                        end
                        return :ok
                    when :cancel
                        return :cancel
                    end
                end
            end
    end
end
