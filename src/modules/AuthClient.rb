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
require "inifile"

module Yast
  class AuthClientClass < Module
    def main
      textdomain  "auth-client"
      Yast.import "Nsswitch"
      Yast.import "Package"
      Yast.import "Pam"
      Yast.import "Service"

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

      @nss_dbs     = ["passwd", "group", "passwd_compat", "group_compat", "services", "netgroup", "aliases"]
      @sss_dbs     = ["passwd", "group" ]

      #IniFile
      @sssd_conf   = nil

      # the auth configuration
      make_hash = proc do |hash,key|
         hash[key] = Hash.new(&make_hash)
      end
      @auth = Hash.new(&make_hash)

    end

    # Check if current machine runs OES
    def CheckOES
      @oes = Package.Installed("NOVLam")
      @oes
    end

    #################################################################
    # Read()
    # Reads the clients authentication configuration.
    # @return true or false
    def Read

      #Check if oes is used in nss
      @auth["oes"]  = CheckOES()

      #Check if ldap is used in nss
      @nss_dbs.each { |db|
        @nsswitch[db] = Nsswitch.ReadDb(db)
      }
      @auth["nssldap"] =   @nsswitch["passwd"].include?("ldap") ||
      			 ( @nsswitch["passwd"].include?("ldap") && @nsswitch["passwd_compat"].include?("ldap") ) ||
                         ( @auth["oes"] && @nsswitch["passwd"].include?("nam") )

      #Check if sssd is used in nss
      @auth["sssd"] = @nsswitch["passwd"].include?("sss")

      if @auth["sssd"]
         @sssd_conf = IniFile.load('/etc/sssd/sssd.conf' )
         @sssd_conf.each do |section, parameter, value|
             @auth["ssd_conf"][section][parameter] = value
         end
      end
      #Builtins.y2milestone("nssldap: %1; sssd: %2; oes: %3",@auth["nssldap"],@auth["sssd"],@auth["oes"])
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
      if ! @sssd
        # Nothing to do
        return true
      end
      domains  = []
      services = []
      filter_groups = []
      filter_users  = []

      #Add sss to pam
      Pam.Add("sss")

      #Remove ldap only nss databases
      @nss_dbs.each { |db|
        @nsswitch[db] = Nsswitch.ReadDb(db).select{ |v| v =~ /ldap/ }
	@nsswitch[db] = ["files"] if @nsswitch[db] == []
      }

      # Add "sss" to the passwd and group databases in nsswitch.conf
      @sss_dbs.each { |db|
        @nsswitch[db].push("sss") if ! @nsswitch[db].include?("sss")
      }

      # Write the new nss tables
      @nss_dbs.each { |db|
         Nsswitch.WriteDb(db,@nsswitch[db])
      }
      Nsswitch.Write

      #Remove kerberos if activated
      if Pam.Enabled("krb5")
        Builtins.y2milestone(
          "configuring 'sss', so 'krb5' will be removed"
        )
        Pam.Remove("ldap-account_only")
        Pam.Remove("krb5")
      end
      Pam.Remove("ldap")

      if @auth["sssd_conf"]["sssd"].has_key?("services")
	 services = @auth["sssd_conf"]["sssd"]["services"].split(%r{,\s*})
      end

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
      @auth["sssd_conf"]["nss"]["filter_users"]  = filter_users,join(", ")
      @auth["sssd_conf"]["nss"]["filter_groups"] = filter_groups,join(", ")

      #Now we write the nss configuration
      nss = @sssd_conf["nss"];
      @auth["ssd_conf"].each_key {
      }
    end
    # end Write
    #################################################################

    #################################################################
    # Import()
    # Imports clients authentication configuration.
    # @return true or false
    def Import(settings)
      @auth = settings
      true
    end
    # end Import
    #################################################################

    #################################################################
    # Export()
    # Exports clients authentication configuration.
    # @return true or false
    def Export
      deep_copy(@auth)
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
         @sssd_conf.each_section do |section|
           summary += "<br>" + section.to_s
         end
      end
      if @auth["oes"]
         summary = _( "System is configured for using OES.\n" )
      end
      if summary == ""
         summary = _( "System is configured for using /etc/passwd only\n" )
      end
      @sssd_conf.write(:filename => "/tmp/sssd.conf")
      summary
    end
    # end Summary
    #################################################################

    publish :variable => :auth,    :type => "map"
    publish :function => :Summary, :type => "string ()"
    publish :function => :Read,    :type => "boolean ()"
    publish :function => :Write,   :type => "boolean ()"
  end

  AuthClient = AuthClientClass.new
  AuthClient.main
end

