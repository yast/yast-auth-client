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
require 'authui/ldapkrb/generic_input_dialog'
Yast.import 'UI'
Yast.import 'Icon'
Yast.import 'Label'

module LdapKrb
    # Edit Kerberos realm configuration
    class EditRealmDialog < UI::Dialog
        include Yast
        include Auth
        include UIShortcuts
        include I18n
        include Logger

        def initialize(realm_name)
            super()
            @realm_name = realm_name
            textdomain "auth-client"
        end

        def create_dialog
            return false unless super
            return true
        end

        def dialog_options
            Opt(:decorated)
        end

        def dialog_content
            VBox(
                InputField(Id(:realm_name), Opt(:hstretch), _('Realm name'), @realm_name.to_s),
                CheckBox(Id(:map_domain), Opt(:hstretch), _('Map Domain Name to the Realm (example.com -> EXAMPLE.COM)'),
                    !@realm_name.nil? && !AuthConfInst.krb_conf_get(['domain_realms', @realm_name.downcase], nil).nil?),
                CheckBox(Id(:map_wildcard_domain), Opt(:hstretch), _('Map Wild Card Domain Name to the Realm (*.example.com -> EXAMPLE.COM)'),
                    !@realm_name.nil? && !AuthConfInst.krb_conf_get(['domain_realms', ".#{@realm_name.downcase}"], nil).nil?),
                VSpacing(1.0),
                InputField(Id(:admin_server), Opt(:hstretch), _('Host Name of Administration Server (Optional)'),
                    AuthConfInst.krb_conf_get(['realms', @realm_name, 'admin_server'], '')),
                InputField(Id(:master_kdc), Opt(:hstretch), _('Host Name of Master Key Distribution Server (Optional)'),
                    AuthConfInst.krb_conf_get(['realms', @realm_name, 'master_kdc'], '')),
                SelectionBox(Id(:kdc), Opt(:hstretch), _('Key Distribution Centres (Optional If Auto-Discovery via DNS is Enabled)'),
                    AuthConfInst.krb_conf_get(['realms', @realm_name, 'kdc'], [])),
                Left(HBox(PushButton(Id(:kdc_add), Label.AddButton), PushButton(Id(:kdc_remove), Label.DeleteButton))),
                VSpacing(1.0),
                HBox(
                    VBox(
                        Left(Label(_('Custom Mappings of Principal Names to User Names'))),
                        Table(Id(:auth_to_local_names), Header(_('Principal Name'), _('User Name')),
                            AuthConfInst.krb_conf_get(['realms', @realm_name, 'auth_to_local_names'], []).map {|princ_name, user_name| Item(princ_name, user_name)}),
                        Left(HBox(PushButton(Id(:a2ln_add), Label.AddButton), PushButton(Id(:a2ln_remove), Label.DeleteButton))),
                    ),
                    VBox(
                        SelectionBox(Id(:auth_to_local), _('Custom Rules for Mapping Principal Names to User Names'),
                            AuthConfInst.krb_conf_get(['realms', @realm_name, 'auth_to_local'], [])),
                        Left(HBox(PushButton(Id(:a2l_add), Label.AddButton), PushButton(Id(:a2l_remove), Label.DeleteButton))),
                    )
                ),
                VSpacing(1.0),
                ButtonBox(
                    PushButton(Id(:ok), Label.OKButton),
                    PushButton(Id(:cancel), Label.CancelButton),
                )
            )
        end

        # Add a KDC
        def kdc_add_handler
            new_kdc = GenericInputDialog.new(_('Please type in the host name of Key Distribution Centre:'), '').run
            if !new_kdc.nil?
                UI.ChangeWidget(Id(:kdc), :Items, UI.QueryWidget(Id(:kdc), :Items) + [new_kdc])
            end
        end

        # Remove a KDC
        def kdc_remove_handler
            UI.ChangeWidget(Id(:kdc), :Items, UI.QueryWidget(Id(:kdc), :Items).map{|item| item[1]} - [UI.QueryWidget(Id(:kdc), :CurrentItem)])
        end

        # Add an auth_to_local
        def a2l_add_handler
            new_a2l = GenericInputDialog.new(_('Please type in the auth_to_local rule:'), '').run
            if !new_a2l.nil?
                UI.ChangeWidget(Id(:auth_to_local), :Items, UI.QueryWidget(Id(:auth_to_local), :Items) + [new_a2l])
            end
        end

        # Remove an auth_to_local
        def a2l_remove_handler
            UI.ChangeWidget(Id(:auth_to_local), :Items, UI.QueryWidget(Id(:auth_to_local), :Items).map{|item| item[1]} - [UI.QueryWidget(Id(:auth_to_local), :CurrentItem)])
        end

        # Add an auth_to_local_names
        def a2ln_add_handler
            new_a2ln = GenericInputDialog.new(_('Please type in the principal name and user name in the format of "princ_name = user_name":'), '').run
            if !new_a2ln.nil?
                new_a2ln = new_a2ln.split(/\s*=\s*/)
                if new_a2ln.length == 2
                    UI.ChangeWidget(Id(:auth_to_local_names), :Items, UI.QueryWidget(Id(:auth_to_local_names), :Items) + [Item(new_a2ln[0], new_a2ln[1])])
                end
            end
        end

        # Remove an auth_to_local_names
        def a2ln_remove_handler
            current_key = UI.QueryWidget(Id(:auth_to_local_names), :CurrentItem)
            new_items = UI.QueryWidget(Id(:auth_to_local_names), :Items).select{ |item| item[1] != current_key}
            UI.ChangeWidget(Id(:auth_to_local_names), :Items, new_items)
        end

        # Save realm settings
        def ok_handler
            input_realm_name = UI.QueryWidget(Id(:realm_name), :Value).upcase
            if input_realm_name == ''
                Popup.Error(_('Please enter realm name.'))
                return
            end
            # Move configuration from one realm to another
            if !@realm_name.nil? && @realm_name != input_realm_name
                AuthConfInst.krb_conf['realms'][input_realm_name] = AuthConfInst.krb_conf['realms'][@realm_name]
                AuthConfInst.krb_conf['realms'].delete(@realm_name)
                if AuthConfInst.krb_conf['libdefaults']['default_realm'] == @realm_name
                    AuthConfInst.krb_conf['libdefaults']['default_realm'] = input_realm_name
                end
                domains = AuthConfInst.krb_conf['domain_realms'].select{ |_, realm| realm == @realm_name}.keys
                domains.each {|domain| AuthConfInst.krb_conf['domain_realms'].delete(domain)}
                domains.each {|domain| AuthConfInst.krb_conf['domain_realms'][domain] = input_realm_name}
            end
            # Create new realm
            if !AuthConfInst.krb_conf['realms'].include?(input_realm_name)
                AuthConfInst.krb_conf['realms'][input_realm_name] = {}
            end
            # Set settings
            realm_conf = AuthConfInst.krb_conf['realms'][input_realm_name]
            realm_conf['admin_server'] = UI.QueryWidget(Id(:admin_server), :Value)
            realm_conf['master_kdc'] = UI.QueryWidget(Id(:master_kdc), :Value)
            realm_conf['kdc'] = UI.QueryWidget(Id(:kdc), :Items).map{|item| item[1]}
            if UI.QueryWidget(Id(:map_domain), :Value)
                AuthConfInst.krb_conf['domain_realms'][input_realm_name.downcase] = input_realm_name
            else
                AuthConfInst.krb_conf['domain_realms'].delete(input_realm_name.downcase)
            end
            if UI.QueryWidget(Id(:map_wildcard_domain), :Value)
                AuthConfInst.krb_conf['domain_realms'][".#{input_realm_name.downcase}"] = input_realm_name
            else
                AuthConfInst.krb_conf['domain_realms'].delete(".#{input_realm_name.downcase}")
            end
            realm_conf['auth_to_local'] = UI.QueryWidget(Id(:auth_to_local), :Items).map{|item| item[1]}
            realm_conf['auth_to_local_names'] = Hash[*UI.QueryWidget(Id(:auth_to_local_names), :Items).map{|item| [item[1], item[2]]}.flatten]
            finish_dialog(:finish)
        end

        # Close the dialog
        def finish_handler
            finish_dialog(:finish)
        end
    end
end
