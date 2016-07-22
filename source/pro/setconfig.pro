pro setconfig,config_num,help=help
;+
; NAME:
;   SETCONFIG
;
;            ============================================
;            Syntax: setconfig, configuration_#,help=help
;            ============================================
;
;   setconfig  Sets the correlator configuration for automatic 
;   ---------  flagging of spectral transitions in CHANnel space.
;
;   The following spectral configurations are supported:
;
;   Config_# = 0 for GBT 3-Helium flags
;            = 1 for GBT 7-alpha (X-band) flags
;            = 2 for GBT 7-alpha (C-band) flags
;            = 3 for ARECIBO 3-Helium flags
;            = 4 = testm3 for GBT 3-Helium
;            = 5 for GBT C-band Orion Te Project 
;
;-
; V5.1 17jul08 tmb 
;
; V6.1 05feb11 tmb setup structure of many new configurations 
; V7.0 03may2013 tvw - added /help, !debug
; V7.1 30may2014 tmb/tvw - added Orion Te Project config
;
;-
;
on_error,!debug ? 0 : 2
;
npar = n_params(0)
;
if npar eq 0 or keyword_set(help) then begin & get_help,'setconfig' & return & endif
;
case config_num of 
                  0: !config = 0 
                  1: !config = 1
                  2: !config = 2
                  3: !config = 3
                  4: !config = 4
                  5: !config = 5
               else: begin
                     print,'CORRELATOR CONFIGURATION NOT SUPPORTED !!!'
                     return
                     end
endcase
;
return                                                
end 


