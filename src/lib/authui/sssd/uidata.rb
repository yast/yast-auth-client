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

require "auth/authconf.rb"
require "authui/sssd/params.rb"

module SSSD
    # UI state information and configuration presentation.
    class UIData
        include Yast
        include Auth
        include Singleton

        def initialize
            # Initially load section "sssd"
            switch_section("sssd")
        end

        # Reload configuration data of the current section.
        def reload_section
            reload_section_conf
            reload_section_more_params
        end

        # Switch to a new configuration section and load its current configuration.
        def switch_section(new_section)
            if new_section == ""
                @curr_section = "sssd"
            else
                @curr_section = new_section
            end
            reload_section
        end

        # Get the name of currently chosen configuration section.
        def get_curr_section
            return @curr_section
        end

        # Delete the currently chosen configuration section.
        def del_curr_section
            sect_name = get_curr_section
            AuthConfInst.sssd_conf.delete(sect_name)
            AuthConfInst.sssd_conf['sssd']['domains'].delete_if{|a| a == sect_name}
            AuthConfInst.sssd_conf['sssd']['services'].delete_if{|a| a == sect_name}
            # Switch away from the deleted section
            switch_section("sssd")
        end

        # Return tuples of parameter name, value, and description for the current section.
        def get_section_conf
            conf = @curr_section_conf
            if @curr_section == 'sssd'
                # Hide these parameters from user
                conf.delete_if { |entry| ['domains', 'services', 'config_file_version'].include?(entry[0]) }
            end
            return conf
        end

        # Return hash of additional customisable parameters (name, description, etc).
        def get_section_more_params
            return @curr_section_more_params
        end

        # Get list of supported identity providers.
        def get_id_providers
            return ["proxy", "local", "ldap", "ipa", "ad"].sort
        end

        # If current section is a domain, return its ID provider. Nil otherwise.
        def get_current_id_provider
            return AuthConfInst.sssd_conf.fetch(@curr_section, Hash[]).fetch("id_provider", nil)
        end

        # If current section is a domain, return its authentication provider. Nil otherwise.
        def get_current_auth_provider
            return AuthConfInst.sssd_conf.fetch(@curr_section, Hash[]).fetch("auth_provider", nil)
        end

        # Get list of supported authentication providers.
        def get_auth_providers
            return ["ldap", "krb5", "ipa", "ad", "proxy", "local", "none"].sort
        end

        # Like get_section_more_params, with a string filter on top of.
        def get_section_params_with_filter(str_filter)
            filter_words = str_filter.split(%r{[\s_]+})
            # To provide better filter result based on the confusing wording of certain SSSD parameters,
            # the quick filter works according to two rules:
            # - Parameter name shall contain all filter words with the exception of the final word.
            # - One of the words among the parameter name shall contain the final filter word.
            # Thus returning result such as "ldap_service_object_class" when filter is "ldap_object".
            return @curr_section_more_params.reject { |name, _detail|
                name_words = name.split(%r{[\s_]+})
                if filter_words.length == 1
                    name_words.none? { |word| word.include? filter_words[0] }
                elsif filter_words.length > 1
                    (filter_words[0..-2] - name_words).any? or name_words.none? { |word| word.include? filter_words[-1] }
                else
                    false
                end
            }
        end

        # Return the customised value of the parameter in current section, or nil if no customisation.
        def get_param_val(param_name)
            return AuthConfInst.sssd_conf.fetch(@curr_section, Hash[]).fetch(param_name, nil)
        end
        
        # Return true only if the currently chosen section involves AD setup.
        def curr_section_involves_ad?
            sect_conf = AuthConfInst.sssd_conf.fetch(@curr_section, Hash[])
            return sect_conf['id_provider'] == 'ad' || sect_conf['auth_provider'] == 'ad'
        end

    private

            # Reload (tuples of) parameter name, value, and description for the current section.
            def reload_section_conf
                params = AuthConfInst.sssd_conf.fetch(@curr_section, Hash[])
                @curr_section_conf = params.map { |k, v|
                    [k, v.to_s, Params.instance.get_by_name(k)["desc"]]
                }
            end

            # Reload (hash of) additional parameter name and descriptions for the current section.
            def reload_section_more_params
                current_conf = AuthConfInst.sssd_conf.fetch(@curr_section, Hash[])
                more_params = Hash[]
                # Collect relevant parameters depending on the current section
                if @curr_section =~ /^domain/
                    more_params.merge!(Params.instance.get_common_domain_params)
                    # Provider-specific parameters
                    more_params.merge!(Params.instance.get_by_provider(get_current_id_provider))
                    more_params.merge!(Params.instance.get_by_provider(get_current_auth_provider))
                else
                    more_params = Params.instance.get_by_category(@curr_section)
                    if @curr_section != "sssd"
                        # Common service parameters
                        more_params.merge!(Params.instance.get_common_service_params)
                    end
                end
                # Remove customised parameters
                more_params.delete_if { |name, _detail| current_conf.key? name }
                @curr_section_more_params = more_params
            end
    end
end
