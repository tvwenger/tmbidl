pro nslog,nslow,nshigh,help=help
;+
; NAME:
;       NSLOG
;
;            ==============================================
;            Syntax: nslog, start_ns_#, stop_ns_#,help=help
;            ==============================================
;
;   nslog   Print information for NSAVE data records 
;   -----
;-
; MODIFICATION HISTORY:
; By rtr in mar 05 to list a range of nsaves
; By tmb in summer 06 to add GRS capability
; V5.0 July 2007
;      21 June 2008 fixed output bug 
;
; V6.1 12feb2011 tmb how can ns# format be wrong here?
;                    aha.  GRS mode had not been used in a long time
;      27june2011 tmb fixed formatting bug for scan_type
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
on_ioerror,punt
if keyword_set(help) then begin & get_help,'nslog' & return & endif
;  find the last ns number in the NSAVE file
;
nsmax=!nsave_max
;
if n_params() eq 0 then begin
                   nslow=!nslow & nshigh=!nshigh &
                   endif
;
if nshigh gt nsmax-1 then nshigh=nsmax-1
if nslow lt 0 then nslow=0
;
print,'Listing NSAVEs from ',nslow,nshigh,nsmax
;
openr,!nslogunit,!nslogfile
nslog=intarr(!nsave_max)
readu,!nslogunit,nslog          ; ! apparently passed by value not reference
!nsave_log[0:!nsave_max-1]=nslog 
close,!nslogunit
;
!deja_vu=0
;
case 1 of 
       !GRSMODE eq 1:begin  ; special GRS header
hdr='NS#   Source          L_gal   B_gal Offset Rec#  Tintg  RMS'
fmt='(i4,1x,a14,1x,2(f7.4,1x),f4.1,1x,i6,1x,f3.0,3x,f5.3)'
                     end
                else:begin  ; normal TMBIDL header
hdr='NS#  Source          R.A.        Dec.    '
hdr=hdr+'  Vel   Rx  Pol     Type    Tsys   Tintg'
fmt='(i4,1x,a12,1x,a22,f6.1,1x,a5,1x,a3,1x,a10,1x,f6.1,f7.1)'
                endelse
endcase
;
;if (!deja_vu eq 0) then begin
   print
   print,'NSAVE file '+ !nsavefile + ' contains: '
   print
   print,hdr
   !deja_vu=1
;endif
;
copy,0,8      ;   copy buffer 0 to buffer 8 before you overwrite 0 with the log data
;
;
for i=nslow,nshigh do begin 
;
    if (!nsave_log[i] eq 1) then begin 
;
       getns,i
       sname=strmid(!b[0].source,0,12)         ; truncate string to 12
       sradec=adstring(!b[0].ra,!b[0].dec,0)   ; RA,DEC string
       scan=!b[0].scan_num                     ; GBT scan number
       vel=!b[0].vel/1.d+3                     ; source velocity
       rxno=strtrim(string(!b[0].line_id),2)   ; 'receiver' # via line_id 
       pol=strtrim(string(!b[0].pol_id),2)     ; receiver polarization
       styp=strtrim(string(!b[0].scan_type),2) ; fetch scan_type
       tsys=!b[0].tsys                         ; Tsys in Kelvin       
       stintg=!b[0].tintg/60.                  ; integration time in minutes
;
; and GRS parameters
       l_gal=!b[0].l_gal
       b_gal=!b[0].b_gal
       pos_offset=!b[0].beamxoff  ; offset in arsec between commanded and GRS (l,b)     
       scn=!b[0].scan_num         ; record # in GRS datafile
;
       case 1 of 
              !GRSMODE eq 1:begin ; special GRS information
                            src=strtrim(string(!b[0].source),2) ; source name
                            src=string(!b[0].source)            ; source name
                            print,i,src,l_gal,b_gal,pos_offset,scn,stintg,tsys, $
                                  format=fmt
                            end
                       else:begin ; normal TMBIDL information
       print,i,sname,sradec,vel,rxno,pol,styp,tsys,stintg, FORMAT=fmt
                            end
endcase
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
