# Sources for auth-client

module_DATA = \
  modules/AuthClient.rb

client_DATA = \
  clients/auth-client.rb \
  clients/auth-client_auto.rb

yncludedir = @yncludedir@/auth-client
ynclude_DATA = \
  include/wizards.rb \
  include/dialogs.rb \
  include/sssd-parameters.rb

scrconf_DATA = \
  scrconf/nscd_conf.scr

schemafilesdir = $(schemadir)/autoyast/rnc
schemafiles_DATA = \
  autoyast-rnc/auth-client.rnc

desktop_DATA = \
  desktop/auth-client.desktop

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(scrconf_DATA) $(schemafiles_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common

