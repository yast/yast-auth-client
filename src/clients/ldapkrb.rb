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

# Module:       Configure system-wide authentication mechanisms via LDAP and Kerberos
# Summary:      Invoke main dialog and allow configuring LDAP and Kerberos
# Authors:      Howard Guo <hguo@suse.com>

require 'auth/authconf'
require 'authui/main_dialog'

Auth::AuthConfInst.read_all
Auth::MainDialog.new(:ldapkrb, 'LDAP and Kerberos Client').run
