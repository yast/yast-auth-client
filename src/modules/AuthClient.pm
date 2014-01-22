#! /usr/bin/perl -w
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

# File: modules/AuthClient.pm
# Module:       Configuration of authentication client
# Summary:      Authentication client configuration data, I/O functions.
# Authors:      Peter Varkoly <varkoly@suse.com>
#               Christian Kornacker <ckornacker@suse.com>
#
# $Id$
package AuthClient;

use strict;
use ycp;
use YaST::YCP;
use YaPI;
use Data::Dumper;
use Config::IniFiles;
our %TYPEINFO;

YaST::YCP::Import("Mode");
YaST::YCP::Import("Nsswitch");
YaST::YCP::Import("Package");
YaST::YCP::Import("Pam");
YaST::YCP::Import("Service");

textdomain("auth-client");

# stored values of /etc/nsswitch.conf
my $nsswitch = {
  "passwd"        => [],
  "group"         => [],
  "passwd_compat" => [],
  "group_compat"  => [],
  "automount"     => []
};
my @nss_dbs     = ("passwd", "group", "passwd_compat", "group_compat");
my @sss_dbs     = ("passwd", "group" );
my $auth        = {};
my $sssd_conf   = undef;

#################################################################
# INTERNAL FUNCTIONS:
# check if given key (second parameter) is contained in a list (1st parameter)
# if 3rd parameter is true (>0), ignore case
sub contains {
    my ($key, $list, $ignorecase) = @_;
    if (!defined $list || ref ($list) ne "ARRAY" || @{$list} == 0) {
        return 0;
    }
    if ($ignorecase) {
        if ( grep /^\Q$key\E$/i, @{$list} ) {
            return 1;
        }
    } else {
        if ( grep /^\Q$key\E$/, @{$list} ) {
            return 1;
        }
    }
    return 0;
}

sub CheckOES
{
    return Package->Installed("NOVLam");
}
# END INTERNAL FUNCTIONS:
#################################################################

#################################################################
# Read()
# Reads the clients authentication configuration.
# @return true or false
BEGIN { $TYPEINFO{Read} = ["function", "boolean"]; }
sub Read
{
    my $self = shift;
    #Check if oes is used in nss
    $auth->{"oes"}  = CheckOES();
    
    #Check if ldap is used in nss
    foreach my $db (@nss_dbs)
    {
      $nsswitch->{$db} = Nsswitch->ReadDb($db);
    }
    $auth->{"nssldap"} = contains("ldap",$nsswitch->{passwd}) || 
                       ( contains("compat",$nsswitch->{passwd}) && contains("compat",$nsswitch->{passwd_compat}) ) ||
                       ( $auth->{"oes"} && contains("nam",$nsswitch->{passwd} ) ); 
    
    #Check if sssd is used in nss
    $auth->{"sssd"} = contains("sss",$nsswitch->{passwd});
    
    if( $auth->{"sssd"})
    {
       $sssd_conf = Config::IniFiles->new( -file => "/etc/sssd/sssd.conf" );
       foreach my $s ( $sssd_conf->Sections )
       {
           foreach my $p ( $sssd_conf->Parameters($s) )
           {
	       $auth->{"sssd_conf"}->{$s}->{$p} = $sssd_conf->val($s,$p);
           }
       }
    }
    y2milestone("nssldap: ".$auth->{"nssldap"}." sssd: ".$auth->{"sssd"}." oes: ".$auth->{"oes"});
    return 1;
}
# end Read()
#################################################################

#################################################################
# Write()
# Writes the clients authentication configuration.
# @return true or false
BEGIN { $TYPEINFO{Write} = ["function", "boolean"]; }
sub Write
{
  my $self = shift;
  if( ! $auth->{"sssd"} ) 
  {
    # Nothing to do
    return 1
  }  
y2milestone("Auth Hash after editing".Dumper($auth));
  #Activate pam sss
  Pam->Add("sss");
  foreach my $db (@sss_dbs)
  {
    push @{$nsswitch->{$db}}, 'sss' if( !contains('sss',$nsswitch->{$db}));
  }
  foreach my $db (@nss_dbs)
  {
    $nsswitch->{$db} = Nsswitch->ReadDb($db);
    my @tmp = grep(!/^ldap/,@{$nsswitch->{$db}});
    $nsswitch->{$db} = \@tmp;
  }
  foreach my $db (@nss_dbs)
  {
    Nsswitch->WriteDb($db,$nsswitch->{$db});
  }
  #Activate deactivate automount in nssswitch
  my @services = split /,\s*/, $auth->{"sssd_conf"}->{"sssd"}->{"services"};
  my @domains  = split /,/, $auth->{"sssd_conf"}->{"sssd"}->{"domains"};
  if( contains( "autofs", \@services ) && scalar @domains )
  {
     my $db = "automount";
     $nsswitch->{$db} = Nsswitch->ReadDb($db);
     my @tmp  = grep(!/^ldap/,@{$nsswitch->{$db}} );
     push @{$nsswitch->{$db}}, 'sss' if( !contains('sss',$nsswitch->{$db}));
     Nsswitch->WriteDb($db,$nsswitch->{$db});
  }
  else
  {
     my $db = "automount";
     $nsswitch->{$db} = Nsswitch->ReadDb($db);
     my @tmp  = grep(!/^sss/,@{$nsswitch->{$db}} );
     Nsswitch->WriteDb($db,$nsswitch->{$db});
  }
  Nsswitch->Write();
  
  #Be shure filter_groups and filter_users contains root in nss section
  my @filter_groups = split /,/, $auth->{"sssd_conf"}->{"nss"}->{"filter_groups"};
  my @filter_users  = split /,/, $auth->{"sssd_conf"}->{"nss"}->{"filter_users"};
  push @filter_groups, "root" if( ! contains("root",\@filter_groups));
  push @filter_users,  "root" if( ! contains("root",\@filter_users));
  $auth->{"sssd_conf"}->{"nss"}->{"filter_groups"} = join(",",@filter_groups);
  $auth->{"sssd_conf"}->{"nss"}->{"filter_users"}  = join(",",@filter_users);
  foreach my $s ( keys %{$auth->{"sssd_conf"}} )
  {
    if( defined $auth->{"sssd_conf"}->{$s}->{DeleteSection} )
    {
      $sssd_conf->DeleteSection($s);
      next;
    }
    $sssd_conf->AddSection($s) if( ! $sssd_conf->SectionExists($s) );
    foreach my $p ( keys %{$auth->{"sssd_conf"}->{$s}} )
    {
       if( "##DeleteValue##" eq $auth->{"sssd_conf"}->{$s}->{$p} )
       {
          $sssd_conf->delval( $s, $p );
	  next;
       }
       if( ! $sssd_conf->exists( $s, $p ) )
       {
          $sssd_conf->newval( $s, $p, $auth->{"sssd_conf"}->{$s}->{$p} );
       }
       else
       {
          $sssd_conf->setval( $s, $p, $auth->{"sssd_conf"}->{$s}->{$p} );
       }
    }
  }
  $sssd_conf->RewriteConfig();
  #Enable autofs only if there is min one domain activated and autofs service is enabled
  if( contains( "autofs", \@services ) && scalar @domains )
  {
    Service->Enable("autofs");
    Service->Restart("autofs");
  }
  else
  {
    Service->Disable("autofs");
    Service->Stop("autofs");
  }
  #Enable sssd only if there is min one domain activated
  if( scalar @domains ) {
    Service->Enable("sssd");
    Service->Restart("sssd");
  }
  else
  {
    Service->Disable("sssd");
    Service->Stop("sssd");
  }
}
# end Write
#################################################################

#################################################################
# Import()
# Imports clients authentication configuration.
# @return true or false
BEGIN { $TYPEINFO{Import} = ["function", "boolean", [ "map", "any", "any" ] ]; }
sub Import {
    my $self = shift;
    my $hash = shift;
    $auth = $hash;
    return 1;
}
# end Import
#################################################################

#################################################################
# Export()
# Exports clients authentication configuration.
# @return map Dumped settings (later acceptable by Import ())
BEGIN { $TYPEINFO{Export}  =["function", [ "map", "any", "any" ] ]; }
sub Export {
    my $self = shift;
    return $auth;  
}
# end Export
#################################################################

#################################################################
# CreateBasicSSSD()
# Create clients authentication configuration.
# @return map Dumped settings (later acceptable by Import ())
BEGIN { $TYPEINFO{CreateBasicSSSD}  =["function", [ "map", "any", "any" ] ]; }
sub CreateBasicSSSD {
    my $self = shift;
    $auth->{"sssd"}    = YaST::YCP::Boolean (1);
    $auth->{"oes"}     = YaST::YCP::Boolean (0);
    $auth->{"nssldap"} = YaST::YCP::Boolean (0);
    $auth->{"sssd_conf"}->{"sssd"}->{"config_file_version"} = "2";
    $auth->{"sssd_conf"}->{"sssd"}->{"servics"}             = "nss, pam";
    return $auth;  
}
# end Export
#################################################################

#################################################################
# Summary()
# returns html formated configuration summary
# @return summary
BEGIN { $TYPEINFO{Summary} = ["function", "string" ]; }
sub Summary {
    my $self = shift;
    my $summary = "";
    if( $auth->{"nssldap"} )
    {
       $summary = _( "System is configured for using nss_ldap.\n" );
    }
    if( $auth->{"sssd"} )
    {
       $summary = _( "System is configured for using sssd.\n" );
       $summary .= '<br>'.Dumper($auth->{"sssd_conf"});
    }
    if( $auth->{"oes"} )
    {
       $summary = _( "System is configured for using OES.\n" );
    }   
    if( $summary eq "" )
    {
       $summary = _( "System is configured for using /etc/passwd only\n" );
    }   
    return $summary;
}
# end Summary
#################################################################

1;
