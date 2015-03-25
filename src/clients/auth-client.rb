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

# File: clients/auth-client.rb
# Module:       Configuration of authentication client
# Summary:      Client file, including commandline handlers
# Authors:      Peter Varkoly <varkoly@suse.com>
#               Christian Kornacker <ckornacker@suse.com>
#

#**
# <h3>Configuration of the authentication client</h3>

require "yauthclient/main_dialog.rb"

module Yast
  class AuthClientCmd < Client
    def main
      textdomain  "auth-client"
      Yast.import "AuthClient"
      Yast.import "CommandLine"
      Yast.import "RichText"

      @ret = :auto

      # the command line description map
      @cmdline = {
        "id"         => "auth-client",
        # translators: command line help text for authentication client module
        "help"       => _(
          "Authentication client configuration module"
        ),
	"guihandler" => fun_ref(method(:AuthClientSequence),    "symbol ()"),
	"initialize" => fun_ref(AuthClient.method(:Read), "boolean ()"),
        "finish"     => fun_ref(AuthClient.method(:Write),"boolean ()"),
        "actions"    => {
          "summary"   => {
            "handler" => fun_ref(method(:SummaryHandler), "boolean (map)"),
            # translators: command line help text for summary action
            "help"    => _("Configuration summary of the authentication client")
          },
          "autoyast-rnc"   => {
            "handler" => fun_ref(method(:AutoyastRnc), "boolean (map)"),
            # translators: command line help text for summary action
            "help"    => _("Create autoyast rnc from @parameters")
          }
	}

      }
      @ret = CommandLine.Run(@cmdline)
      deep_copy(@ret)
    end

    # Print summary of basic options
    # @return [Boolean] false
    def SummaryHandler(options)
      options = deep_copy(options)
      CommandLine.Print(RichText.Rich2Plain(Ops.add("<br>", AuthClient.Summary)))
      false # do not call Write...
    end

    def AutoyastRnc(options)
        options = deep_copy(options)
        sections = "";
        cont = 'default namespace = "http://www.suse.com/1.0/yast2ns"
namespace a = "http://relaxng.org/ns/compatibility/annotations/1.0"
namespace config = "http://www.suse.com/1.0/configns"
auth-client =
  element auth-client {
     element nssldap { BOOLEAN }? &
     element sssd    { BOOLEAN }? &
     element oes     { BOOLEAN }? &
     sssd_conf?
}

sssd_conf =
  element sssd_conf {
'
       @params.each_key { |s|
          cont += "     "+s+"? &\n"
	  sections += s + " =\n  element " + s + " {\n"
          @params[s].each_key { |k|
	    case @params[s][k]["type"]
	      when "bool"
	        sections += "    element " + k + "{ BOOLEAN }? &\n"
	      when "int"
	        sections += "    element " + k + "{ INTEGER }? &\n"
	      else
	        sections += "    element " + k + "{ text }? &\n"
	    end
	  }
	  sections += "  }\n"
       }
       cont = cont + "}\n" + sections
       CommandLine.Print(cont)
    end

  end
end
YAuthClient::MainDialog.new.run

