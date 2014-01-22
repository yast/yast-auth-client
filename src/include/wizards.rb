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

# File: auth-client/wizards.rb
# Module:       Configuration of authentication client
# Summary:      Authentication client configuration wizards.
# Authors:      Peter Varkoly <varkoly@suse.com>
#               Christian Kornacker <ckornacker@suse.com>
#
# $Id$

module Yast
  module AuthClientWizardsInclude
    def initialize_auth_client_wizards(include_target)
      Yast.import "UI"

      textdomain "auth-client"

      Yast.import "Sequencer"
      Yast.import "Wizard"
      Yast.import "Label"
      Yast.import "Stage"

      Yast.include include_target, "auth-client/dialogs.rb"
    end
    # Whole configuration of auth-client
    # @return sequence result
    def AuthClientSequence
      aliases = {
        "read"  => [lambda { ReadDialog()  }, true],
        "main"  => [lambda { MainDialog()  }, true],
        "write" => [lambda { WriteDialog() }, true]
      }

      sequence = {
        "ws_start" => "read",
        "read"     => { :abort => :abort, :next => "main" },
        "main"     => { :abort => :abort, :next => "write" },
        "write"    => { :abort => :abort, :next => :next }
      }

      if Stage.cont
        Wizard.CreateDialog
      else
        Wizard.OpenNextBackDialog
        Wizard.HideAbortButton
      end
      Wizard.SetDesktopTitleAndIcon("auth-client")

      ret = Sequencer.Run(aliases, sequence)

      UI.CloseDialog
      Convert.to_symbol(ret)
    end

  end
end
