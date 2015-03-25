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
require "yauthclient/new_section_dialog.rb"
require "yauthclient/edit_param_dialog.rb"
Yast.import "AuthClient"

module YAuthClient
    # Main dialog is split into overview on left side, and config editor on right side.
    class MainDialog
        include Yast::UIShortcuts
        include Yast::I18n
        include Yast::Logger

        def initialize
            textdomain "auth-client"
        end

        def run
            log.info "AuthClient.read? " + Yast::AuthClient.Read.to_s
            return if !pre_check
            return if !render_all
            begin
                return ui_event_loop
            ensure
                Yast::UI.CloseDialog()
            end
        end

        private
            # Render overview and edit buttons on left side, config editor on right side.
            def render_all
                Yast::UI.OpenDialog(
                    Opt(:decorated, :defaultsize),
                    VBox(
                        Left(HBox(
                            Yast::Icon::Simple("yast-nis"),
                            Heading(_("Authentication Client Config"))
                        )),
                        HBox(
                            # Overview of all config sections
                            HWeight(35, VBox(
                                Tree(Id(:section_tree), Opt(:immediate), "Sections", []),
                                CheckBox(Id(:mkhomedir), Opt(:notify),
                                    _("Create Home Directory on Login"), 
                                    Yast::AuthClient.auth["mkhomedir"]),
                                HBox(
                                    PushButton(Id(:new_sec), _("New Section")),
                                    PushButton(Id(:del_sec), _("Delete Section"))
                                )
                            )),
                            # Config editor
                            HWeight(65, VBox(
                                ReplacePoint(Id(:section_conf), Empty()),
                                ReplacePoint(Id(:list_more_params), Empty())
                            ))
                        ),
                        # Footer
                        ButtonBox(
                            PushButton(Id(:ok), Yast::Label.OKButton),
                            PushButton(Id(:cancel), Yast::Label.CancelButton)
                        )
                    )
                )
                render_section_tree
                render_section_conf
                render_list_more_params
            end

            # Render overview of all config sections in tree.
            def render_section_tree
                tree = [
                    Item("sssd"),
                    Item("Services", true, UIData.instance.get_all_services),
                    Item("Domains", true, UIData.instance.get_all_domains)
                ]
                Yast::UI.ChangeWidget(Id(:section_tree), :Items, tree)
                Yast::UI.ChangeWidget(Id(:section_tree), :CurrentItem, UIData.instance.get_curr_section)
            end

            # For the currently selection config section, render customised parameters and values in a table.
            def render_section_conf
                Yast::UI.ReplaceWidget(Id(:section_conf), VBox(
                    Left(Label(Opt(:boldFont), _("Customisation - %s" % UIData.instance.get_curr_section))),
                    HBox(
                        Table(
                            Id(:conf_table),
                            Header(_("Name"), _("Value"), _("Description")),
                            UIData.instance.get_section_conf.map { |detail|
                                # Display a brief of parameter description
                                desc = detail[2].lines[0]
                                desc = desc && desc.strip || ""
                                Item(detail[0], detail[1], desc.length > 60 && desc[0..59] + "..." || desc)
                            }
                        ),
                        PushButton(Id(:edit_param), Yast::Label.EditButton),
                    )
                ))
            end

            # For the currently selected config section, render list of additional parameters for customisation.
            def render_list_more_params
                Yast::UI.ReplaceWidget(Id(:list_more_params), VBox(
                    Left(Label(Opt(:boldFont), _("More Parameters"))),
                    HBox(
                        VBox(
                            HBox(
                                Label(_("Name filter:")),
                                InputField(Id(:param_filter), Opt(:hstretch, :notify), "")
                            ),
                            Table(
                                Id(:more_param_table),
                                Header(_("Name"), _("Description")),
                                []
                            ),
                        ),
                        PushButton(Id(:add_param), Yast::Label.SelectButton)
                    )
                ))
                render_table_more_params("") # populate parameter table without filter
            end

            # Render the table of parameter name and description.
            def render_table_more_params(filter_val)
                Yast::UI.ChangeWidget(Id(:more_param_table), :Items,
                    UIData.instance.get_section_params_with_filter(filter_val).map { |name, detail|
                            # Display a brief of parameter description
                            desc = detail["desc"].lines[0]
                            desc = desc && desc.strip || ""
                            Item(name, desc.length > 60 && desc[0..59] + "..." || desc)
                    }
                )
            end

            # Check system environment for the proper operation of SSSD
            def pre_check
                if Yast::AuthClient.auth["nssldap"] && ! Mode.autoinst
                    if ! Popup.YesNo(
                        _( "Your system is configured for using nss_ldap.\n" +
                        "This module is designed to configure your system via sssd.\n" +
                        "If you continue, your nss_ldap configuration will be removed.\n" +
                        "Do you want to continue?" )
                        )
                        return false
                    end
                end
                if Yast::AuthClient.auth["oes"] && ! Mode.autoinst
                    if ! Popup.YesNo(
                        _( "Your system is configured as OES client.\n" +
                        "This module is designed to configure your system via sssd.\n" +
                        "If you continue, your OES client configuration will be deactivated.\n" +
                        "Do you want to continue?" )
                        )
                        return false
                    end
                end
                Yast::AuthClient.auth["sssd"]    = true;
                Yast::AuthClient.auth["nssldap"] = false;
                Yast::AuthClient.auth["oes"]     = false;
                if ! Yast::AuthClient.auth.has_key?("sssd_conf")
                    Yast::AuthClient.CreateBasicSSSD
                end
                return true
            end

            def ui_event_loop
                loop do
                    case Yast::UI.UserInput
                    # Left side
                    when :section_tree
                        # Choose a new section to configure
                        choice = Yast::UI.QueryWidget(Id(:section_tree), :CurrentItem)
                        if choice == "Services" || choice == "Domains"
                            UIData.instance.switch_section("")
                        else
                            UIData.instance.switch_section(choice)
                        end
                        # Re-render the customisation screen on the right side
                        render_section_conf
                        render_list_more_params

                    when :new_sec
                        # Create a new section (domain or service)
                        result = NewSectionDialog.new.run
                        if result != :cancel
                            # Re-render to display the new section
                            UIData.instance.switch_section(result)
                            render_section_tree
                            render_section_conf
                            render_list_more_params
                        end

                    when :del_sec
                        # Delete the chosen section (domain or service)
                        sect_name = UIData.instance.get_curr_section
                        if sect_name == "sssd"
                            Yast::Popup.Error(_("You may not delete section SSSD."))
                            redo
                        elsif !Yast::Popup.YesNo(_("Do you really wish to delete section %s?" % sect_name))
                            redo
                        end
                        if sect_name.include? "domain/"
                            # Remove domain - the section name has prefix 'domain/'
                            UIData.instance.get_conf.delete(sect_name)
                            # Domain names in parameter "domains" do not use prefix
                            sect_name = sect_name.sub("domain/", "")
                            UIData.instance.get_conf["sssd"]["domains"] = UIData.instance.get_enabled_domains.delete_if { |d| d == sect_name }.join(",")
                        else
                            # Remove service
                            UIData.instance.get_conf.delete(sect_name)
                            UIData.instance.get_conf["sssd"]["services"] = UIData.instance.get_enabled_services.delete_if { |d| d == sect_name }.join(",")
                        end
                        # Re-render to display section SSSD
                        UIData.instance.switch_section("sssd")
                        render_section_tree
                        render_section_conf
                        render_list_more_params

                    when :mkhomedir
                        # Change the create-home-directory-on-login settings
                        Yast::AuthClient.auth["mkhomedir"] = Yast::UI.QueryWidget(Id(:mkhomedir), :Value)
                        
                    # Right side
                    when :edit_param
                        # Edit the value of chosen parameter
                        param_name = Yast::UI.QueryWidget(Id(:conf_table), :CurrentItem)
                        if param_name == nil
                            redo
                        end
                        if EditParamDialog.new(param_name).run == :ok
                            UIData.instance.reload_section
                            render_section_conf
                        end

                    when :param_filter
                        # Reload parameter table according to the filter
                        filter_val = Yast::UI.QueryWidget(Id(:param_filter), :Value)
                        render_table_more_params(filter_val)

                    when :add_param
                        # Customise value of the parameter
                        param_name = Yast::UI.QueryWidget(Id(:more_param_table), :CurrentItem)
                        if param_name == nil
                            redo
                        end
                        if EditParamDialog.new(param_name).run == :ok
                            UIData.instance.reload_section
                            render_section_conf
                            render_list_more_params
                        end

                    # Bottom
                    when :ok
                        # Save settings - validate
                        if UIData.instance.get_enabled_domains == [] && !Yast::Popup.ContinueCancelHeadline(
                            _("No domain enabled"),
                            _("No domain has been enabled in [sssd] \"domains\" parameter.\n" +
                              "SSSD will not start, and only local authentication will be available.\n" +
                              "Do you still wish to proceed?"))
                            redo
                        end
                        all_domains = UIData.instance.get_all_domains.map { |d| d.sub("domain/", "") }
                        misspelt_names = UIData.instance.get_enabled_domains - all_domains
                        if misspelt_names != []
                            Yast::Popup.Error(
                                "Certain domains mentioned in [sssd] \"domains\" aprameter do not have " + 
                                "configuration:\n%s\n\n" % misspelt_names.join(", ") +
                                "This could be a spelling mistake. SSSD will not start in this configuration.\n" +
                                "Note that domain names are case sensitive. Please correct the parameter value.")
                            redo # user must correct the mistake
                        end 
                        disabled_domains = all_domains - UIData.instance.get_enabled_domains
                        if disabled_domains != [] && !Yast::Popup.ContinueCancelHeadline(
                            _("Inactive domain(s) found"),
                            "Certain configured domains are not enabled in [sssd] \"domains\" parameter:\n" +
                            "%s\n\n" % disabled_domains.join(", ") +
                            "Domains will not work unless explicitly mentioned in the parameter.\n" +
                            "Do you still wish to proceed?")
                            redo
                        end
                        Yast::AuthClient.Write
                        break
                    when :cancel
                        # Discard settings and quit
                        break
                    end
                end
            end
    end
end
