# encoding: utf-8

# File: auth-client/dialogs.rb
# Package:      Configuration of authentication client
# Summary:      Definition of dialogs
# Authors:      Peter Varkoly <varkoly@suse.de>
#                Christian Kornacker <ckornacker@suse.com>
#

module Yast
  module AuthClientDialogsInclude
    def initialize_auth_client_dialogs(include_target)
      textdomain "auth-client"

      Yast.import "AuthClient"
      Yast.import "Label"
      Yast.import "Mode"
      Yast.import "Popup"

      Yast.include include_target, "auth-client/sssd-parameters.rb"
      @MAXINT = 10000000000000
      # the auth configuration
      make_hash = proc do |hash,key|
         hash[key] = Hash.new(&make_hash)
      end
      AuthClient.auth = Hash.new(&make_hash)

    end

    def DeleteDomain
        _Domain = Convert.to_string( UI.QueryWidget(Id(:domains), :CurrentItem))
        _name   = _Domain.gsub("domain/","")
        if ! Popup.YesNo( Builtins.sformat(_("Do you really want to delete the domain '%1'?" ),_name) )
           return
        end
        if AuthClient.auth["sssd_conf"]["sssd"].has_key?("domains")
           domains = AuthClient.auth["sssd_conf"]["sssd"]["domains"].split(%r{,\s*})
           domains = domains.select { |a| a != _name } 
           AuthClient.auth["sssd_conf"]["sssd"]["domains"] = domains.join(", ")
        end
        AuthClient.auth["sssd_conf"][_Domain]["DeleteSection"] = true
    end

    def HelpForParameter(parameters)
        _help=""
        parameters.each { |parameter|
            _desc = GetDescription(parameter)
            if _desc.empty?
                _help = _help + _("There is no help for this parameter.") + parameter
            else
                    _help = _help + "\n" + parameter + ":\n" + _desc
            end
            _default = GetParameterDefault(parameter)
            if _default != ""
                _help = _help + "\n" + _("Default value: ") + String(_default)
            end
            _values = GetParameterValues(parameter)
            if _values != []
                _help = _help + "\n" + _("Available values: ") + _values.join(", ")
            end
            _help = _help + "\n"
        }
        Popup.Message(_help)
    end

    def GetDescription(parameter)
        @params.each_key { |s|
          if @params[s][parameter] && @params[s][parameter].has_key?("desc")
             return @params[s][parameter]["desc"]
          end
        }
        return ""
    end

    def GetParameterType(parameter)
        @params.each_key { |s|
           if @params[s][parameter] && @params[s][parameter].has_key?("type")
              return @params[s][parameter]["type"]
           end
        }
        return "string"
    end

    def GetParameterDefault(parameter)
        @params.each_key { |s|
	  if @params[s][parameter] && @params[s][parameter].has_key?("def")
	     return @params[s][parameter]["def"]
	  end
        }
        return ""
    end

    def GetParameterValues(parameter)
        @params.each_key { |s|
	  if @params[s][parameter] && @params[s][parameter].has_key?("vals")
             return @params[s][parameter]["vals"].split(%r{,\s*})
          end
        }
        return []
    end

    def ConvertToString(item,parameter)
        _type = GetParameterType(parameter)
        case _type
            when "bool"
                if Convert.to_boolean(UI.QueryWidget(Id(item),:Value))
                   return "True"
                else
                   return "False"
                end
            else 
                return UI.QueryWidget(Id(item),:Value)
        end
    end

    def ValidateInput(item,parameter)
        @params.each_key { |s|
	  if @params[s][parameter] && @params[s][parameter].has_key?("rule")
             return ConvertToString(item,parameter) =~ @params[s][parameter]["rule"]
          end
        }
        return true
    end

    def AddParameter(section,parameter)
        Builtins.y2milestone("--Add Parameter %1 in section %2 called",parameter,section)
        _type = GetParameterType(parameter)
        _def  = GetParameterDefault(parameter)
        _term = VBox()
        case _type 
          when "int"
             _term.params << Left( IntField( Id(:value), parameter, 0, @MAXINT, _def.to_i ))
          when "bool"
             if _def =~ /1|true/i
                _term.params << Left( CheckBox( Id(:value), parameter, true ))
             else   
                _term.params << Left( CheckBox( Id(:value), parameter, false ))
             end   
          when "string"
             _term.params << Left( InputField( Id(:value), Opt(:hstretch), parameter, _def))
        end
        #No we open the dialog
        UI.OpenDialog(
                Opt(:decorated),
                VBox(
                        Frame( Builtins.sformat(_("Set Parameter Value in Section '%1'"), section), _term ),
                        ButtonBox(
                          PushButton(Id(:cancel), _("Cancel")),
                          PushButton(Id(:ok),     _("OK"))
                        )
                )
        )
        #Waiting for response
        ret = nil
        while ret != :cancel && ret != :ok
          event = UI.WaitForEvent
          ret = Ops.get(event, "ID")
          case ret
            when :cancel
               break
            when :ok
                if !AuthClient.auth["sssd_conf"].has_key?(section)
                    AuthClient.auth["sssd_conf"][section] = Hash.new
                end
                if ValidateInput(:value,parameter)
                  AuthClient.auth["sssd_conf"][section][parameter] = ConvertToString(:value,parameter)
                else
                  Popup.Error( Builtins.sformat(_("Value for parameter '%1' is invalid."), parameter))
                  ret = nil
                end
                break
          end
        end
        UI.CloseDialog
        return ret
    end

    def SelectParameter(section)
        _pars = []
        if section =~ /^domain/
            _id_provider   = nil 
            _auth_provider = nil
            if AuthClient.auth["sssd_conf"][section].has_key?("id_provider")
               _id_provider = AuthClient.auth["sssd_conf"][section]["id_provider"]
            end   
            if AuthClient.auth["sssd_conf"][section].has_key?("auth_provider")
               _auth_provider = AuthClient.auth["sssd_conf"][section]["auth_provider"]
            end
            if !_id_provider.nil?
               _pars.concat( @params[_id_provider].keys )
            end
            if !_auth_provider.nil? && _id_provider != _auth_provider
               _pars.concat( @params[_auth_provider].keys )
            end
            _pars.concat( @params["domain"].keys )
        else
           _pars.concat( @params[section].keys )
        end
        if _pars == []
            Popup.Warning( Builtins.sformat(_("Section '%1' has no attributes."), section) )
            return true
        end
        _pars = _pars.select { |a| a !~ /^$/ }
        if AuthClient.auth["sssd_conf"].has_key?(section)
            #List only not exisstent parameter
            _pars = _pars.select { |a| ! AuthClient.auth["sssd_conf"][section].has_key?(a) }
        end
        #No we open the dialog
        UI.OpenDialog(
                Opt(:decorated),
                VBox(
                        Label(Builtins.sformat(_("Select new Parameter for section '%1'"), section)),
                        SelectionBox(
                          Id(:parameter),
                          _(""),
                          _pars.sort
                        ),
                        HBox(
                          Label(_("Quick Filter:")),
                          InputField(Id(:quickfilter), Opt(:hstretch, :notify), ""),
                        ),
                        ButtonBox(
                          PushButton(Id(:cancel), _("Cancel")),
                          PushButton(Id(:help),   _("Help")),
                          PushButton(Id(:ok),     _("OK"))
                        )
                )
        )
        #Waiting for response
        ret = nil
        while ret != :cancel && ret != :ok
          event = UI.WaitForEvent
          ret = Ops.get(event, "ID")
          case ret
            when :quickfilter
              filter_words = UI.QueryWidget(Id(:quickfilter), :Value).split(%r{\W|_})
              _filterpars = _pars.select do |par_name|
                par_words = par_name.split(%r{\W|_})
                # The wording of SSSD parameters is not straight forward
                # Therefore the quick filter tries to be more helpful by using these filter rules:
                # - Parameter name shall contain all filter words except the last filter word
                # - One of the words in the parameter name shall contain the last filter word
                # The mechanism improves matching quality, e.g.
                # ldap_service_object_class will show up when filter is "ldap_object"
                if filter_words.length == 1
                  par_words.any? { |word| word.include? filter_words[0] }
                elsif filter_words.length > 1
                  (filter_words[0..-2] - par_words).empty? and par_words.any? { |word| word.include? filter_words[-1] }
                else
                  true
                end
              end
              UI.ChangeWidget(Id(:parameter), :Items, _filterpars.sort)
            when :cancel
               break
            when :help
                HelpForParameter( [ Convert.to_string(UI.QueryWidget(Id(:parameter),:CurrentItem)) ])
            when :ok
               ret = AddParameter(section,Convert.to_string(UI.QueryWidget(Id(:parameter),:CurrentItem)))
          end
        end
        UI.CloseDialog
        return ret
    end

    def MakeSelectedList(list,value)
	return list.map { |k| k == value ? Item(Id(k),k,true) : Item(Id(k),k) }
    end

    def BuildSection(section)
        _term = VBox()
        #Empy section
        return _term if ! AuthClient.auth["sssd_conf"].has_key?(section)

        _params = AuthClient.auth["sssd_conf"][section].keys

        #Check if a domain have all its obligatory parameter
        _id_provider   = nil
        _auth_provider = nil
        if AuthClient.auth["sssd_conf"][section].has_key?("id_provider")
           _id_provider = AuthClient.auth["sssd_conf"][section]["id_provider"]
           @params[_id_provider].each_key { |k| 
             if @params[_id_provider][k].has_key?("req") && ! _params.include?(k)
               AuthClient.auth["sssd_conf"][section][k] = GetParameterDefault(k)
               _params.push(k)
             end
           }
        end
        if AuthClient.auth["sssd_conf"][section].has_key?("auth_provider")
           _auth_provider = AuthClient.auth["sssd_conf"][section]["auth_provider"]
           @params[_auth_provider].each_key { |k| 
             if @params[_auth_provider][k].has_key?("req") && ! _params.include?(k)
               AuthClient.auth["sssd_conf"][section][k] = GetParameterDefault(k)
               _params.push(k)
             end
           }
        end
        _params.each { |k|
           type = GetParameterType(k)
           v    = AuthClient.auth["sssd_conf"][section][k]
           vals = GetParameterValues(k)
           case type 
             when "int"
                _term.params << Left( IntField( Id(k), k, 0, @MAXINT, v.to_i ))
             when "bool"
                if v =~ /1|true/i
                   _term.params << Left( CheckBox( Id(k), k, true ))
                else   
                   _term.params << Left( CheckBox( Id(k), k, false ))
                end   
             when "string"
                if vals.empty?
                   _term.params << Left( InputField(Id(k), Opt(:hstretch), k, v))
                else
                   _term.params << Left( ComboBox(Id(k),k, MakeSelectedList(vals,v)))
                end
           end
        }
        return _term
    end

    def ConfigureSection(section)

        #No we open the dialog
        UI.OpenDialog(
                Opt(:decorated),
                VBox(
                        Frame( Builtins.sformat(_("Edit sssd section '%1'"), section),
                                ReplacePoint(Id(:rep_params), BuildSection(section) )
                        ),
                        ButtonBox(
                          PushButton(Id(:cancel), _("Cancel")),
                          PushButton(Id(:help),   _("Help")),
                          PushButton(Id(:add),    _("New")),
                          PushButton(Id(:ok),     _("OK"))
                        )
                )
        )
        #Waiting for response
        ret = nil
        while ret != :cancel && ret != :ok
          event = UI.WaitForEvent
          ret = Ops.get(event, "ID")
          case ret
            when :cancel
               break
            when :help
                    HelpForParameter(AuthClient.auth["sssd_conf"][section].keys)
            when :add
               ret = SelectParameter(section)
               if ret == :ok
                   UI.ReplaceWidget(Id(:rep_params), BuildSection(section) )
               end
               ret = nil
            when :ok
                AuthClient.auth["sssd_conf"][section].each_key { |k|
                  if ValidateInput(k,k)
                    AuthClient.auth["sssd_conf"][section][k] = ConvertToString(k,k)
                  else
                    Popup.Error( Builtins.sformat(_("Value for parameter '%1' is invalid."), k))
                    ret = nil
                  end
                }
          end
        end
        UI.CloseDialog
    end

    def ReadDialog
      Builtins.y2milestone("--Start AuthClient ReadDialog ---")
      ret = AuthClient.Read
      ret ? :next : :abort
    end

    def AddDomain
        UI.OpenDialog( Opt(:decorated),
                VBox(
                    Frame( _("Add New Domain"),
                        VBox(
                           InputField( Id(:name), Opt(:hstretch), _("Name:"),"" ),
                           Left( CheckBox( Id(:activate), _("Activate Domain"), true ) ),
                           SelectionBox( Id(:id_provider),
                             _("The identification provider used for the domain"),
                             GetParameterValues("id_provider")
                           ),
                           SelectionBox( Id(:auth_provider),
                             _("The authentication provider used for the domain"),
                             ["default"] + GetParameterValues("auth_provider")
                           )
                        )
                    ),
                    ButtonBox(
                      PushButton(Id(:cancel), _("Cancel")),
                      PushButton(Id(:help),   _("Help")),
                      PushButton(Id(:ok),     _("OK"))
                    )
                )
        )
        #Waiting for response
        ret = nil
        while ret != :cancel && ret != :ok
          event = UI.WaitForEvent
          ret = Ops.get(event, "ID")
          case ret
            when :cancel
               break
            when :help
                #TODO
                Popup.Message(_("Help for creating new domain"))
            when :ok
                    dname = Convert.to_string(UI.QueryWidget(Id(:name), :Value))
                if dname.empty?
                        Popup.Error(_("You have to provide a domain name!"))
                        ret = nil
                else
                   name  = "domain/" + dname
                   AuthClient.auth["sssd_conf"][name] = Hash.new
                   AuthClient.auth["sssd_conf"][name]["id_provider"] =   UI.QueryWidget(Id(:id_provider),:CurrentItem)
                   auth_provider = UI.QueryWidget(Id(:auth_provider),:CurrentItem)
                   if auth_provider != "default"
                      AuthClient.auth["sssd_conf"][name]["auth_provider"] = auth_provider
                   end   
                   if Convert.to_boolean(UI.QueryWidget(Id(:activate),:Value))
                      if ! AuthClient.auth["sssd_conf"]["sssd"].has_key?("domains")
                          AuthClient.auth["sssd_conf"]["sssd"]["domains"]= dname
                      else
                          AuthClient.auth["sssd_conf"]["sssd"]["domains"] = AuthClient.auth["sssd_conf"]["sssd"]["domains"]  + ", "+ dname
                      end
                   end
		   #The default ldap schema rfc2307 is deprecated use rfc2307bis
		   AuthClient.auth["sssd_conf"][name]["ldap_schema"] = 'RFC2307bis' if AuthClient.auth["sssd_conf"][name]["id_provider"] == "ldap"
                   ConfigureSection(name)
                   Builtins.y2milestone("auth %1", AuthClient.auth)
                end
          end
        end
        UI.CloseDialog
        return ret
    end

    def CreateServices
        _term = VBox()
        _term.params << Left(Label(_("Basic Settings:")))
        _term.params << Left(PushButton(Id(:sssd), "&sssd"))
        _term.params << Left(Label(_("Services:")))
        if AuthClient.auth["sssd_conf"]["sssd"].has_key?("services")
          _services = AuthClient.auth["sssd_conf"]["sssd"]["services"].split(%r{,\s*})
          _term.params << Left(PushButton(Id(:nss),    "&nss"))    if _services.include?("nss")
          _term.params << Left(PushButton(Id(:pam),    "&pam"))    if _services.include?("pam")
          _term.params << Left(PushButton(Id(:sudo),   "&sudo"))   if _services.include?("sudo")
          _term.params << Left(PushButton(Id(:autofs), "&autofs")) if _services.include?("autofs")
          _term.params << Left(PushButton(Id(:ssh),    "&ssh"))    if _services.include?("ssh")
        end
        _term.params << Left( CheckBox( Id(:mkhomedir), Opt(:notify), _("Create Home Directory on Login"),  AuthClient.auth["mkhomedir"] ))
        _term
    end

    def ListDomains
        _domains = AuthClient.auth["sssd_conf"].keys;
        _domains = _domains.select { |a| a =~ /^domain/ }
        _domains = _domains.select { |a| ! AuthClient.auth["sssd_conf"][a].has_key?("DeleteSection") }
        _domains
    end

   def CheckSettings
       _ret = :next
       _inactive_domains = [] # List of domain which ar defined but not activated
       _active_domains = 0    # Count of active domains 
       _domains = ListDomains()

       if _domains != []
          if AuthClient.auth["sssd_conf"]["sssd"].has_key?("domains")
             _acd = []
             AuthClient.auth["sssd_conf"]["sssd"]["domains"].split(%r{,\s*}).each { |d| 
                _acd.push("domain/"+d)
             }
             _domains.each { |d| 
               if ! _acd.include?(d)
                        _inactive_domains.push(d)
               else
                     _active_domains = _active_domains + 1
               end
             }
          end
          if _active_domains == 0
             if ! Popup.YesNo( _("There are no activated domains in the [sssd] section.\n" +
                                 "sssd will not be started. Only local authentication will be available.\n" +
                                 "Do you want to write this configuration?"));
                 return :go_on
             end
          end
          if _inactive_domains != []
		# TRANSLATORS: %s stands for list of inactive domains
             if ! Popup.YesNo( _("There are some domains you have not activated:\n" +
				   "%s \n" +
				 "Do you want to write this configuration?") % _inactive_domains.join(", ")
                               )
                 return :go_on
             end
          end
       end
       _ret
    end

    def MainDialog
      Builtins.y2milestone("--Start AuthClient MainDialog ---")
      if AuthClient.auth["nssldap"] && ! Mode.autoinst
          if ! Popup.YesNo(
            _( "Your system is configured for using nss_ldap.\n" +
           "This module is designed to configure your system via sssd.\n" +
           "If you continue, your nss_ldap configuration will be removed.\n" +
           "Do you want to continue?" )
          )
            return :abort
          end
      end
      if AuthClient.auth["oes"] && ! Mode.autoinst
          if ! Popup.YesNo(
            _( "Your system is configured as OES client.\n" +
           "This module is designed to configure your system via sssd.\n" +
           "If you continue, your OES client configuration will be deactivated.\n" +
           "Do you want to continue?" )
          )
            return :abort
          end
      end
      AuthClient.auth["sssd"]    = true; 
      AuthClient.auth["nssldap"] = false; 
      AuthClient.auth["oes"]     = false; 
      if ! AuthClient.auth.has_key?("sssd_conf")
         AuthClient.CreateBasicSSSD
      end
      # Main dialog contents
      contents = Frame(
          _("Authentication Client"),
          HBox(
            HWeight(
              7,
              Top(
                 ReplacePoint(Id(:rep_services), CreateServices() )
              )
            ),
            HWeight(
              13,
              Top(
                VBox(
                  ReplacePoint(Id(:rep_domains),
                    SelectionBox( Id(:domains),
                      _("Configured Authentication Domains"),
                      ListDomains()
                    ) 
                  )
                )
              )
            ),
            HWeight(
              6,
              Top(
                VBox(
                  Label(""),
                  PushButton(Id(:AddDomain),    _("Add")),
                  PushButton(Id(:EditDomain),   _("Edit")),
                  PushButton(Id(:DeleteDomain), _("Delete"))
                )
              )
            )
          )
        )
      # Inetd configure dialog caption
      caption = _("Authentication Client Configuration (sssd)")

      # initialize GUI
      Wizard.SetContentsButtons(
        caption,
        contents,
        _("SSSD provides a set of daemons to manage access to remote directories and authentication mechanisms.<br>" +
          "You have to confiugre at least one authentication domain.<br>" +
          "The first you have to set for a authentication domain is the identification and auth provider used for the domain.<br>" +
          "In the next step you have to set some mandatory parameter for the selected providers." +
          "You can select later all parameters available for the selected identification and auth provider." +
          "SSSD provides following id_provider:<br>" +
          "<b>proxy</b>: Support a legacy NSS provider.<br>" +
          "<b>local</b>: SSSD internal provider for local users.<br>" +
          "<b>ldap</b>: LDAP provider. See sssd-ldap(5) for more information on configuring LDAP.<br>" +
          "<b>ipa</b>: FreeIPA and Red Hat Enterprise Identity Management provider.<br>" +
          "<b>ad</b>: Active Directory provider.<br>" +
	  "Supported auth providers are:<br>" +
          "<b>ldap</b> for native LDAP authentication.<br>" +
          "<b>krb5</b> for Kerberos authentication.<br>" +
          "<b>ipa</b> FreeIPA and Red Hat Enterprise Identity Management provider.<br>" +
          "<b>ad</b> Active Directory provider.<br>" +
          "<b>proxy</b> for relaying authentication to some other PAM target.<br>" +
          "<b>none</b> disables authentication explicitly.<br>" +
          "The default auth provider is the id_provider.<br>"
	),
        Label.CancelButton,
        Label.FinishButton
      )

      ret = nil
      _EventType = nil
      while ret != :next && ret != :back
         event = UI.WaitForEvent
         ret   = Ops.get(event, "ID")
         Builtins.y2milestone("ret was pussed %1",ret)
         case ret
           when :mkhomedir
             AuthClient.auth["mkhomedir"]  = Convert.to_boolean( UI.QueryWidget(Id(:mkhomedir), :CurrentItem) );
           when :sssd
             ConfigureSection("sssd")
             UI.ReplaceWidget(Id(:rep_services), CreateServices() )
           when :nss
             ConfigureSection("nss")
           when :pam
             ConfigureSection("pam")
           when :sudo
             ConfigureSection("sudo")
           when :autofs
             ConfigureSection("autofs")
           when :ssh
             ConfigureSection("ssh")
           when :AddDomain
             AddDomain()
             UI.ReplaceWidget(Id(:rep_domains), SelectionBox( Id(:domains),_("Configured Authentication Domains"),ListDomains()) )
           when :EditDomain
             _Domain = Convert.to_string( UI.QueryWidget(Id(:domains), :CurrentItem))
             ConfigureSection(_Domain)
           when :DeleteDomain
             DeleteDomain()
             UI.ReplaceWidget(Id(:rep_domains), SelectionBox( Id(:domains),_("Configured Authentication Domains"),ListDomains()) )
           when :next
             ret = CheckSettings()
         end
      end
      ret
    end

    def WriteDialog
      Builtins.y2milestone("--Start AuthClient WriteDialog ---")
      ret = AuthClient.Write
      ret ? :next : :abort
    end
  end
end
