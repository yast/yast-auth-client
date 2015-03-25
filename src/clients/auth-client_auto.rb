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

# File: clients/auth-client_auto.ycp
# Module:       Configuration of authentication client
# Summary:      Client file, including commandline handlers
# Authors:      Peter Varkoly <varkoly@suse.com>
#               Christian Kornacker <ckornacker@suse.com>
#
# This is a client for autoinstallation. It takes its arguments,
# goes through the configuration and return the setting.
# Does not do any changes to the configuration.

# @param first a map of authentication settings
# @return [Hash] edited settings or an empty map if canceled
# @example map mm = $[ "FAIL_DELAY" : "77" ];
# @example map ret = WFM::CallModule ("auth-client_auto", [ mm ]);

module Yast
  class AuthClientAuto < Client
    def main
      textdomain "auth-client"
      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("auth-client auto started")
      Yast.import "AuthClient"
      @ret = nil
      @func = ""
      @param = {}

      # Check arguments
      if Ops.greater_than(Builtins.size(WFM.Args), 0) &&
          Ops.is_string?(WFM.Args(0))
        @func = Convert.to_string(WFM.Args(0))
        if Ops.greater_than(Builtins.size(WFM.Args), 1) &&
            Ops.is_map?(WFM.Args(1))
          @param = Convert.to_map(WFM.Args(1))
        end
      end
      #TODO make y2debug if it works correctly
      Builtins.y2milestone("func=%1",  @func)
      Builtins.y2milestone("param=%1", @param)
      case @func
        when "Import"
          @ret = AuthClient.Import(@param)
        when "Summary"
          @ret = AuthClient.Summary()
        when "Reset"
          AuthClient.Import({})
          AuthClient.SetModified(false)
          @ret = {}
        when "Change"
          AuthClient.SetModified(true)
        when "Export"
          @ret = AuthClient.Export
        when "Read"
          AuthClient.Read
          @ret = AuthClient.Export
        when "GetModified"
          @ret = AuthClient.GetModified
        when "SetModified"
          AuthClient.SetModified(true)
          @ret = true
        when "Write"
          AuthClient.Write
        when "Packages"
          @ret = { "install" => ["sssd","krb5-client" ], "remove" => [] }
        else
          Builtins.y2error("Unknown function: %1", @func)
          @ret = false
      end
      Builtins.y2debug("ret=%1", @ret)
      Builtins.y2milestone("AuthClient auto finished")
      Builtins.y2milestone("----------------------------------------")

      deep_copy(@ret)
    end
  end
end

Yast::AuthClientAuto.new.main
