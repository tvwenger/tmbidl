pro getns,ns,help=help,rehash=rehash
;+
; NAME:
;
;      GETNS
;
;       ==================================================
;       SYNTAX: getns,nsave_slot_#,help=help,rehash=rehash
;       ==================================================
;
;   getns   fills buffer 0 with NSAVE region specified by nsave_slot_# 
;   -----   if ns not input uses !nsave value
;           if (!nsave_log(!nsave) eq 0) then there is no data here 
;
; KEYWORDS 
;           HELP   - if set then gives this help          
;           REHASH - if set then recovers HISTORY information via 
;                    rehash,/reset and sets X-axis range
;

;-
;MODIFICATION HISTORY
;
; rtr fixed bug ma05
; V5.0 July 2005
; V7.0 03may2013 tvw - added /help, !debug
; V7.1 10jun2014 tmb - added 'history' keyword and cleaned up /help screed
;
;-
;
on_error,!debug ? 0 : 2
;
if keyword_set(help) then begin & get_help,'getns' & return & endif
;
if n_params() eq 0 then ns=!nsave ; use current !nsave if slot location not input
;
!nsave=ns
;
openu,!nsunit,!nsavefile
nsave = assoc(!nsunit,!rec)       ; !rec is one {gbt_data} structure for the pattern
;
openr,!nslogunit,!nslogfile
nslog=intarr(!nsave_max)
readu,!nslogunit,nslog
!nsave_log[0:!nsave_max-1]=nslog
close,!nslogunit
;
if (!nsave_log[!nsave] eq 0) then begin
   print,'NO DATA has been written here yet: NSAVE= ',!nsave
   close,!nsunit
   return
   endif
;
!b[0]=nsave[!nsave]  ; copy nsave = !nsave into buffer 0
;
close,!nsunit
;                        
if KeyWord_Set(rehash) then begin ; details below set for RRL work 
   rehash,/reset
   xmin=!nregion[0] & xmax=!nregion[2*!nrset-1]
;   xmin=xmin-0.01*xmin & xmax=xmax+0.01*xmax
   setx,xmin,xmax & scaley
   xx & zline & rrlflag
   g,/info
endif
;
return
end
