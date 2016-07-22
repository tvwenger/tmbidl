;+
; NAME:
;       ACS_TAGS
;
;            ======================
;            Syntax: acs_flags,rxid,lcen,tag,loffset
;            ======================
;
;   acs_tags  Uses !config state and 'rxid' string to determine ACS 
;   ---------  spectral transition flag to find a line name and offset from
;              flag 
;                          rxid = receiver (or band id)
;;                         lcen = line center in channels
;                          tag  = the returned tag
;                          loffset = returned difference between flag
;                                    and line
;

;   Uses !config to pick correct flags for given ACS configuration:
;   
;        !config = 0 for GBT 3-Helium flags'
;                = 1 for GBT 7-alpha (X-band) flags'
;                    below nor currently implemented
;                = 2 for GBT 7-alpha (C-band) flags'
;                = 3 for ARECIBO 3He flags'
;
; MODIFICATION HISTORY:
; V5.1 8 Jan 2008 by TMB
;        23Jan08 dsb add lineid's to case statement (e.g., H89 instead of rx1).
;        03Apr08 dsb add C-band 7-alpha flags
;        17Jul08 tmb add ARECIBO interim correlator 3He flags
;        8/08    rtr converts ascflags to acstags
;
;-
pro acs_tags,rxid,lcen,tag,loffset
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() ne 4 then begin
              print,'Required Syntax: acs_flags,rxid,lcen,tag,loffset'
              return
              endif
;
config=!config
;
rxid=strtrim(rxid,2)
print,'band ',rxid,' center=',lcen
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
                     'rx1': he3tag,lcen,tag,loffset
                     'rx2': a91tag,lcen,tag,loffset
                     'rx3': b115tag,lcen,tag,loffset
                     'rx4': a92tag,lcen,tag,loffset
                     'rx5': he3tag,lcen,tag,loffset
                     'rx6': hepptag,lcen,tag,loffset
                     'rx7': g131tag,lcen,tag,loffset
                     'rx8': g132tag,lcen,tag,loffset
                    'HE3a': he3tag,lcen,tag,loffset
                     'A91': a91tag,lcen,tag,loffset
                    'B115': b115tag,lcen,tag,loffset
                     'A92': a92tag,lcen,tag,loffset
                    'HE3b': he3tag,lcen,tag,loffset
                    'HE++': hepptag,lcen,tag,loffset
                    'G131': g131tag,lcen,tag,loffset
                    'G132': g132tag,lcen,tag,loffset
                     else: begin
                        print, rxid,' not found'
                        return
                     end
               endcase
               end
            1: begin
               case rxid of
                     'rx1': h89tag,lcen,tag,loffset
                     'rx2': h88tag,lcen,tag,loffset
                     'rx3': h87tag,lcen,tag,loffset
                     'rx4': he3tag,lcen,tag,loffset
                     'rx5': h93tag,lcen,tag,loffset
                     'rx6': h92tag,lcen,tag,loffset
                     'rx7': h91tag,lcen,tag,loffset
                     'rx8': h90tag,lcen,tag,loffset
                     'H89': h89tag,lcen,tag,loffset
                     'H88': h88tag,lcen,tag,loffset
                     'H87': h87tag,lcen,tag,loffset
                     'HE3': he3tag,lcen,tag,loffset
                     'H93': h93tag,lcen,tag,loffset
                     'H92': h92tag,lcen,tag,loffset
                     'H91': h91tag,lcen,tag,loffset
                     'H90': h90tag,lcen,tag,loffset
                     else: begin
                        print, rxid,' not found'
                        return
                     end
               endcase
               end
            2: begin
               print,'ACS_TAGS: !config = ',!config,' not yet implemented'
               return
               end
;               case rxid of
;                     'rx1': h107
;                     'rx2': h104
;                     'rx3': h105
;                     'rx4': h106
;                     'rx5': h108
;                     'rx6': h109
;                     'rx7': h110
;                     'rx8': h112
;                     'H104': h104
;                     'H105': h105
;                     'H106': h106
;                     'H107': h107
;                     'H108': h108
;                     'H109': h109
;                     'H110': h110
;                     'H112': h112
;               endcase
;               end
            3: begin
               print,'ACS_TAGS: !config = ',!config,' not yet implemented'
               return
               end
;               case rxid of
;                     'rx1': aog132
;                     'rx2': aob115
;                     'rx3': aoa91
;                     'rx4': aohe3
;                    'G132': aog132
;                    'B115': aob115
;                     'A91': aoa91
;                     'He3': aohe3
;               endcase
;               end
         else: begin
               print,'CORRELATOR CONFIGURATION NOT SUPPORTED!!!! Check !config value'
               return
               end
endcase
;
if abs(loffset) gt !line_match_warning then begin
   print,'Possible bad line tag',tag
end
return
end
