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
            enroll_frame = VBox(
                    Left(Label(_('Enter AD user credentials (e.g. Administrator) to enroll or re-enroll this computer:'))),
                    InputField(Id(:username), Opt(:hstretch), _('Username'), AuthConfInst.ad_user),
                    Password(Id(:password), Opt(:hstretch), _('Password'), AuthConfInst.ad_pass),
                    CheckBox(Id(:update_dns), Opt(:hstretch), _('Update AD\'s DNS records as well'), AuthConfInst.ad_update_dns),
                    InputField(Id(:orgunit), Opt(:hstretch), _('Optional Organisation Unit such as "Headquarter/HR/BuildingA"'), AuthConfInst.ad_ou),
                    Left(CheckBox(Id(:overwrite_smb_conf), _('Overwrite Samba configuration to work with this AD'), AuthConfInst.ad_overwrite_smb_conf)),
            )
            ad_entry = ''
            if AuthConfInst.autoyast_editor_mode
                ad_entry = _('(Not applicable in AutoYast editor)')
            elsif ad_discovered
                ad_entry = @ad_server + _(' (Auto-discovered via DNS)')
            elsif @ad_server.to_s != ''
                ad_entry = @ad_server
            else
                ad_entry = _('(DNS error)')
                enroll_frame = Label(_("The name resolution service on this computer does not satisfy AD enrollment requirements.\n" +
                                       "Please configure your network environment to use AD server as the name resolver."))
            end
            enrollment_status = _('(Not applicable in AutoYast editor)')
            if !AuthConfInst.autoyast_editor_mode
                if @ad_server != '' && ad_enrolled && kerberos_ready
                    enrollment_status = _('Already enrolled')
                else
                    enrollment_status = _('Not yet enrolled')
                end
            end
            UI.ReplaceWidget(Id(:status),
                VBox(MinHeight(10,
                    Table(
                        Opt(:keepSorting),
                        Header(_('Name'), _('Value')),
                        [
                            Item('Active Directory Server', ad_entry),
                            Item('Active Directory Domain', @ad_domain),
                            Item('Workgroup', @workgroup_name),
                            Item('Enrollment Status', enrollment_status)
                        ]
                    )
                ))
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

        def finish_handler
            username = UI.QueryWidget(Id(:username), :Value)
            orgunit = UI.QueryWidget(Id(:orgunit), :Value)
            password = UI.QueryWidget(Id(:password), :Value)
            overwrite_smb_conf = UI.QueryWidget(Id(:overwrite_smb_conf), :Value)

            if !username.nil? && username != '' || !password.nil? && password != '' || !orgunit.nil? && orgunit != ''
                # Enroll the computer, or save the enrollment details
                if username == '' || password == ''
                    Popup.Error(_('Please enter both username and password.'))
                    return
                end
                # join_ad will configure and apply Kerberos and then join AD
                AuthConfInst.ad_domain = @ad_domain
                AuthConfInst.ad_user = username
                AuthConfInst.ad_ou = orgunit
                AuthConfInst.ad_pass = password
                AuthConfInst.ad_update_dns = UI.QueryWidget(Id(:update_dns), :Value)
                AuthConfInst.ad_overwrite_smb_conf = overwrite_smb_conf
                if AuthConfInst.autoyast_editor_mode
                    Popup.Message(_('AD enrollment details have been saved for AutoYast. Please keep in mind that AD user password is saved in plain text.'))
                    finish_dialog(:finish)
                    return
                end
                success, output = AuthConfInst.ad_join_domain
                if success
                    Popup.LongMessage(_("Enrollment has completed successfully!\n\nCommand output:\n") + output)
                    # If user enters this dialog once again, the details should be cleared.
                    AuthConfInst.ad_user = ''
                    AuthConfInst.ad_ou = ''
                    AuthConfInst.ad_pass = ''
                    finish_dialog(:finish)
                    return
                else
                    Popup.LongMessage(_("The enrollment process failed.\n\nCommand output:\n") + output)
                    return
                end
            end
            finish_dialog(:finish)
        end
    end
end
