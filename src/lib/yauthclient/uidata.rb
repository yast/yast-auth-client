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

require "yauthclient/params.rb"

Yast.import "AuthClient"

module YAuthClient
    # UI state information and configuration presentation.
    class UIData
        include Yast::Logger
        include Singleton

        def initialize
            @sssd_conf = Yast::AuthClient.auth["sssd_conf"]

            # Initially load section "sssd"
            switch_section("sssd")
        end

        # Return SSSD configuration backend (all sections)
        def get_conf
            return @sssd_conf
        end

        # Return list of all configured domain names (with prefix /).
        def get_all_domains
            if !@sssd_conf
                return []
            end
            return @sssd_conf.keys.select { |k| k.start_with? "domain/" }.uniq
        end

        # Return list of enabled domain names (without prefix /).
        def get_enabled_domains
            if !@sssd_conf["sssd"]
                return []
            end
            return @sssd_conf["sssd"].fetch("domains", "").split(%r{[\s,]+})
        end

        # Return list of enabled service names.
        def get_enabled_services
            if !@sssd_conf["sssd"]
                return []
            end
            return @sssd_conf["sssd"].fetch("services", "").split(%r{[\s,]+})
        end

        # Return list of all configured service names.
        def get_all_services
            if !@sssd_conf
                return []
            end
            sections = @sssd_conf.keys.select { |k| !k.start_with?("domain/") && k != "sssd" }
            # Pull in more service names from "services" parameter
            sections += @sssd_conf.fetch("sssd", Hash[]).fetch("services", "").split(%r{[\s,]+})
            return sections.uniq
        end

        # Reload configuration data of the current section.
        def reload_section
            reload_section_conf
            reload_section_more_params
        end

        # Switch to a new configuration section and load its current configuration.
        def switch_section(new_section)
            @curr_section = new_section
            reload_section
        end

        # Get the name of currently chosen configuration section.
        def get_curr_section
            return @curr_section
        end

        # Return tuples of parameter name, value, and description for the current section.
        def get_section_conf
            return @curr_section_conf
        end

        # Return hash of additional customisable parameters (name, description, etc).
        def get_section_more_params
            return @curr_section_more_params
        end

        # Return list of service names not yet enabled in configuration.
        def get_unused_svcs
            supported = ["nss", "pam", "sudo", "autofs", "ssh"]
            return (supported - get_enabled_services).sort
        end

        # Get list of supported identity providers.
        def get_id_providers
            return ["proxy", "local", "ldap", "ipa", "ad"].sort
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
            return @curr_section_more_params.reject { |name, detail|
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
            return @sssd_conf.fetch(@curr_section, Hash[]).fetch(param_name, nil)
        end

        private
            # Reload (tuples of) parameter name, value, and description for the current section.
            def reload_section_conf
                params = @sssd_conf.fetch(@curr_section, Hash[])
                @curr_section_conf = params.map { |k, v| [k, v.to_s, Params.instance.get_by_name(k)["desc"]] }
            end

            # Reload (hash of) additional parameter name and descriptions for the current section.
            def reload_section_more_params
                current_conf = @sssd_conf.fetch(@curr_section, Hash[])
                more_params = Hash[]
                # Collect relevant parameters depending on the current section
                if @curr_section =~ /^domain/
                    # Provider-specific parameters
                    id_provider = current_conf.fetch("id_provider", "")
                    auth_provider = current_conf.fetch("auth_provider", "")
                    if id_provider != ""
                        more_params.merge!(Params.instance.get_by_section(id_provider))
                    end
                    if auth_provider != ""
                        more_params.merge!(Params.instance.get_by_section(auth_provider))
                    end
                    # Common domain parameters
                    more_params.merge!(Params.instance.get_common_domain_section)
                else
                    more_params = Params.instance.get_by_section(@curr_section)
                end
                # Remove customised parameters
                more_params.delete_if { |name, detail| current_conf.has_key? name }
                @curr_section_more_params = more_params
            end
    end
end
