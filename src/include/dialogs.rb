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
      @auth = Hash.new(&make_hash)

    end

    def DeleteDomain
        _Domain = Convert.to_string( UI.QueryWidget(Id(:domains), :CurrentItem))
        _name   = _Domain.gsub("domain/","")
        if ! Popup.YesNo( Builtins.sformat(_("Do you realy want to delete the domain '%1'." ),_name) )
           return
        end
        if @auth["sssd_conf"]["sssd"].has_key?("domains")
           domains = @auth["sssd_conf"]["sssd"]["domains"].split(%r{,\s*})
           domains = domains.select { |a| a != _name } 
           @auth["sssd_conf"]["sssd"]["domains"] = domains.join(", ")
        end
        @auth["sssd_conf"][_Domain]["DeleteSection"] = true
    end

    def HelpForParameter(parameters)
        _HELP=""
        parameters.each { |parameter|
            _DESC = GetDescription(parameter)
            if _DESC == ""
                _HELP = _HELP + _("There is no help for this parameter.") + parameter
            else
                    _HELP = _HELP + "\n" + parameter + ":\n" + _DESC
            end
            _DEF = GetParameterDefault(parameter)
            if _DEF != ""
                _HELP = _HELP + "\n" + _("Default value: ") + String(_DEF)
            end
            _VALUES = GetParameterValues(parameter)
            if _VALUES != []
                _HELP = _HELP + "\n" + _("Available values: ") + _VALUES.join(", ")
            end
            _HELP = _HELP + "\n"
        }
        Popup.Message(_HELP)
    end

    def GetDescription(parameter)
            @params.each_key { |s|
           @params[s].each_key { |k| 
              if k == parameter && @params[s][k].has_key?("desc")
                      return @params[s][k]["desc"]
              end
           }
        }
        return ""
    end

    def GetParameterType(parameter)
            @params.each_key { |s|
           @params[s].each_key { |k| 
              if k == parameter && @params[s][k].has_key?("type")
                      return @params[s][k]["type"]
              end
           }
        }
        return "string"
    end

    def GetParameterDefault(parameter)
            @params.each_key { |s|
           @params[s].each_key { |k| 
              if k == parameter && @params[s][k].has_key?("def")
                      return @params[s][k]["def"]
              end
           }
        }
        return ""
    end

    def GetParameterValues(parameter)
            @params.each_key { |s|
           @params[s].each_key { |k| 
              if k == parameter && @params[s][k].has_key?("vals")
                      return @params[s][k]["vals"].split(%r{,\s*})
              end
           }
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

    def AddParameter(section,parameter)
        Builtins.y2milestone("--Add Parameter %1 in section %2 called",parameter,section)
        _type = GetParameterType(parameter)
        _def  = GetParameterDefault(parameter)
        _term = VBox()
        case _type 
          when "int"
             _term = Builtins.add( _term, Left( IntField( Id(:value), parameter, 0, @MAXINT, _def.to_i )) )
          when "bool"
             if _def =~ /1|true/i
                _term = Builtins.add( _term, Left( CheckBox( Id(:value), parameter, true )) )
             else   
                _term = Builtins.add( _term, Left( CheckBox( Id(:value), parameter, false )) )
             end   
          when "string"
             _term = Builtins.add( _term, Left( TextEntry( Id(:value), parameter, _def)) )
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
                if !@auth["sssd_conf"].has_key?(section)
                    @auth["sssd_conf"][section] = Hash.new
                end
                @auth["sssd_conf"][section][parameter] = ConvertToString(:value,parameter)
                break
          end
        end
        UI.CloseDialog
        return ret
    end

    def SelectParameter(section)
        _PARS = []
        if section =~ /^domain/
            _id_provider   = nil 
            _auth_provider = nil
            if @auth["sssd_conf"][section].has_key?("id_provider")
               _id_provider = @auth["sssd_conf"][section]["id_provider"]
            end   
            if @auth["sssd_conf"][section].has_key?("auth_provider")
               _auth_provider = @auth["sssd_conf"][section]["auth_provider"]
            end
            if _id_provider != nil
               _PARS.concat( @params[_id_provider].keys )
            end
            if _auth_provider != nil && _id_provider != _auth_provider
               _PARS.concat( @params[_auth_provider].keys )
            end
            _PARS.concat( @params["domain"].keys )
        else
           _PARS.concat( @params[section].keys )
        end
        if _PARS == []
            Popup.Warning( Builtins.sformat(_("Section '%1' has no attributes."), section) )
            return true
        end
        _PARS = _PARS.select { |a| a !~ /^$/ }
        if @auth["sssd_conf"].has_key?(section)
            #List only not exisstent parameter
            _PARS = _PARS.select { |a| @auth["sssd_conf"][section].keys.index(a) == nil }
        end
        #No we open the dialog
        UI.OpenDialog(
                Opt(:decorated),
                VBox(
                        Frame( Builtins.sformat(_("Select new Parameter for section '%1'"), section),
                           SelectionBox(
                             Id(:parameter),
                             _("New Parameter"),
                             _PARS.sort
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
                HelpForParameter( [ Convert.to_string(UI.QueryWidget(Id(:parameter),:CurrentItem)) ])
            when :ok
               ret = AddParameter(section,Convert.to_string(UI.QueryWidget(Id(:parameter),:CurrentItem)))
          end
        end
        UI.CloseDialog
        return ret
    end

    def BuildSection(section)
        _term = VBox()
        #Empy section
        return _term if ! @auth["sssd_conf"].has_key?(section)

        _params = @auth["sssd_conf"][section].keys

        #Check if a domain have all its obligatical parameter
        _id_provider   = nil
        _auth_provider = nil
        if @auth["sssd_conf"][section].has_key?("id_provider")
           _id_provider = @auth["sssd_conf"][section]["id_provider"]
           @params[_id_provider].each_key { |k| 
             if @params[_id_provider][k].has_key?("req") && _params.index(k) == nil
               @auth["sssd_conf"][section][k] = GetParameterDefault(k)
               _params.push(k)
             end
           }
        end
        if @auth["sssd_conf"][section].has_key?("auth_provider")
           _auth_provider = @auth["sssd_conf"][section]["auth_provider"]
           @params[_auth_provider].each_key { |k| 
             if @params[_auth_provider][k].has_key?("req") && _params.index(k) == nil
               @auth["sssd_conf"][section][k] = GetParameterDefault(k)
               _params.push(k)
             end
           }
        end
        _params.each { |k|
           type = GetParameterType(k)
           v    = @auth["sssd_conf"][section][k]
           case type 
             when "int"
                _term = Builtins.add( _term, Left( IntField( Id(k), k, 0, @MAXINT, v.to_i )) )
             when "bool"
                if v =~ /1|true/i
                   _term = Builtins.add( _term, Left( CheckBox( Id(k), k, true )) )
                else   
                   _term = Builtins.add( _term, Left( CheckBox( Id(k), k, false )) )
                end   
             when "string"
                _term = Builtins.add( _term, Left( TextEntry( Id(k), k, v)) )
           end
        }
        return _term
    end

    def ConfigureSection(section)

        #No we open the dialog
        UI.OpenDialog(
                Opt(:decorated),
                VBox(
                        Frame( Builtins.sformat(_("Edit ssd section '%1'"), section),
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
                    HelpForParameter(@auth["sssd_conf"][section].keys)
            when :add
               ret = SelectParameter(section)
               if ret == :ok
                   UI.ReplaceWidget(Id(:rep_params), BuildSection(section) )
               end
               ret = nil
            when :ok
                @auth["sssd_conf"][section].each_key { |k|
                    @auth["sssd_conf"][section][k] = ConvertToString(k,k)
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
                           TextEntry( Id(:name), _("Name:"),"" ),
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
                if dname == ""
                        Popup.Error(_("You have to provide a domain name!"))
                        ret = nil
                else
                   name  = "domain/" + dname
                   @auth["sssd_conf"][name] = Hash.new
                   @auth["sssd_conf"][name]["id_provider"] =   UI.QueryWidget(Id(:id_provider),:CurrentItem)
                   auth_provider = UI.QueryWidget(Id(:auth_provider),:CurrentItem)
                   if auth_provider != "default"
                      @auth["sssd_conf"][name]["auth_provider"] = auth_provider
                   end   
                   if Convert.to_boolean(UI.QueryWidget(Id(:activate),:Value))
                      if ! @auth["sssd_conf"]["sssd"].has_key?("domains")
                          @auth["sssd_conf"]["sssd"]["domains"]= dname
                      else
                          @auth["sssd_conf"]["sssd"]["domains"] = @auth["sssd_conf"]["sssd"]["domains"]  + ", "+ dname
                      end
                   end
                   ConfigureSection(name)
                         Builtins.y2milestone("auth %1", @auth)
                end
          end
        end
        UI.CloseDialog
        return ret
    end

    def CreateServices
        _term = VBox()
        _term = Builtins.add( _term, Left(Label(_("Basic Settings:"))) )
        _term = Builtins.add( _term, Left(PushButton(Id(:sssd), "&sssd")) )
        _term = Builtins.add( _term, Left(Label(_("Services:"))) )
        if @auth["sssd_conf"]["sssd"].has_key?("services")
          _SERVICES = @auth["sssd_conf"]["sssd"]["services"].split(%r{,\s*})
          _term = Builtins.add( _term, Left(PushButton(Id(:nss),    "&nss")) )    if _SERVICES.index("nss") != nil
          _term = Builtins.add( _term, Left(PushButton(Id(:pam),    "&pam")) )    if _SERVICES.index("pam") != nil
          _term = Builtins.add( _term, Left(PushButton(Id(:sudo),   "&sudo")) )   if _SERVICES.index("sudo") != nil
          _term = Builtins.add( _term, Left(PushButton(Id(:autofs), "&autofs")) ) if _SERVICES.index("autofs") != nil
          _term = Builtins.add( _term, Left(PushButton(Id(:ssh),    "&ssh")) )    if _SERVICES.index("ssh") != nil
        end
        _term
    end

    def ListDomains
        _DOMAINS = @auth["sssd_conf"].keys;
        _DOMAINS = _DOMAINS.select { |a| a =~ /^domain/ }
        _DOMAINS = _DOMAINS.select { |a| ! @auth["sssd_conf"][a].has_key?("DeleteSection") }
        _DOMAINS
    end

   def CheckSettings
       _ret = :next
       _inactiv_domains = [] # List of domain which ar defined but not activated
       _activ_domains = 0    # Count of activ domains 
       _DOMAINS = ListDomains()

       if _DOMAINS != []
          if @auth["sssd_conf"]["sssd"].has_key?("domains")
             _acd = []
             @auth["sssd_conf"]["sssd"]["domains"].split(%r{,\s*}).each { |d| 
                _acd.push("domain/"+d)
             }
             _DOMAINS.each { |d| 
               if _acd.index(d) == nil
                        _inactiv_domains.push(d)
               else
                     _activ_domains = _activ_domains + 1
               end
             }
          end
          if _activ_domains == 0
             if ! Popup.YesNo( _("There are no activated domains in the [sssd] section.\n" +
                                 "sssd will not be started. Only local authentication will be available.\n" +
                                 "Do you want to write this configuration?")
                               )
                 return :go_on
             end
          end
          if _inactiv_domains != []
             if ! Popup.YesNo( _("There are some domains you have not activated it:\n" +
                                 _inactiv_domains.join(", ") + "\n" +
                                 "Do you want to write this configuration?")
                               )
                 return :go_on
             end
          end
       end
       _ret
    end

    def MainDialog
      Builtins.y2milestone("--Start AuthClient MainDialog ---")
      @auth = AuthClient.GetConfig
      Builtins.y2milestone("auth %1", @auth);
      if @auth["nssldap"] == "1" && ! Mode.autoinst
          if ! Popup.YesNo(
            _( "Your system is configured for using nss_ldap.\n" +
           "This module is designed to configure your system via sssd.\n" +
           "If you are using this module your nss_ldap configuration will be removed.\n" +
           "Do you want to continue?" )
          )
            return :abort
          end
      end
      if @auth["oes"] == "1" && ! Mode.autoinst
          if ! Popup.YesNo(
            _( "Your system is configured as OES client.\n" +
           "This module is designed to configure your system via sssd.\n" +
           "If you are using this module your OES client configuration will be deactivated.\n" +
           "Do you want to continue?" )
          )
            return :abort
          end
      end
      @auth["sssd"]    = true; 
      @auth["nssldap"] = false; 
      @auth["oes"]     = false; 
      if ! @auth.has_key?("sssd_conf")
         @auth = AuthClient.CreateBasicSSSD
      end
      # Main dialog contents
      contents = Frame(
          _("SPAM Prevention"),
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
        _("TODO WRITE HELP"),
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
      AuthClient.Import(@auth)
      ret = AuthClient.Write
      ret ? :next : :abort
    end
  end
end
