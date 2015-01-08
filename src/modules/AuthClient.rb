# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2006-2012 Novell, Inc. All Rights Reserved.
#
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
# this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail, you may find
# current contact information at www.novell.com.
# ------------------------------------------------------------------------------

# File: modules/AuthClient.ycp
# Module:       Configuration of authentication client
# Summary:      Authentication client configuration data, I/O functions.
# Authors:      Peter Varkoly <varkoly@suse.com>
#               Christian Kornacker <ckornacker@suse.com>
#
# $Id$
require "yast"

module Yast
  class AuthClientClass < Module

    NSS_DBS = ["passwd", "group", "passwd_compat", "group_compat", "services", "netgroup", "aliases", "automount" ]
    SSS_DBS = ["passwd", "group" ]

    def main
      textdomain  "auth-client"
      Yast.import "Nsswitch"
      Yast.import "Package"
      Yast.import "Pam"
      Yast.import "Service"

      # configuration modification switch
      @modified = false

      # stored values of /etc/nsswitch.conf
      @nsswitch = {
        "passwd"        => [],
        "group"         => [],
        "passwd_compat" => [],
        "group_compat"  => [],
        "automount"     => [],
        "services"      => [],
        "netgroup"      => [],
        "aliases"       => []
      }


      # the auth configuration
      @make_hash = proc do |hash,key|
         hash[key] = Hash.new(&@make_hash)
      end

      @auth = Hash.new(&@make_hash)

    end

    # Check if current machine runs OES
    def CheckOES
      return Package.Installed("NOVLam")
    end

    #################################################################
    # Read()
    # Reads the clients authentication configuration.
    # @return true or false
    def Read

      #Check if oes is used in nss
      @auth["oes"]  = CheckOES()

      #Check if pam_mkhomedir is enabled.
      @auth["mkhomedir"] = Pam.Enabled("mkhomedir")

      #Check if ldap is used in nss
      NSS_DBS.each { |db| @nsswitch[db] = Nsswitch.ReadDb(db) }

      @auth["nssldap"] =   @nsswitch["passwd"].include?("ldap") ||
                         ( @nsswitch["passwd"].include?("ldap") && @nsswitch["passwd_compat"].include?("ldap") ) ||
                         ( @auth["oes"] && @nsswitch["passwd"].include?("nam") )

      #Check if sssd is used in nss
      @auth["sssd"] = @nsswitch["passwd"].include?("sss")

      if @auth["sssd"]
         _sections = SCR.Dir(path(".etc.sssd_conf.section"))
         _sections.each { |s|
            _values = SCR.Read(path( ".etc.sssd_conf.all.\"#{s}\"" ) )
            _values["value"].each { |v|
              next if v["kind"] == "comment"
              @auth["sssd_conf"][s][v["name"]] = v["value"]
            }
         }
      end
      Builtins.y2milestone("auth: %1",@auth)
      true
    end
    # end Read()
    #################################################################

    #################################################################
    # Write()
    # Writes the clients authentication configuration.
    # @return true or false
    def Write
      if ! @auth['sssd_conf']['sssd'].has_key?("domains")
        # Nothing to do
        return true
      end
      Builtins.y2milestone("auth: %1",@auth)
      domains  = []
      services = []
      filter_groups = []
      filter_users  = []
      to_install    = []
      if !Package.Installed("sssd") && Package.Available("sssd")
          to_install << "sssd"
      end

      need_sssd = {
         "ldap"  => false,
         "ipa"   => false,
         "ad"    => false,
         "krb5"  => false,
         "proxy" => false
      }

      #Add sss to pam
      Pam.Add("sss")

      #Enable pam_mkhomedir if required.
      if @auth["mkhomedir"]
         Pam.Add("mkhomedir")
      else
         Pam.Remove("mkhomedir")
      end

      #Remove ldap only nss databases
      NSS_DBS.each { |db|
        @nsswitch[db] = Nsswitch.ReadDb(db).reject{ |v| v =~ /ldap/ }
        @nsswitch[db] = ["files"] if @nsswitch[db] == []
      }

      # Add "sss" to the passwd and group databases in nsswitch.conf
      SSS_DBS.each { |db| @nsswitch[db].push("sss") if ! @nsswitch[db].include?("sss") }


      #Remove kerberos if activated
      if Pam.Enabled("krb5")
        Builtins.y2milestone( "configuring 'sss', so 'krb5' will be removed")
        Pam.Remove("ldap-account_only")
        Pam.Remove("krb5")
      end
      Pam.Remove("ldap")

      if @auth["sssd_conf"]["sssd"].has_key?("services")
         services = @auth["sssd_conf"]["sssd"]["services"].split(%r{,\s*})
      end

      #Enable autofs if service is enabled
      if services.include?("autofs")
         @nsswitch["automount"].push("sss") if ! @nsswitch["automount"].include?("sss") 
         Service.Enable("autofs")
         Service.Start("autofs")
      end

      # Write the new nss tables
      NSS_DBS.each { |db| Nsswitch.WriteDb(db, @nsswitch[db]) }
      Nsswitch.Write

      if @auth["sssd_conf"]["sssd"].has_key?("domains")
         domains = @auth["sssd_conf"]["sssd"]["domains"].split(%r{,\s*})
      end

      #Be sure filter_groups and filter_users contains root in nss section
      if @auth["sssd_conf"].has_key?("nss")
        if @auth["sssd_conf"]["nss"].has_key?("filter_users")
          filter_users = @auth["sssd_conf"]["nss"]["filter_users"].split(%r{,\s*})
        end
      end
      if @auth["sssd_conf"].has_key?("nss")
        if @auth["sssd_conf"]["nss"].has_key?("filter_groups")
          filter_groups = @auth["sssd_conf"]["nss"]["filter_groups"].split(%r{,\s*})
        end
      end
      filter_users.push("root")  if ! filter_users.include?("root")
      filter_groups.push("root") if ! filter_groups.include?("root")
      @auth["sssd_conf"]["nss"]["filter_users"]  = filter_users.join(", ")
      @auth["sssd_conf"]["nss"]["filter_groups"] = filter_groups.join(", ")

      #Now we write the sssd configuration
      @auth["sssd_conf"].each_key { |s|
        if @auth["sssd_conf"][s].has_key?('DeleteSection')
           SCR.Write(path(".etc.sssd_conf.section.\"#{s}\""), nil )
           next
        end
        @auth["sssd_conf"][s].each_key { |k|
	  value = @auth["sssd_conf"][s][k]
          if value == "##DeleteValue##"
             SCR.Write(path(".etc.sssd_conf.value.\"#{s}\".#{k}"), nil )
          else
             SCR.Write(path(".etc.sssd_conf.value.\"#{s}\".#{k}"),value)
          end
          if k == "id_provider" or k == "auth_provider" 
             need_sssd[value] = true;
          end
        }
      }
      #Add section for each services
      _sections = SCR.Dir(path(".etc.sssd_conf.section"))
      services.each { |s|
        SCR.Write(path(".etc.sssd_conf.section_comment.\"#{s}\""), '') if ! _sections.include?(s)
      }
      SCR.Write(path(".etc.sssd_conf"),nil)

      need_sssd.each_pair do |key, needed|
        pkg = "sssd-#{key}"
        if needed && !Package.Installed(pkg) && Package.Available(pkg)
          to_install << pkg
        end
      end

      Package.DoInstall(to_install) unless to_install.empty?


      #Start sssd only if there are more then one domain defined
      if !domains.empty?
        Service.Enable("sssd")
        Service.Disable("nscd")
        Service.Stop("nscd")
        Service.Active("sssd") ? Service.Restart("sssd") : Service.Start("sssd")
      else
        Service.Disable("sssd")
        Service.Stop("sssd")
      end
      return true
    end
    # end Write
    #################################################################

    #################################################################
    # Import()
    # Imports clients authentication configuration.
    # 
    # @return true or false
    def Import(settings)
      @auth = Hash.new(&@make_hash)

      # Read the basic settings of auth client
      settings.each_key { |s|
        next if s == "sssd_conf"
        @auth[s] = settings[s]
      }

      # Evaluate if the settings are valid
      if settings['sssd']
        # using sssd
        unless settings.has_key?('sssd_conf')
          Builtins.y2milestone("There are no sssd configuration provided but sssd is enabled.")
          return false
        else
          # Read sssd basic settings
          settings['sssd_conf'].each_key { |key|
            next if key == "auth_domains"
            @auth['sssd_conf'][key] = settings['sssd_conf'][key]
          }
          unless settings['sssd_conf'].has_key?('auth_domains')
            Builtins.y2milestone("There are no authentication domain defined")
            return false
          else
            # Read authentication domains
            settings['sssd_conf']['auth_domains'].each { |domain|
              if !domain.has_key?('domain_name')
                Builtins.y2warning("Domain has no domain_name: #{domain}")
              end
              name = 'domain/' + domain['domain_name']
              domain.each_key { |key|
                next if key == 'domain_name'
                @auth['sssd_conf'][name][key] = domain[key]
              }
            }
          end
        end
      else
        # not using sssd
        if settings.has_key?('sssd_conf') 
          Builtins.y2milestone("There are sssd configuration provided but sssd is not enabled.")
          return false
        end
        Builtins.y2milestone("Authentication will not made via sssd.")
        @auth['sssd'] = false
      end

      true
    end
    # end Import
    #################################################################

    #################################################################
    # Export()
    # Exports clients authentication configuration.
    # @return map Dumped settings (later acceptable by Import ())
    def Export

       settings = Hash.new

       #Write basic settings
       @auth.each_key { |s|
         next if s == "sssd_conf"
         settings[s] = @auth[s]
       }
       return settings if ! @auth.has_key?("sssd_conf")

       #Write sssd settings
       settings["sssd_conf"] = Hash.new
       settings["sssd_conf"]["auth_domains"] = Array.new
       @auth["sssd_conf"].each_key { |s|
          if s =~ /^domain\//
            domain = @auth["sssd_conf"][s]
            domain["domain_name"] = s.sub("domain/","")
            settings["sssd_conf"]["auth_domains"].push(domain)
          else
            settings["sssd_conf"][s] = @auth["sssd_conf"][s]
          end
       }
       return settings
    end
    # end Export
    #################################################################

    #################################################################
    # Summary()
    # returns html formated configuration summary
    # @return summary
    def Summary
      summary = "";
      if @auth["nssldap"]
         summary = _( "System is configured for using nss_ldap.\n" )
      end
      if @auth["sssd"]
         summary = _( "System is configured for using sssd.\n" )
         @auth["sssd_conf"].each_key { |sec|
           summary += "<br> In section: '" + sec + "' are following parameter defined: " + @auth["sssd_conf"][sec].keys.join(",")
         }
      end
      if @auth["oes"]
         summary = _( "System is configured for using OES.\n" )
      end
      if summary == ""
         summary = _( "System is configured for using /etc/passwd only.\n" )
      end
      summary
    end
    # end Summary
    #################################################################

    #################################################################
    # CreateBasicSSSD()
    # Create empty authentication configuration.
    def CreateBasicSSSD
       @auth["sssd"]    = true
       @auth["oes"]     = false
       @auth["nssldap"] = false
       @auth["sssd_conf"]["sssd"]["config_file_version"] = 2
       @auth["sssd_conf"]["sssd"]["services"] = "nss, pam"

       @modified        = true
    end
    #
    #################################################################

    #################################################################
    # SetModified()
    # Sets configuration modification switch
    def SetModified(value)
       @modified    = value
    end
    #
    #################################################################
    
    #################################################################
    # GetModified()
    # Returns configuration modification switch
    # @return modified
    def GetModified
       return @modified
    end
    #
    #################################################################

    publish :variable => :auth,    :type => "map"
    publish :function => :Read,    :type => "boolean ()"
    publish :function => :Write,   :type => "boolean ()"
    publish :function => :Import,  :type => "boolean ()"
    publish :function => :Export,  :type => "map ()"
    publish :function => :Summary, :type => "string ()"
    publish :function => :SetModified,     :type => "boolean ()"
    publish :function => :GetModified,     :type => "boolean ()"
    publish :function => :CreateBasicSSSD, :type => "map ()"
  end

  AuthClient = AuthClientClass.new
  AuthClient.main
end

