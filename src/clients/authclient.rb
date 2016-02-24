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

# File: clients/authclient.rb
# Module:       Configure system-wide authentication mechanisms
# Summary:      Invoke main dialog.
# Authors:      Howard Guo <hguo@suse.com>

require 'auth/authconf'
require 'authui/main_dialog'

include Auth
AuthConfInst.sssd_read
AuthConfInst.ldap_read
AuthConfInst.krb_read
AuthConfInst.aux_read
MainDialog.new.run