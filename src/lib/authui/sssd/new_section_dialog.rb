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
require "authui/sssd/initial_customisation_dialog.rb"

module SSSD
    # Create a new domain section.
    class NewSectionDialog
        include Yast
        include Auth
        include UIShortcuts
        include I18n
        include Logger

        def initialize
            textdomain "auth-client"
            # ID provider to UI caption mapping and reversed mapping
            @id_provider_caption = {
                "proxy" => _("Delegate to third-party software library (proxy_lib_name)"),
                "local"=> _("Local SSSD file database"),
                "ad"=> _("Microsoft Active Directory"),
                "ipa"=> _("FreeIPA"),
                "ldap"=> _("Generic directory service (LDAP)"),
            }
            @id_caption_provider = Hash[*@id_provider_caption.map { |name, caption| [caption, name] }.flatten]

            @auth_provider_caption = {
                "ldap"=> _("Generic directory service (LDAP)"),
                "krb5"=> _("Generic Kerberos service"),
                "ipa"=> _("FreeIPA"),
                "ad"=> _("Microsoft Active Directory"),
                "proxy"=> _("Delegate to third-party software library (proxy_lib_name)"),
                "local"=> _("Local SSSD file database"),
                "none"=> _("The domain does not provide authentication service"),
            }
            @auth_caption_provider = Hash[*@auth_provider_caption.map { |name, caption| [caption, name] }.flatten]
        end

        # Return name of the new section if it was created. :cancel otherwise.
        def run
            return if !render_all
            begin
                return ui_event_loop # return string or :cancel
            ensure
                UI.CloseDialog()
            end
        end

    private

            # Render input box and dropdowns for service/domain creation
            def render_all
                UI.OpenDialog(
                    VBox(
                        # New domain and provider types
                        Id(:section_dom),
                        InputField(Id(:dom_name), Opt(:hstretch), _("Domain name (such as example.com):"), ""),
                        SelectionBox(
                            Id(:id_provider),
                            _("Which service provides identity data, such as user names and group memberships?"),
                            @id_caption_provider.keys.sort
                        ),
                        SelectionBox(
                            Id(:auth_provider),
                            _("Which service handles user authentication?"),
                            @auth_caption_provider.keys.sort
                        ),
                        Left(CheckBox(Id(:activate), _("Enable the domain"), true)),
                        ButtonBox(
                            PushButton(Id(:ok), Label.OKButton),
                            PushButton(Id(:cancel), Label.CancelButton)
                        )
                    )
                )
            end

            # Switch to new section and return :ok if section was created, or :cancel otherwise.
            def ui_event_loop
                loop do
                    case UI.UserInput
                    when :ok
                        # Create new domain
                        sect_name = UI.QueryWidget(Id(:dom_name), :Value).to_s.strip
                        id_provider = @id_caption_provider[UI.QueryWidget(Id(:id_provider), :Value)]
                        auth_provider = @auth_caption_provider[UI.QueryWidget(Id(:auth_provider), :Value)]
                        activate_dom = UI.QueryWidget(Id(:activate), :Value)
                        if sect_name == ""
                            Popup.Error(_("Please enter the domain name."))
                            redo
                        elsif ["sssd", "nss", "pam", "pac", "ssh", "autofs"].include?(sect_name)
                            Popup.Error(_("The domain name collides with a reserved keyword. Please choose a different name."))
                            redo
                        elsif AuthConfInst.sssd_get_domains.include?(sect_name)
                            Popup.Error(_("The domain name is already in-use."))
                            redo
                        end
                        # Activate the new domain in SSSD daemon config
                        if activate_dom
                            AuthConfInst.sssd_conf["sssd"]["domains"] += [sect_name]
                        end
                        # Create config in domain section
                        sect_conf = AuthConfInst.sssd_conf.fetch(sect_name, {})
                        sect_conf["id_provider"] = id_provider
                        sect_conf["auth_provider"] = auth_provider
                        if id_provider == "ldap" && sect_conf["ldap_schema"].nil?
                            sect_conf["ldap_schema"] = "rfc2307bis"
                        end
                        # Swtich to this new section
                        AuthConfInst.sssd_conf['domain/' + sect_name] = sect_conf
                        UIData.instance.switch_section('domain/' + sect_name)
                        # Instruct user to create initial customisation
                        if InitialCustomisationDialog.new(["domain", id_provider, auth_provider]).run != :ok
                            # Revert changes
                            AuthConfInst.sssd_conf["sssd"]["domains"] -= [sect_name]
                            AuthConfInst.sssd_conf.delete('domain/' + sect_name)
                            return :cancel
                        end
                        return :ok
                    when :cancel
                        return :cancel
                    end
                end
            end
    end
end
