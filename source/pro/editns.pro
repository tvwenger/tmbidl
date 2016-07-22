pro editns,ns1,ns2,help=help
;+
; NAME:
;       EDITNS
;
;   editns   Edit the NSAVE file.  
;   ------   One can modify this routine to change the contents
;            of an existing NSAVE record in any way you wish
;            and then save the edited record back to the same slot.
;
;            ===============================================
;            Syntax: editns, ns_start_#, ns_stop_#,help=help              
;            ===============================================              
;            No input default is all nsave slots.
;            One parameter input does only this one slot.
;            Two parameters do the start,stop slot range.
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
on_ioerror,punt
;
if keyword_set(help) then begin & get_help,'editns' & return & endif
;
if n_params() eq 0 then begin
                        ns1=1 & ns2=99999 &   ;  defaults to do all
                        end
;
if n_params() eq 1 then begin
                        ns2=ns1 
                        end
;
if (ns2 lt ns1) then begin
                       get_help,'editns'
                       return
                       end
;
openr,!nslogunit,!nslogfile
nslog=intarr(!nsave_max)
readu,!nslogunit,nslog          ; ! apparently passed by value not reference
!nsave_log[0:!nsave_max-1]=nslog
close,!nslogunit
;
!deja_vu=0
hdr='NS#  Source      Line  Pol     Type    Tsys   Tintg'
fmt='(i3,1x,a12,1x,a4,2x,a3,1x,a12,f6.1,f7.1)'
;
   print
   print,'NSAVE file '+ !nsavefile + ' contains: '
   print
   print,hdr
;
copy,0,8      ;   copy buffer 0 to buffer 8 before you overwrite 0 with the log data
;
;
for i=0,!nsave_max-1 do begin 
;
    if (!nsave_log[i] eq 1) then begin 
;
       getns,i
       sname=strmid(!b[0].source,0,12)         ; truncate string to 12
       scan=!b[0].scan_num                     ; GBT scan number
       vel=!b[0].vel/1.d+3                     ; source velocity
       rxno=strtrim(string(!b[0].line_id),2)   ; 'receiver' # via line_id 
       pol=strtrim(string(!b[0].pol_id),2)     ; receiver polarization
       styp=string(!b[0].scan_type)            ; fetch scan_type
       tsys=!b[0].tsys                         ; Tsys in Kelvin       
       stintg=!b[0].tintg/60.                  ; integration time in minutes
;
;       if (i ge ns1) and (i le ns2) then print,i,sname,rxno,pol,styp,tsys,stintg, $
;                                               FORMAT=fmt
;
       if (rxno eq 'HE3') then begin
                               rxno='HE3a'
                               print,i,sname,rxno,pol,styp,tsys,stintg, FORMAT=fmt      
                               nsoff
                               !b[0].line_id=byte(rxno)
                               putns,i
                               nson
                               end
;
       endif
;
endfor
;
copy,8,0       ;  replace buffer 0 data 
!deja_vu=0
;
goto, out
punt: print,'EOF on NSAVE file: probably due to incompatible file sizes'
;
out:
return
end
