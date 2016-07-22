function findpol, ipol,help=help
;+
; NAME:
;      FINDPOL
;
;   findpol  Find the polarization state of the data from SDFITS crval4 
;   -------  
;
;     Syntax: pol = findpol(crval4,help=help)
;     =============================
;
; V5.1 April 2008 tmb 
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'findpol' & return,-1 & endif
;
;print,"polarization is=",ipol
case ipol of 
          -1:polid='RR'
          -2:polid='LL'
          -3:polid='RL'
          -4:polid='LR'
          -5:polid='XX'
          -6:polid='YY'
          -7:polid='XY'
          -8:polid='YX'
           1:polid='I'
           2:polid='Q'
           3:polid='U'
           4:polid='V'
        else:print,"Invalid Polarization flag in SDFITS file!"
endcase
;
return, polid
end

