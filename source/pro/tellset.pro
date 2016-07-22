pro tellset,help=help  ;  show the search values to be used by SELECT and SELECTNS
;+
;NAME:
;  TELLSET
;
;            =========================
;            Syntax: tellset,help=help
;            =========================
;
;   tellset   Shows the SELECT parameters currently set.
;   -------    
;-
;  v5.1 Feb 2008 tmb
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'tellset' & return & endif
;
print
print,'Selecting: Source= '+!src+'  Type= '+!typ+'  ID= '+!id+' Pol= '+!pol+ $
                  ' Scan= '+!scan
print,'Record range for search= '+fstring(!recmin,'(i6)')+' to '+fstring(!recmax,'(i6)')
print,'Scan   range for search= '+fstring(!scanmin,'(i6)')+' to '+fstring(!scanmax,'(i6)')
print
;
return
end
