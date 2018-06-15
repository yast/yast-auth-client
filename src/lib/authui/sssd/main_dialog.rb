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
require "authui/sssd/new_section_dialog.rb"
require "authui/sssd/manage_ad_dialog.rb"
require "authui/sssd/edit_param_dialog.rb"
require "authui/sssd/extended_param_dialog.rb"

module SSSD
    # Main dialog is split into overview on left side, and config editor on right side.
    class MainDialog
        include Yast
        include Auth
        include UIShortcuts
        include I18n
        include Logger

        def initialize
            textdomain "auth-client"
            # SSSD section name to UI caption mapping
            @sect_name_caption = {
                "sssd" => _("Global Options"), "nss" => _("Name switch"),
                "pam" => _("Authentication"), "sudo" => _("Sudo"),
                "autofs" => _("Auto-Mount"), "ssh" => _("SSH Public Keys"),
                "pac" => _("Privilege Account Certificate (MS-PAC)"),
            }
            # The reverse caption mapping
            @sect_caption_name = Hash[*@sect_name_caption.map { |name, caption| [caption, name] }.flatten]
        end

        def run
            return if !render_all
            begin
                return ui_event_loop
            ensure
                UI.CloseDialog()
            end
        end

    private

            # Render overview and edit buttons on left side, config editor on right side.
            def render_all
                UI.OpenDialog(
                    Opt(:decorated, :defaultsize),
                    VBox(
                        Left(HBox(
                            Icon::Simple("yast-nis"),
                            Heading(_("Manage Domain User Logon"))
                        )),
                        HBox(
                            # Overview of all config sections
                            HWeight(50, VBox(
                                Frame(
                                    _(""),
                                    VBox(
                                        Left(HBox(Label(_("Daemon Status: ")), Label(Service.Active("sssd") ? _("Running") : _("Stopped")))),
                                        Left(CheckBox(Id(:enable_daemon_pam), Opt(:notify), _("Allow Domain User Logon"), AuthConfInst.sssd_enabled && AuthConfInst.sssd_pam)),
                                        Left(CheckBox(Id(:mkhomedir_enable), _('Create Home Directory'), AuthConfInst.mkhomedir_pam)),
                                        VSpacing(0.2),
                                        Left(Label(_("Enable domain data source:"))),
                                        Left(CheckBox(Id(:nss_passwd), Opt(:notify), _("Users"), AuthConfInst.sssd_nss.include?('passwd'))),
                                        Left(CheckBox(Id(:nss_group), Opt(:notify), _("Groups"), AuthConfInst.sssd_nss.include?('group'))),
                                        Left(CheckBox(Id(:nss_sudoers), Opt(:notify), _("Super-User Commands (sudo)"), AuthConfInst.sssd_nss.include?('sudoers'))),
                                        Left(CheckBox(Id(:nss_automount), Opt(:notify), _("Map Network Drives (automount)"), AuthConfInst.sssd_nss.include?('automount'))),
                                        Left(CheckBox(Id(:svc_ssh), Opt(:notify), _("SSH Public Keys"), AuthConfInst.sssd_conf['sssd']['services'].include?('ssh'))),
                                        Left(CheckBox(Id(:svc_pac), Opt(:notify), _("Privilege Account Certificate (MS-PAC)"), AuthConfInst.sssd_conf['sssd']['services'].include?('pac'))),
                                    )
                                ),
                                VSpacing(0.2),
                                Tree(Id(:section_tree), Opt(:immediate), "", []),
                                Left(HBox(
                                    PushButton(Id(:new_domain), _("Add Domain")),
                                    PushButton(Id(:del_domain), _("Leave Domain")),
                                    PushButton(Id(:clear_cache), _("Clear Domain Cache"))
                                )),
                            )),
                            # Config editor
                            HWeight(50, VBox(
                                ReplacePoint(Id(:section_conf), Empty())
                            ))
                        ),
                        # Footer
                        ButtonBox(
                            PushButton(Id(:ok), Label.OKButton),
                            PushButton(Id(:cancel), Label.CancelButton)
                        )
                    )
                )
                render_section_tree
                render_section_conf

            end

            # Get the SSSD configuration section name from the chosen entry in section tree
            def get_config_sect_name
                chosen_sect = UI.QueryWidget(Id(:section_tree), :CurrentItem)
                # The chosen item could be a translated caption
                caption_to_name = @sect_caption_name[chosen_sect]
                caption_to_name = chosen_sect if !caption_to_name
                if AuthConfInst.sssd_conf["domain/" + caption_to_name]
                    # Or it could be a domain section but missing the domain/ prefix
                    return "domain/" + caption_to_name
                end
                return caption_to_name
            end

            # Set the chosen entry in section tree according to UIData.instance.get_curr_section
            def set_config_sect_name
                sect_name = UIData.instance.get_curr_section.gsub(/^domain\//, "")
                display_name = @sect_name_caption[sect_name]
                display_name = sect_name if !display_name
                UI.ChangeWidget(Id(:section_tree), :CurrentItem, display_name)
            end

            # Render overview of all config sections in tree.
            def render_section_tree
                tree = [
                  Item(@sect_name_caption["sssd"]),
                  Item(_("Service Options"), true, (AuthConfInst.sssd_conf['sssd']['services']).map {|svc| @sect_name_caption[svc]}),
                  Item(_("Domain Options"), true, AuthConfInst.sssd_get_domains)
                ]
                UI.ChangeWidget(Id(:section_tree), :Items, tree)
                set_config_sect_name
            end

            # For the currently selection config section, render customised parameters and values in a table.
            def render_section_conf
                content = nil
                sect_name = get_config_sect_name
                case sect_name
                    when _("Service Options"), _("Domain Options")
                        content = VBox(Label(Opt(:boldFont), _("Select Global Options, a service, or a domain to customise.")))
                    else
                        # Additional widgets for a domain
                        domain_additions = [Empty()]
                        if /^domain\//.match(sect_name)
                            enabled = AuthConfInst.sssd_conf["sssd"]["domains"].include?(sect_name.gsub(/^domain\//, ''))
                            domain_additions = [CheckBox(Id(:enable_domain), Opt(:notify), _("Use this domain"), enabled)]
                            # Additiona widgets for an AD domain
                            if AuthConfInst.sssd_conf[sect_name]["id_provider"] == "ad" || AuthConfInst.sssd_conf[sect_name]["auth_provider"] == "ad"
                                domain_additions += [
                                    HSpacing(1.0),
                                    PushButton(Id(:manage_ad_domain), _("Enroll to Active Directory"))
                                ]
                            end
                        end
                        # Common widgets
                        caption = @sect_name_caption[sect_name]
                        caption = sect_name if !caption
                        content = VBox(
                            # TRANSLATORS: Label of the area used to customise parameters.
                            # %s is the name of the section being customised.
                            Left(Label(Opt(:boldFont), _("Options - %s") % caption)),
                            Left(HBox(*domain_additions)),
                            HBox(
                                Table(
                                    Id(:conf_table),
                                    Header(_("Name"), _("Value")),
                                    UIData.instance.get_section_conf.map { |detail|
                                        Item(detail[0], detail[1])
                                    }
                                )
                            ),
                            Left(HBox(
                                PushButton(Id(:edit_param), Label.EditButton),
                                PushButton(Id(:del_param), Label.DeleteButton),
                                PushButton(Id(:extended_opts), _('Extended Options')),
                            )),
                        )
                end
                UI.ReplaceWidget(Id(:section_conf), content)
            end

            def ui_event_loop
                loop do
                    case UI.UserInput
                    # Left side
                    when :section_tree
                        # Choose a new section to configure
                        sect_name = get_config_sect_name
                        UIData.instance.switch_section(sect_name)
                        # Re-render the customisation screen on the right side
                        render_section_conf

                    when :new_domain
                        # Create a new domain
                        result = NewSectionDialog.new.run
                        if result != :cancel
                            # Re-render to display the new section
                            render_section_tree
                            render_section_conf
                        end

                    when :del_domain
                        # Delete the chosen domain
                        sect_name = get_config_sect_name
                        if !/^domain\//.match(sect_name)
                            Popup.Error(_("Please select a domain among the list."))
                            redo
                        end
                        if !Popup.YesNo(_("Do you really wish to erase configuration for domain %s?") % sect_name)
                            redo
                        end
                        AuthConfInst.sssd_conf.delete(sect_name)
                        AuthConfInst.sssd_conf['sssd']['domains'].delete_if{|a| a == sect_name.sub(/^domain\//, '')}

                        # Re-render to display default section SSSD
                        UIData.instance.switch_section('sssd')
                        render_section_tree
                        render_section_conf

                    when :enable_domain
                        # Enable/disable domain
                        enabled = UI.QueryWidget(Id(:enable_domain), :Value)
                        domain_name = get_config_sect_name.sub(/^domain\//, '')
                        all_domains = AuthConfInst.sssd_conf['sssd']['domains']
                        if enabled
                            AuthConfInst.sssd_conf['sssd']['domains']  = all_domains + [domain_name] if !all_domains.include?(domain_name)
                        else
                            AuthConfInst.sssd_conf['sssd']['domains'].delete_if{ |dom| dom == domain_name}
                        end

                    when :manage_ad_domain
                        # Show AD membership management dialog
                        ManageADDialog.new.run

                    when :enable_daemon_pam
                        # Enable/disable SSSD daemon
                        AuthConfInst.sssd_enabled = UI.QueryWidget(Id(:enable_daemon_pam), :Value)
                        AuthConfInst.sssd_pam = AuthConfInst.sssd_enabled
                        all_nss_options = [:nss_passwd, :nss_group, :nss_sudoers, :nss_automount]
                        if AuthConfInst.sssd_enabled
                            if AuthConfInst.ldap_pam || AuthConfInst.krb_pam
                                Popup.Error(_("This computer is currently using legacy LDAP or Kerberos method to authenticate users.\n" +
                                              "Before you may use SSSD to authenticate users, please disable LDAP and Kerberos authentication from \"LDAP and Kerberos Client\"."))
                                UI.ChangeWidget(Id(:enable_daemon_pam), :Value, false)
                                AuthConfInst.sssd_enabled = false
                                AuthConfInst.sssd_pam = false
                                redo
                            end
                            nss_all_disabled = !(all_nss_options.any? { |checkbox| UI.QueryWidget(Id(checkbox), :Value)})
                            if nss_all_disabled
                                # Enable PAM and NSS as courtesy default
                                UI.ChangeWidget(Id(:nss_passwd), :Value, true)
                                UI.ChangeWidget(Id(:nss_group), :Value, true)
                                AuthConfInst.sssd_nss = (AuthConfInst.sssd_nss + ['passwd', 'group']).uniq
                                AuthConfInst.sssd_pam = true
                                AuthConfInst.sssd_enable_svc('pam')
                                AuthConfInst.sssd_enable_svc('nss')
                            end
                        else
                            # Disable all options
                            all_nss_options.each { |checkbox| UI.ChangeWidget(Id(checkbox), :Value, false) }
                            [:svc_ssh, :svc_pac].each { |checkbox| UI.ChangeWidget(Id(checkbox), :Value, false) }
                            AuthConfInst.sssd_nss = []
                            AuthConfInst.sssd_disable_svc('pam')
                            AuthConfInst.sssd_disable_svc('nss')
                        end
                        render_section_tree

                    when :nss_passwd
                        # Enable/disable NSS password database
                        enable = UI.QueryWidget(Id(:nss_passwd), :Value)
                        if enable
                            if AuthConfInst.ldap_nss.include?('passwd')
                                Popup.Error(_("This computer is currently reading user database from LDAP identity provider.\n" +
                                              "Before you may use SSSD user database, please disable LDAP user database from \"LDAP and Kerberos Client\"."))
                                UI.ChangeWidget(Id(:nss_passwd), :Value, false)
                                redo
                            end
                            AuthConfInst.sssd_nss += ['passwd'] if !AuthConfInst.sssd_nss.include?('passwd')
                            AuthConfInst.sssd_enable_svc('nss')
                        else
                            AuthConfInst.sssd_nss.delete_if{ |n| n == 'passwd'}
                            AuthConfInst.sssd_disable_svc('nss') if AuthConfInst.sssd_nss.empty?
                        end
                        render_section_tree

                    when :nss_group
                        # Enable/disable NSS group database
                        enable = UI.QueryWidget(Id(:nss_group), :Value)
                        if enable
                            if AuthConfInst.ldap_nss.include?('group')
                                Popup.Error(_("This computer is currently reading group database from LDAP identity provider.\n" +
                                              "Before you may use SSSD group database, please disable LDAP group database from \"LDAP and Kerberos Client\"."))
                                UI.ChangeWidget(Id(:nss_group), :Value, false)
                                redo
                            end
                            AuthConfInst.sssd_nss += ['group'] if !AuthConfInst.sssd_nss.include?('group')
                            AuthConfInst.sssd_enable_svc('nss')
                        else
                            AuthConfInst.sssd_nss.delete_if{ |n| n == 'group'}
                            AuthConfInst.sssd_disable_svc('nss') if AuthConfInst.sssd_nss.empty?
                        end
                        render_section_tree

                    when :nss_sudoers
                        # Enable/disable NSS sudoers database
                        enable = UI.QueryWidget(Id(:nss_sudoers), :Value)
                        if enable
                            if AuthConfInst.ldap_nss.include?('sudoers')
                                Popup.Error(_("This computer is currently reading sudoers database from LDAP identity provider.\n" +
                                              "Before you may use SSSD sudoers database, please disable LDAP sudoers database from \"LDAP and Kerberos Client\"."))
                                UI.ChangeWidget(Id(:nss_sudoers), :Value, false)
                                redo
                            end
                            AuthConfInst.sssd_nss += ['sudoers'] if !AuthConfInst.sssd_nss.include?('sudoers')
                            AuthConfInst.sssd_enable_svc('nss')
                            AuthConfInst.sssd_enable_svc('sudo')
                            Popup.Message(_("Sudo data source has been globally enabled.\n" + 
                            "Please remember to also customise \"sudo_provider\" parameter in Extended Options of each individual domain that provides sudo data."))
                        else
                            AuthConfInst.sssd_nss.delete_if{ |n| n == 'sudoers' }
                            AuthConfInst.sssd_disable_svc('sudo')
                            AuthConfInst.sssd_disable_svc('nss') if AuthConfInst.sssd_nss.empty?
                        end
                        render_section_tree

                    when :nss_automount
                        # Enable/disable NSS automount database
                        enable = UI.QueryWidget(Id(:nss_automount), :Value)
                        if enable
                            if AuthConfInst.ldap_nss.include?('automount')
                                Popup.Error(_("This computer is currently reading automount database from LDAP identity provider.\n" +
                                              "Before you may use SSSD automount database, please disable LDAP automount database from \"LDAP and Kerberos Client\"."))
                                UI.ChangeWidget(Id(:nss_automount), :Value, false)
                                redo
                            end
                            AuthConfInst.sssd_nss += ['automount'] if !AuthConfInst.sssd_nss.include?('automount')
                            AuthConfInst.sssd_enable_svc('nss')
                            AuthConfInst.sssd_enable_svc('autofs')
                            Popup.Message(_("Automount data source has been globally enabled.\n" + 
                            "Please remember to also customise \"autofs_provider\" parameter in Extended Options of each individual domain that provides automount data."))
                        else
                            AuthConfInst.sssd_nss.delete_if{ |n| n == 'automount' }
                            AuthConfInst.sssd_disable_svc('autofs')
                            AuthConfInst.sssd_disable_svc('nss') if AuthConfInst.sssd_nss.empty?
                        end
                        AuthConfInst.autofs_enabled = enable
                        render_section_tree

                    when :svc_ssh
                        # Enable/disable SSH service
                        enable = UI.QueryWidget(Id(:svc_ssh), :Value)
                        if enable
                            AuthConfInst.sssd_enable_svc('ssh')
                        else
                            AuthConfInst.sssd_disable_svc('ssh')
                        end
                        render_section_tree

                    when :svc_pac
                        # Enable/disable PAC responder
                        enable = UI.QueryWidget(Id(:svc_pac), :Value)
                        if enable
                            Popup.Message(_("MS-PAC data source has been globally enabled.\n" + 
                            "This optional feature depends on the capabilities of your Microsoft Active Directory domain.\n" +
                            "SSSD may fail to start if Active Directory domain lacks the support, in which case please turn off this feature."))
                            AuthConfInst.sssd_enable_svc('pac')
                        else
                            AuthConfInst.sssd_disable_svc('pac')
                        end
                        render_section_tree

                    # Right side
                    when :edit_param
                        # Edit the value of chosen parameter
                        param_name = UI.QueryWidget(Id(:conf_table), :CurrentItem)
                        if param_name.nil?
                            redo
                        end
                        if EditParamDialog.new(param_name).run == :ok
                            render_section_conf
                        end

                    when :del_param
                        # Delete a parameter customisation
                        param_name = UI.QueryWidget(Id(:conf_table), :CurrentItem)
                        if param_name.nil?
                            redo
                        end
                        # Forbid removal of mandatory parameters
                        is_important = Params.instance.get_by_name(param_name)["important"]
                        if [
                          UIData.instance.get_curr_section,
                          UIData.instance.get_current_id_provider,
                          UIData.instance.get_current_auth_provider
                        ].any? { |param_category|
                            Params.instance.is_required?(param_category, param_name)
                        }
                            Popup.Error(_("This is a mandatory parameter and it may not be deleted."))
                            redo
                        end
                        # Warn against removal of important parameters
                        if is_important && !Popup.ContinueCancelHeadline(
                            _("Confirm parameter removal: ") + param_name,
                            _("The parameter is important. Removal of the parameter may cause configuration failure.\n" +
                              "Please consult SSSD manual page before moving on.\n" +
                              "Do you still wish to remove the parameter?"))
                            redo
                        end
                        AuthConfInst.sssd_conf[get_config_sect_name].delete(param_name)
                        UIData.instance.reload_section
                        render_section_conf

                    when :extended_opts
                        if ExtendedParamDialog.new(get_config_sect_name).run == :ok
                            UIData.instance.reload_section
                            render_section_conf
                        end

                    # Bottom
                    when :ok
                        # Save settings - validate
                        if AuthConfInst.sssd_conf['sssd']['domains'].empty? && AuthConfInst.sssd_enabled && !Popup.ContinueCancelHeadline(
                            _("No domain"),
                            _("You have not configured any authentication domain, yet you chose to enable domain authentication.\n" +
                              "SSSD will fail to start, and only local authentication will be available.\n" +
                              "Do you still wish to proceed?"))
                            redo
                        end
                        if AuthConfInst.sssd_enabled
                            AuthConfInst.nscd_enabled = false
                        end
                        AuthConfInst.mkhomedir_pam = UI.QueryWidget(Id(:mkhomedir_enable), :Value)
                        AuthConfInst.sssd_apply
                        AuthConfInst.aux_apply
                        break

                    when :cancel
                        # Discard settings and quit
                        break

                    when :clear_cache
                        # Remove all SSSD cache files
                        AuthConfInst.sssd_clear_cache
                        Popup.Message(_('All cached data have been erased.'))
                    end
                end
            end
    end
end
