pro acs_flags,rxid,help=help
;+
; NAME:
;       ACS_FLAGS
;
;            ================================
;            Syntax: acs_flags,rxid,help=help
;            ================================
;
;   acs_flags  Uses !config state and 'rxid' string to determine ACS 
;   ---------  spectral transition flag locations in channels and plots them
;
;   Uses !config to pick correct flags for given ACS configuration:
;   
;        !config = 0 for GBT 3-Helium flags'
;                = 1 for GBT 7-alpha (X-band) flags'
;                = 2 for GBT 7-alpha (C-band) flags'
;                = 3 for ARECIBO 3He flags'
;                = 4 for linehii4 (aka testm3) GBT 3-Helium'
;                = 5 for GBT C-band Orion Te Project 
;
;-
; MODIFICATION HISTORY:
; V5.1 8 Jan 2008 by TMB
;        23Jan08 dsb add lineid's to case statement (e.g., H89 instead of rx1).
;        03Apr08 dsb add C-band 7-alpha flags
;        17Jul08 tmb add ARECIBO interim correlator 3He flags
;        23Feb09 dsb use explict rxid (e.g., rx1.1 instead of rx1).
;
; V6.0 24june2009 rtr adds 3He generic flag  
;      11july     tmb added rx1, rx2, etc. capability back as 
;                     some .pro's such as qlook us this notation
;                     also included explict handling of case
;                     statement non-matches.
;
;                     we need to think of a better approach here
;
; V6.1 05feb2011 tmb/dsb but we haven't thought of a better approach...
;
; V7.0 3may2013 tvw - added /help, !debug
;     17jun2013 tmb - finally resolved this .pro properly with his
;                     sandbox code that actually had !config=4 implemented
;     30may2014 tmb/tvw - added Orion Te Project C-band configuration 
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'acs_flags' & return & endif
;
config=!config
;
case config of
           -1: begin
               print
               print,'Need to specify ACS configuration for correct flags!!!'
               print
               print,'!config = 0 for GBT 3-Helium flags'
               print,'!config = 1 for GBT 7-alpha (X-band) flags'
               print,'!config = 2 for GBT 7-alpha (C-band) flags'
               print,'!config = 3 for ARECIBO 3-Helium flags'
               print,'!config = 4 for linehii4 (aka testm3) GBT 3-Helium'
               print,'!config = 5 for Orion C-band Te Project'
               print
               print,'==================================='
               print,'Use procedure:  setconfig, config_#'
               print,'==================================='
               return
               end
            0: begin
               case rxid of
                       'rx1': he3
                       'rx2': a91
                       'rx3': b115
                       'rx4': a92
                       'rx5': he3
                       'rx6': hepp
                       'rx7': g131
                       'rx8': g132
                     'rx1.1': he3
                     'rx2.1': a91
                     'rx3.1': b115
                     'rx4.1': a92
                     'rx5.1': he3
                     'rx6.1': hepp
                     'rx7.1': g131
                     'rx8.1': g132
                     'rx1.2': he3
                     'rx2.2': a91
                     'rx3.2': b115
                     'rx4.2': a92
                     'rx5.2': he3
                     'rx6.2': hepp
                     'rx7.2': g131
                     'rx8.2': g132
                      'HE3a': he3
                       'A91': a91
                      'B115': b115
                       'A92': a92
                      'HE3b': he3
                      'HE++': hepp
                      'G131': g131
                      'G132': g132
                       'HE3': he3
                       else : print,'config=0 no case match'
               endcase
               end
            1: begin
               case rxid of
                       'rx1': h89
                       'rx2': h88
                       'rx3': h87
                       'rx4': he3
                       'rx5': h93
                       'rx6': h92
                       'rx7': h91
                       'rx8': h90
                     'rx1.1': h89
                     'rx2.1': h88
                     'rx3.1': h87
                     'rx4.1': he3
                     'rx5.1': h93
                     'rx6.1': h92
                     'rx7.1': h91
                     'rx8.1': h90
                     'rx1.2': h89
                     'rx2.2': h88
                     'rx3.2': h87
                     'rx4.2': he3
                     'rx5.2': h93
                     'rx6.2': h92
                     'rx7.2': h91
                     'rx8.2': h90
                       'H89': h89
                       'H88': h88
                       'H87': h87
                       'HE3': he3
                       'H93': h93
                       'H92': h92
                       'H91': h91
                       'H90': h90
                       else : print,'config=1 no case match'
               endcase
               end
            2: begin
               case rxid of
                       'rx1': h107
                       'rx2': h104
                       'rx3': h105
                       'rx4': h106
                       'rx5': h108
                       'rx6': h109
                       'rx7': h110
                       'rx8': h112
                     'rx1.1': h107
                     'rx2.1': h104
                     'rx3.1': h105
                     'rx4.1': h106
                     'rx5.1': h108
                     'rx6.1': h109
                     'rx7.1': h110
                     'rx8.1': h112
                     'rx1.2': h107
                     'rx2.2': h104
                     'rx3.2': h105
                     'rx4.2': h106
                     'rx5.2': h108
                     'rx6.2': h109
                     'rx7.2': h110
                     'rx8.2': h112
                      'H104': h104
                      'H105': h105
                      'H106': h106
                      'H107': h107
                      'H108': h108
                      'H109': h109
                      'H110': h110
                      'H112': h112
                       else : print,'config=2 no case match'
               endcase
               end
            3: begin
               case rxid of
                     'rx1.1': aog132
                     'rx2.1': aob115
                     'rx3.1': aoa91
                     'rx4.1': aohe3
                     'rx1.2': aog132
                     'rx2.2': aob115
                     'rx3.2': aoa91
                     'rx4.2': aohe3
                      'G132': aog132
                      'B115': aob115
                       'A91': aoa91
                       'He3': aohe3
                       else : print,'config=3 no case match'
               endcase
               end
            4: begin  ; just a place holder for the nonce so that it compiles
               case rxid of
                       'rx1': he3
                       'rx2': a91
                       'rx3': b115
                       'rx4': a92
                       'rx5': he3
                       'rx6': hepp
                       'rx7': g131
                       'rx8': g132
                     'rx1.1': he3
                     'rx2.1': a91
                     'rx3.1': b115
                     'rx4.1': a92
                     'rx5.1': he3
                     'rx6.1': hepp
                     'rx7.1': g131
                     'rx8.1': g132
                     'rx1.2': he3
                     'rx2.2': a91
                     'rx3.2': b115
                     'rx4.2': a92
                     'rx5.2': he3
                     'rx6.2': hepp
                     'rx7.2': g131
                     'rx8.2': g132
                      'HE3a': he3
                       'A91': a91
                      'B115': b115
                       'A92': a92
                      'HE3b': he3
                      'HE++': hepp
                      'G131': g131
                      'G132': g132
                       'HE3': he3
                       else : print,'config=4 no case match'
               endcase
               end
            5: begin  ; Orion C-band Te Project 
               case rxid of
                       'rx1': h105
                       'rx2': h104
                       'rx3': h103
                       'rx4': h102
                       'rx5': h109
                       'rx6': h108
                       'rx7': h107
                       'rx8': h106
                     'rx1.1': h105
                     'rx2.1': h104
                     'rx3.1': h103
                     'rx4.1': h102
                     'rx5.1': h109
                     'rx6.1': h108
                     'rx7.1': h107
                     'rx8.1': h106
                     'rx1.2': h105
                     'rx2.2': h104
                     'rx3.2': h103
                     'rx4.2': h102
                     'rx5.2': h109
                     'rx6.2': h108
                     'rx7.2': h107
                     'rx8.2': h106
                      'H102': h102
                      'H103': h103
                      'H104': h104
                      'H105': h105
                      'H106': h106
                      'H107': h107
                      'H108': h108
                      'H109': h109
                       else : print,'config=5 no case match'
               endcase
               end
         else: begin
               print,'CORRELATOR CONFIGURATION NOT SUPPORTED!!!! Check !config value'
               return
               end
endcase
;
return
end
