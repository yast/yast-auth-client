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
require 'auth/authconf.rb'
require 'authui/ldapkrb/edit_realm_dialog'
require 'authui/ldapkrb/krb_extended_opts_dialog'
require 'authui/ldapkrb/ldap_extended_opts_dialog'
Yast.import 'UI'
Yast.import 'Label'

module LdapKrb
    # Main dialog shows three tabs, one for Kerberos, one for LDAP, and one for auxiliary daemons.
    class MainDialog
        include Yast
        include Auth
        include UIShortcuts
        include I18n
        include Logger

        def initialize
            @tab = :ldap # the last saved tab
            textdomain 'auth-client'
        end

        def run
            return if !UI.OpenDialog(Opt(:decorated, :defaultsize),
                VBox(Opt(:hstretch),
                    DumbTab([_('Use a Directory as Identity Provider (LDAP)'), _('Authentication via Kerberos')],
                            ReplacePoint(Id(:tab), Empty())),
                    ButtonBox(
                        PushButton(Id(:ok), Label.OKButton),
                        PushButton(Id(:cancel), Label.CancelButton),
                    ),
                ),
            )
            render_ldap
            begin
                return ui_event_loop
            ensure
                UI.CloseDialog()
            end
        end

        def ui_event_loop
            loop do
                case UI.UserInput
                    when _('Use a Directory as Identity Provider (LDAP)')
                        save_tab
                        render_ldap
                        @tab = :ldap
                    when _('Authentication via Kerberos')
                        save_tab
                        render_krb
                        @tab = :krb

                    # LDAP tab events
                    when :ldap_pam
                        if UI.QueryWidget(Id(:ldap_pam), :Value)
                            if AuthConfInst.sssd_pam || AuthConfInst.sssd_enabled
                                Popup.Error(_("This computer is currently using SSSD to authenticate users.\n" +
                                              "Before you may use legacy LDAP authentication (pam_ldap), please disable SSSD from \"User Logon Management\"."))
                                UI.ChangeWidget(Id(:ldap_pam), :Value, false)
                            end
                        end
                    when :ldap_nss_passwd
                        if UI.QueryWidget(Id(:ldap_nss_passwd), :Value)
                            if AuthConfInst.sssd_nss.include?('passwd')
                                Popup.Error(_("This computer is currently reading user database from SSSD identity provider.\n" +
                                              "Before you may use LDAP user database (nss_ldap), please disable SSSD user database from \"User Logon Management\"."))
                                UI.ChangeWidget(Id(:ldap_nss_passwd), :Value, false)
                            end
                        end
                    when :ldap_nss_group
                        if UI.QueryWidget(Id(:ldap_nss_group), :Value)
                            if AuthConfInst.sssd_nss.include?('group')
                                Popup.Error(_("This computer is currently reading group database from SSSD identity provider.\n" +
                                              "Before you may use LDAP group database (nss_ldap), please disable SSSD group database from \"User Logon Management\"."))
                                UI.ChangeWidget(Id(:ldap_nss_group), :Value, false)
                            end
                        end
                    when :ldap_nss_sudoers
                        if UI.QueryWidget(Id(:ldap_nss_sudoers), :Value)
                            if AuthConfInst.sssd_nss.include?('sudoers')
                                Popup.Error(_("This computer is currently reading sudoers database from SSSD identity provider.\n" +
                                              "Before you may use LDAP sudoers database (nss_ldap), please disable SSSD sudo database from \"User Logon Management\"."))
                                UI.ChangeWidget(Id(:ldap_nss_sudoers), :Value, false)
                            end
                        end
                    when :ldap_nss_automount
                        if UI.QueryWidget(Id(:ldap_nss_automount), :Value)
                            if AuthConfInst.sssd_nss.include?('automount')
                                Popup.Error(_("This computer is currently reading automount database from SSSD identity provider.\n" +
                                              "Before you may use LDAP automount database (nss_ldap), please disable SSSD automount database from \"User Logon Management\"."))
                                UI.ChangeWidget(Id(:ldap_nss_automount), :Value, false)
                                redo
                            end
                        end
                        AuthConfInst.autofs_enabled = UI.QueryWidget(Id(:ldap_nss_automount), :Value)
                    when :ldap_test
                        uris, hosts = get_ldap_uri_and_hosts
                        if uris.empty? && hosts.empty?
                            Popup.Error(_('Please enter server URI.'))
                            redo
                        end
                        start_tls = UI.QueryWidget(Id(:ldap_tls_method), :CurrentButton) == :ldap_tls_method_starttls
                        dn = UI.QueryWidget(Id(:ldap_binddn), :Value)
                        password = UI.QueryWidget(Id(:ldap_bindpw), :Value)
                        base_dn = UI.QueryWidget(Id(:ldap_base), :Value)
                        if base_dn == ''
                            Popup.Error(_('Please enter DN of search base.'))
                            redo
                        end
                        # Test URI input
                        uris.each {|uri|
                            result = AuthConfInst.ldap_test_bind(uri, start_tls, dn, password, base_dn)
                            if result == ''
                                Popup.Message(_('Successfully contacted LDAP server on URI %s!') % [uri])
                            else
                                Popup.LongError(_("Connection check has failed on URI %s.\n\n%s") % [uri, result])
                            end
                        }
                        # Test host address input, construct URI for each one.
                        host_uri_prefix = ''
                        if UI.QueryWidget(Id(:ldap_tls_method), :CurrentButton) == :ldap_tls_method_yes
                            host_uri_prefix = 'ldaps://'
                        else
                            host_uri_prefix = 'ldap://'
                        end
                        hosts.each {|host|
                            splitted = host.split(':')
                            if splitted.length == 1
                                host_uri = "#{host_uri_prefix}#{host}:389"
                            else
                                host_uri = "#{host_uri_prefix}#{splitted[0]}:#{splitted[1]}"
                            end
                            result = AuthConfInst.ldap_test_bind(host_uri, start_tls, dn, password, base_dn)
                            if result == ''
                                Popup.Message(_('Successfully contacted LDAP server on host %s') % [host_uri])
                            else
                                Popup.LongError(_("Connection check has failed on host %s.\n\n%s") % [host_uri, result])
                            end
                        }
                    when :ldap_extended_opts
                        LdapExtendedOptsDialog.new.run
                    when :nscd_enable
                        if AuthConfInst.sssd_enabled && UI.QueryWidget(Id(:nscd_enable), :Value)
                            if !Popup.YesNo(_("The name service cache is should only used with legacy LDAP identity provider,\n" +
                                             "but your system currently has authentication domain enabled, which is not compatible with the cache.\n\n" +
                                             "Do you still wish to enable the cache?"))
                                UI.ChangeWidget(Id(:nscd_enable), :Value, false)
                            end
                        end
                    when :ldap_extended_opts
                        LdapExtendedOptsDialog.new.run

                    # Kerberos tab events
                    when :krb_pam
                        if UI.QueryWidget(Id(:krb_pam), :Value)
                            if AuthConfInst.sssd_pam || AuthConfInst.sssd_enabled
                                Popup.Error(_("This computer is currently using SSSD to authenticate users.\n" +
                                              "Before you may use Kerberos authentication (pam_krb5), please disable SSSD from \"User Logon Management\"."))
                                UI.ChangeWidget(Id(:krb_pam), :Value, false)
                            end
                        end
                    when :krb_realm_new
                        LdapKrb::EditRealmDialog.new(nil).run
                        curr_def = UI.QueryWidget(Id(:krb_default_realm), :Value)
                        UI.ChangeWidget(Id(:krb_default_realm), :Items, [_('(not specified)')] + AuthConfInst.krb_conf['realms'].keys.sort)
                        UI.ChangeWidget(Id(:krb_default_realm), :Value, curr_def)
                        UI.ChangeWidget(Id(:krb_realms), :Items, AuthConfInst.krb_conf['realms'].keys.sort)
                    when :krb_realm_edit
                        realm = UI.QueryWidget(Id(:krb_realms), :CurrentItem)
                        if realm.nil?
                            redo
                        end
                        LdapKrb::EditRealmDialog.new(realm).run
                        curr_def = UI.QueryWidget(Id(:krb_default_realm), :Value)
                        UI.ChangeWidget(Id(:krb_default_realm), :Items, [_('(not specified)')] + AuthConfInst.krb_conf['realms'].keys.sort)
                        UI.ChangeWidget(Id(:krb_default_realm), :Value, curr_def)
                        UI.ChangeWidget(Id(:krb_realms), :Items, AuthConfInst.krb_conf['realms'].keys.sort)
                    when :krb_realm_del
                        realm_name = UI.QueryWidget(Id(:krb_realms), :CurrentItem)
                        if realm_name.nil?
                            redo
                        end
                        if Popup.YesNo(_('Are you sure to delete realm %s?') % [realm_name])
                            AuthConfInst.krb_conf['domain_realm'].delete_if{ |_, domain_realm| domain_realm == realm_name}
                            if UI.QueryWidget(Id(:krb_default_realm), :Value) == realm_name
                                UI.ChangeWidget(Id(:krb_default_realm), :Value, _('(not specified)'))
                            end
                            AuthConfInst.krb_conf['realms'].delete(realm_name)
                            UI.ChangeWidget(Id(:krb_realms), :Items, AuthConfInst.krb_conf['realms'].keys.sort)
                            curr_def = UI.QueryWidget(Id(:krb_default_realm), :Value)
                            UI.ChangeWidget(Id(:krb_default_realm), :Items, [_('(not specified)')] + AuthConfInst.krb_conf['realms'].keys.sort)
                            UI.ChangeWidget(Id(:krb_default_realm), :Value, curr_def)
                            if AuthConfInst.krb_conf_get(['libdefaults', 'default_realm'], nil) == realm_name
                                AuthConfInst.krb_conf['libdefaults'].delete('default_realm')
                            end
                        end
                    when :krb_extended_opts
                        KrbExtendedOptsDialog.new.run

                    # Save ALL
                    when :ok
                        save_tab
                        AuthConfInst.ldap_apply
                        AuthConfInst.krb_apply
                        AuthConfInst.aux_apply
                        break
                    else
                        break
                end
            end
        end

        # Save the content of current tab.
        def save_tab
            case @tab
            when :ldap
                save_ldap
            when :krb
                save_krb
            when :aux
                save_aux
            end
        end

        # Return a tuple of ldap URIs (array) and ldap host:port combinations (array).
        def get_ldap_uri_and_hosts
            uris = []
            hosts = []
            UI.QueryWidget(Id(:ldap_host_or_uri), :Value).split(/\s+/).each {|entry|
                if /ldap.*:\/\//.match(entry)
                    uris += [entry]
                else
                    hosts += [entry]
                end
            }
            return [uris, hosts]
        end

        def save_ldap
            AuthConfInst.nscd_enabled = UI.QueryWidget(Id(:nscd_enable), :Value)
            AuthConfInst.ldap_pam = UI.QueryWidget(Id(:ldap_pam), :Value)
            ['passwd', 'group', 'sudoers', 'automount'].each{ |db|
                symbol = ('ldap_nss_' + db).to_sym
                if UI.QueryWidget(Id(symbol), :Value)
                    AuthConfInst.ldap_nss += [db] if !AuthConfInst.ldap_nss.include?(db)
                else
                    AuthConfInst.ldap_nss.delete_if{ |n| n == db}
                end
            }
            # Split URI/host entry into two attributes, remove port attribute
            AuthConfInst.ldap_conf.delete('port')
            uris, hosts = get_ldap_uri_and_hosts
            if hosts.any?
                AuthConfInst.ldap_conf['host'] = hosts.join(' ')
            else
                AuthConfInst.ldap_conf.delete('host')
            end
            if uris.any?
                AuthConfInst.ldap_conf['uri'] = uris.join(' ')
            else
                AuthConfInst.ldap_conf.delete('uri')
            end
            AuthConfInst.ldap_conf['base'] = UI.QueryWidget(Id(:ldap_base), :Value)
            AuthConfInst.ldap_conf['binddn'] = UI.QueryWidget(Id(:ldap_binddn), :Value)
            if AuthConfInst.ldap_conf['binddn'] == ''
                AuthConfInst.ldap_conf.delete('binddn')
            end
            AuthConfInst.ldap_conf['bindpw'] = UI.QueryWidget(Id(:ldap_bindpw), :Value)
            if AuthConfInst.ldap_conf['bindpw'] == ''
                AuthConfInst.ldap_conf.delete('bindpw')
            end
            if UI.QueryWidget(Id(:ldap_rfc2307bis), :Value)
                AuthConfInst.ldap_conf['nss_schema'] = 'rfc2307bis'
            else
                AuthConfInst.ldap_conf.delete('nss_schema')
            end
            if UI.QueryWidget(Id(:ldap_persist), :Value)
                AuthConfInst.ldap_conf['nss_connect_policy'] = 'persist'
            else
                AuthConfInst.ldap_conf['nss_connect_policy'] = 'oneshot'
            end
            case UI.QueryWidget(Id(:ldap_tls_method), :CurrentButton)
            when :ldap_tls_method_no
                AuthConfInst.ldap_conf['ssl'] = 'no'
            when :ldap_tls_method_yes
                AuthConfInst.ldap_conf['ssl'] = 'yes'
            when :ldap_tls_method_starttls
                AuthConfInst.ldap_conf['ssl'] = 'start_tls'
            end
            AuthConfInst.mkhomedir_pam = UI.QueryWidget(Id(:mkhomedir_enable), :Value)
        end

        # Save Kerberos
        def save_krb
            AuthConfInst.krb_pam = UI.QueryWidget(Id(:krb_pam), :Value)
            default_realm_choice = UI.QueryWidget(Id(:krb_default_realm), :Value)
            if default_realm_choice == _('(not specified)')
                AuthConfInst.krb_conf['libdefaults']['default_realm'] = nil
            else
                AuthConfInst.krb_conf['libdefaults']['default_realm'] = default_realm_choice
            end
            AuthConfInst.krb_conf['libdefaults']['forwardable'] = UI.QueryWidget(Id(:krb_forwardable), :Value)
            AuthConfInst.krb_conf['libdefaults']['proxiable'] = UI.QueryWidget(Id(:krb_proxiable), :Value)
            AuthConfInst.krb_conf['libdefaults']['noaddresses'] = UI.QueryWidget(Id(:krb_noaddresses), :Value)
            AuthConfInst.krb_conf['libdefaults']['dns_lookup_realm'] = UI.QueryWidget(Id(:krb_dns_lookup_realm), :Value)
            AuthConfInst.krb_conf['libdefaults']['dns_lookup_kdc'] = UI.QueryWidget(Id(:krb_dns_lookup_kdc), :Value)
            AuthConfInst.krb_conf['libdefaults']['allow_weak_crypto'] = UI.QueryWidget(Id(:krb_allow_weak_crypto), :Value)
            AuthConfInst.mkhomedir_pam = UI.QueryWidget(Id(:mkhomedir_enable), :Value)
        end

        def render_ldap
            UI.ReplaceWidget(Id(:tab), VBox(
                HBox(
                    Top(VBox(
                        Left(CheckBox(Id(:ldap_pam), Opt(:notify), _('Allow LDAP Users To Authenticate (pam_ldap)'), AuthConfInst.ldap_pam)),
                        Left(CheckBox(Id(:nscd_enable), Opt(:notify), _('Cache LDAP Entries For Faster Response (nscd)'), AuthConfInst.nscd_enabled)),
                        Left(CheckBox(Id(:mkhomedir_enable), _('Automatically Create Home Directory'), AuthConfInst.mkhomedir_pam)),
                        VSpacing(1.0),
                        Left(Label(_('Read the following items from LDAP data source:'))),
                        Left(CheckBox(Id(:ldap_nss_passwd), Opt(:notify), _("Users"), AuthConfInst.ldap_nss.include?('passwd'))),
                        Left(CheckBox(Id(:ldap_nss_group), Opt(:notify), _("Groups"), AuthConfInst.ldap_nss.include?('group'))),
                        Left(CheckBox(Id(:ldap_nss_sudoers), Opt(:notify), _("Super-User Commands (sudo)"), AuthConfInst.ldap_nss.include?('sudoers'))),
                        Left(CheckBox(Id(:ldap_nss_automount), Opt(:notify), _("Network Disk Locations (automount)"), AuthConfInst.ldap_nss.include?('automount'))),
                        VSpacing(1.0),
                        Left(Label(_('Enter LDAP server locations (space separated), in either format:'))),
                        Left(Label(_('- Host name or IP and port number (ip:port)'))),
                        Left(Label(_('- URI (ldap://server:port, ldaps://server:port)'))),
                        InputField(Id(:ldap_host_or_uri), Opt(:hstretch), ''),
                        InputField(Id(:ldap_base), Opt(:hstretch), _('DN of Search Base (e.g. dc=example,dc=com)'),
                                   AuthConfInst.ldap_conf['base'].to_s),
                    )),
                    Top(VBox(
                        InputField(Id(:ldap_binddn), Opt(:hstretch), _('DN of Bind User (Leave Empty for Anonymous Bind)'),
                                   AuthConfInst.ldap_conf['binddn'].to_s),
                        InputField(Id(:ldap_bindpw), Opt(:hstretch), _('Password of the Bind User (Leave Empty for Anonymous Bind)'),
                                   AuthConfInst.ldap_conf['bindpw'].to_s),
                        VSpacing(1.0),
                        CheckBox(Id(:ldap_rfc2307bis), Opt(:hstretch), _('Identify Group Members by Their DNs (RFC2307bis)'),
                                 AuthConfInst.ldap_conf['nss_schema'] == 'rfc2307bis'),
                        CheckBox(Id(:ldap_persist), Opt(:hstretch), _('Leave LDAP Connections Open for Consecutive Requests'),
                                 AuthConfInst.ldap_conf['nss_connect_policy'] != 'oneshot'),
                        VSpacing(1.0),
                        Frame(_('Secure LDAP communication'), RadioButtonGroup(Id(:ldap_tls_method), VBox(
                            Left(RadioButton(Id(:ldap_tls_method_no), _('Do Not Use Security'))),
                            Left(RadioButton(Id(:ldap_tls_method_yes), _('Secure Communication via TLS'))),
                            Left(RadioButton(Id(:ldap_tls_method_starttls), _('Secure Communication via StartTLS'))),
                        ))),
                        VSpacing(1.0),
                        Left(HBox(PushButton(Id(:ldap_test), _('Test Connection')), PushButton(Id(:ldap_extended_opts), _('Extended Options')))),
                    )),
                ),
            ))
            # Combine host/port/uri into one
            default_port_str = AuthConfInst.ldap_conf['port'] ? AuthConfInst.ldap_conf['port'] : '389'
            hosts = AuthConfInst.ldap_conf['host'].to_s.split(/\s+/).map{|a_host|
                # If not specified, append the default port number
                if a_host.split(':').length == 1
                    a_host + ':' + default_port_str
                else
                    a_host
                end
            }
            uris = AuthConfInst.ldap_conf['uri'].to_s.split(/\s+/)
            UI.ChangeWidget(Id(:ldap_host_or_uri), :Value, (uris + hosts).join(' '))

            if AuthConfInst.ldap_conf['bind_policy'] == 'soft'
                UI.ChangeWidget(Id(:ldap_bind_policy), :CurrentButton, :ldap_bind_policy_soft)
            else
                UI.ChangeWidget(Id(:ldap_bind_policy), :CurrentButton, :ldap_bind_policy_hard)
            end
            if AuthConfInst.ldap_conf['ssl'] == 'on'
                UI.ChangeWidget(Id(:ldap_tls_method), :CurrentButton, :ldap_tls_method_yes)
            elsif AuthConfInst.ldap_conf['ssl'] == 'start_tls'
                UI.ChangeWidget(Id(:ldap_tls_method), :CurrentButton, :ldap_tls_method_starttls)
            else
                UI.ChangeWidget(Id(:ldap_tls_method), :CurrentButton, :ldap_tls_method_no)
            end
        end

        def render_krb
            UI.ReplaceWidget(Id(:tab), VBox(
                HBox(
                    Top(VBox(
                        Left(CheckBox(Id(:krb_pam), Opt(:notify), _('Allow Kerberos Users To Authenticate (pam_krb5)'),
                            AuthConfInst.krb_pam)),
                        Left(HBox(CheckBox(Id(:mkhomedir_enable), _('Automatically Create Home Directory'), AuthConfInst.mkhomedir_pam))),
                        VSpacing(1.0),
                        Left(ComboBox(Id(:krb_default_realm), _('Default Realm For User Login:'),
                            [_('(not specified)')] + AuthConfInst.krb_conf['realms'].keys.sort)),
                        Left(SelectionBox(Id(:krb_realms), _('All Authentication Realms'),
                            AuthConfInst.krb_conf['realms'].keys.sort)),
                        Left(HBox(PushButton(Id(:krb_realm_new), _('Add Realm')), PushButton(Id(:krb_realm_edit), _('Edit Realm')), PushButton(Id(:krb_realm_del), _('Delete Realm')))),
                    )),
                    Top(VBox(
                        Left(CheckBox(Id(:krb_dns_lookup_realm), _('Use DNS TXT Record to Discover Realms'),
                            AuthConfInst.krb_conf_get_bool(['libdefaults', 'dns_lookup_realm'], false))),
                        Left(CheckBox(Id(:krb_dns_lookup_kdc), _('Use DNS SRV record to Discover KDC servers'),
                            AuthConfInst.krb_conf_get_bool(['libdefaults', 'dns_lookup_kdc'], false))),
                        VSpacing(1.0),
                        Left(CheckBox(Id(:krb_allow_weak_crypto), _('Allow Insecure Encryption (Windows NT)'),
                            AuthConfInst.krb_conf_get_bool(['libdefaults', 'allow_weak_crypto'], false))),
                        Left(CheckBox(Id(:krb_forwardable), _('Allow KDC on Other Networks to Issue Authentication Tickets'),
                            AuthConfInst.krb_conf_get_bool(['libdefaults', 'forwardable'], false))),
                        Left(CheckBox(Id(:krb_proxiable), _('Allow Kerberos-Enabled Services to Take on The Identity Of a User'),
                            AuthConfInst.krb_conf_get_bool(['libdefaults', 'proxiable'], false))),
                        Left(CheckBox(Id(:krb_noaddresses), _('Issue Address-Less Tickets for Computers Behind NAT'),
                            AuthConfInst.krb_conf_get_bool(['libdefaults', 'noaddresses'], false))),
                        VSpacing(1.0),
                        Left(PushButton(Id(:krb_extended_opts), _('Extended Options'))),
                    )),
                ),
            ))
            UI.ChangeWidget(Id(:krb_default_realm), :Value, AuthConfInst.krb_conf_get(['libdefaults', 'default_realm'], _('(not specified)')))
        end
    end
end
