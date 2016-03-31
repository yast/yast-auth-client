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
Yast.import 'Icon'
Yast.import 'Label'

module SSSD
    # Manage AD membership
    class ManageADDialog < UI::Dialog
        include Yast
        include Auth
        include UIShortcuts
        include I18n
        include Logger

        def initialize
            super()
            textdomain "auth-client"
        end

        def create_dialog
            return false unless super
            render_status
            return true
        end

        def dialog_options
            Opt(:decorated)
        end

        def render_status
            @ad_domain = AuthConfInst.sssd_conf[UIData.instance.get_curr_section]['ad_domain']
            @ad_domain = UIData.instance.get_curr_section.gsub(/^domain\//, '') if !@ad_domain
            @workgroup_name = AuthConfInst.ad_get_workgroup_name(@ad_domain)
            ad_enrolled, kerberos_ready = AuthConfInst.ad_get_membership_status(@ad_domain)
            # AD server is very tricky
            ad_discovered = false
            @ad_server = AuthConfInst.sssd_conf[UIData.instance.get_curr_section]['ad_server']
            if @ad_server.to_s == ''
                @ad_server = AuthConfInst.ad_find_pdc(@ad_domain)
                if @ad_server != ''
                    ad_discovered = true
                end
            end
            # The frame is shown only if AD server can be discovered or is explicitly specified
            # The frame is hidden if the module is not running in autoyast mode and AD server is not found/specified
            enroll_caption = _('Enroll')
            if AuthConfInst.autoyast_editor_mode
                enroll_caption = _('Save Enrollment Details')
            end
            enroll_frame = Frame(_('Enroll or re-enroll this computer'),
                VBox(
                    Left(Label(_('Enter credentials of an AD user who is eligible to enroll the computer, such as Administrator:'))),
                    InputField(Id(:username), Opt(:hstretch), _('Username'), AuthConfInst.ad_user),
                    InputField(Id(:orgunit), Opt(:hstretch), _('Organisation Unit (e.g. Server/Computer/Finance. Leave empty for default)'), AuthConfInst.ad_ou),
                    Password(Id(:password), Opt(:hstretch), _('Password'), AuthConfInst.ad_pass),
                    Left(CheckBox(Id(:overwrite_smb_conf), _('Overwrite Samba configuration to work with this AD'), AuthConfInst.ad_overwrite_smb_conf)),
                    PushButton(Id(:enroll), enroll_caption),
                ),
            )
            ad_entry = Empty()
            if AuthConfInst.autoyast_editor_mode
                ad_entry = Label(_('(Not applicable in AutoYast editor)'))
            elsif ad_discovered
                ad_entry = Label(@ad_server + _(' (Auto-discovered via DNS)'))
            elsif @ad_server.to_s != ''
                ad_entry = Label(@ad_server)
            else
                ad_entry = Label(_('The server is not specified in configuration and cannot be found via DNS'))
                enroll_frame = Label(_("The name resolution service on this computer does not satisfy AD enrollment requirements.\n" +
                                       "Please configure your network environment to use AD server as the name resolver."))
            end
            status_widget = Empty()
            if !AuthConfInst.autoyast_editor_mode
                if @ad_server != '' && ad_enrolled && kerberos_ready
                    status_widget = Left(Label(Id(:enroll_status), _('The host has successfully enrolled at AD.')))
                else
                    status_widget = Left(Label(Id(:enroll_status), _('The host is not enrolled at AD yet.')))
                end
            end
            UI.ReplaceWidget(Id(:status),
                VBox(
                        Left(HBox(Label(Opt(:hstretch), _('Active directory server:')), ad_entry)),
                        Left(HBox(Label(Opt(:hstretch), _('Active directory domain name:')), Label(@ad_domain))),
                        Left(HBox(Label(Opt(:hstretch), _('Workgroup name:')), Label(@workgroup_name))),
                        status_widget,
                )
            )
            UI.ReplaceWidget(Id(:enroll_frame), enroll_frame)
            UI.RecalcLayout
        end
        
        def dialog_content
            MinWidth(80, VBox(
                Left(Heading(_('Active Directory enrollment'))),
                VSpacing(1),
                Frame(_('Current status'), ReplacePoint(Id(:status), Label(Opt(:hstretch), _('Gathering status...')))),
                VSpacing(1),
                ReplacePoint(Id(:enroll_frame), Empty()),
                ButtonBox(
                    PushButton(Id(:finish), Label.OKButton),
                ),
            ))
        end

        # Enroll this computer at AD.
        def enroll_handler
            username = UI.QueryWidget(Id(:username), :Value)
            orgunit = UI.QueryWidget(Id(:orgunit), :Value)
            password = UI.QueryWidget(Id(:password), :Value)
            overwrite_smb_conf = UI.QueryWidget(Id(:overwrite_smb_conf), :Value)
            if username == '' || password == ''
                Popup.Error(_('Please enter both username and password.'))
                return
            end
            # join_ad will configure and apply Kerberos and then join AD
            AuthConfInst.ad_domain = @ad_domain
            AuthConfInst.ad_user = username
            AuthConfInst.ad_ou = orgunit
            AuthConfInst.ad_pass = password
            AuthConfInst.ad_overwrite_smb_conf = overwrite_smb_conf
            if AuthConfInst.autoyast_editor_mode
                Popup.Message(_('AD enrollment details have been saved for AutoYast. Please keep in mind that AD user password is saved in plain text.'))
                return
            end
            success, output = AuthConfInst.ad_join_domain
            if success
                Popup.LongMessage(_("Enrollment has completed successfully!\n\nCommand output:\n") + output)
                render_status
            else
                Popup.LongMessage(_("The enrollment process failed.\n\nCommand output:\n") + output)
            end
        end

        # Close the dialog
        def finish_handler
            finish_dialog(:finish)
        end
    end
end
