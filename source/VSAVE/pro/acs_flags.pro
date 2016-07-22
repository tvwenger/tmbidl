;+
; NAME:
;       ACS_FLAGS
;
;            ======================
;            Syntax: acs_flags,rxid
;            ======================
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
;
; MODIFICATION HISTORY:
; V5.1 8 Jan 2008 by TMB
;        23Jan08 dsb add lineid's to case statement (e.g., H89 instead of rx1).
;        03Apr08 dsb add C-band 7-alpha flags
;        17Jul08 tmb add ARECIBO interim correlator 3He flags
;
;-
pro acs_flags,rxid
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 then begin
              print,'Need to specify receiver id via string'
              return
              endif
;
config=!config
;
print,'rxid=',rxid
case config of
           -1: begin
               print
               print,'Need to specify ACS configuration for correct flags!!!'
               print
               print,'!config = 0 for GBT 3-Helium flags'
               print,'!config = 1 for GBT 7-alpha (X-band) flags'
               print,'!config = 2 for GBT 7-alpha (C-band) flags'
               print,'!config = 3 for ARECIBO 3-Helium flags'
               print
               print,'Use procedure:  setconfig, config_#'
               print,'                ==================='
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
                    'HE3a': he3
                     'A91': a91
                    'B115': b115
                     'A92': a92
                    'HE3b': he3
                    'HE++': hepp
                    'G131': g131
                    'G132': g132
                     'HE3': he3
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
                     'H89': h89
                     'H88': h88
                     'H87': h87
                     'HE3': he3
                     'H93': h93
                     'H92': h92
                     'H91': h91
                     'H90': h90
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
                     'H104': h104
                     'H105': h105
                     'H106': h106
                     'H107': h107
                     'H108': h108
                     'H109': h109
                     'H110': h110
                     'H112': h112
               endcase
               end
            3: begin
               case rxid of
                     'rx1': aog132
                     'rx2': aob115
                     'rx3': aoa91
                     'rx4': aohe3
                    'G132': aog132
                    'B115': aob115
                     'A91': aoa91
                     'He3': aohe3
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
