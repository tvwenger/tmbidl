pro rec_info,rec,help=help  
;+
; NAME:
;       REC_INFO
;
;            ====================================
;            Syntax: rec_info, record_#,help=help
;            ====================================
;
; rec_info   Print information for a {tmbidl_data} data file record.
; --------   'record_#' is the record number which is the position of 
;            the data structure in the data file. 
;
;            ONLINE/OFFLINE toggle to ONLINE or OFFLINE data file 
;
;-
; MODIFICATION HISTORY:
; by TMB in Summer 2006 to accomodate GRS data files 
; V5.0 July 2007
; by TMB Aug 07 to accomodate CONTinuum
; 06feb08 dsb increase source name to 16 char
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'rec_info' & return & endif
;
case !online of           ;  select ONLINE or OFFLINE data file 
     1: begin
              openr,!onunit,!online_data      ; open the ONLINE data file 
              record = assoc(!onunit,!rec)    ; !rec is the {tmbidl_data} structure 
              recmax = !kon-1                 ; provide EOF test info 
        end
     0: begin
              openr,!offunit,!offline_data    ; open the OFFLINE data file
              record = assoc(!offunit,!rec)
              recmax = !koff-1
        end
endcase
;
rec=abs(rec)
!rec=record[rec]
;
if rec gt recmax then begin
   print,'EOF on data file'
   close,!onunit & close,!offunit & 
   return
   endif
;
fmt0='(a68)'
;
case 1 of 
  !GRSMODE eq 1:begin  ; special GRS mode
                fmt1='(i8,1x,a14,1x,2(f7.4,1x),f4.1,1x,f6.1,1x,f5.3,1x,a9,1x,a)'
                end
     !LINE eq 1:begin  ; normal TMBIDL spectral line mode
                fmt1='(i5,1x,a16,1x,a22,f6.1,1x,a5,1x,a3,1x,a3,1x,i9,f6.1,f7.1)'
                end
           else:begin
                fmt1='(i5,1x,a16,1x,a22,f6.1,1x,a5,1x,a3,1x,a3,1x,i9,1x,f6.1,f8.4)'
                end
endcase
;   111 blank_sky     07 42 16.2  +40 37 60   0.0 D38   OFF RCP    46
;hdr=' Rec#   Source         R.A.         Dec.   Vel  Rx   Type Pol  Scan#'
;
sname=strmid(!rec.source,0,16)             ; truncate input 16 char string to 12
sradec=adstring(!rec.ra,!rec.dec,0)  ; 22 char string which is inefficient

scan=!rec.scan_num                         ; GBT scan number
vel=!rec.vel/1.0d+3                        ; source velocity
rxno=strtrim(string(!rec.line_id),2)       ; 'receiver' # via line_id 
pol=strtrim(string(!rec.pol_id),2)         ; receiver polarization
type=string(!rec.scan_type)
case 1 of 
    !LINE eq 1: styp=strmid(type,13,3)     ; TP LINE MODE 'ON:' or 'OFF' 
          else: styp=strmid(type,0,3)      ; 'GRS', 'DEC', 'RA:'
endcase
tsys=!rec.tsys
case 1 of 
    !LINE eq 0: time=!rec.tintg            ; CONTINUUM mode is seconds
          else: time=!rec.tintg/60.        ; otherwise in minutes
endcase
;
; and GRS parameters
l_gal=!rec.l_gal
b_gal=!rec.b_gal
pos_offset=!rec.beamxoff  ; offset in arsec between commanded and GRS (l,b)     
lid=strtrim(string(!rec.line_id),2)
typ=strtrim(string(!rec.scan_type),2) ; GRS spectral ID 
;
case 1 of 
; 
       !GRSMODE eq 1:begin ; GRS prints l_gal,b_gal
                     src=strtrim(string(!rec.source),2)    ; source name
                     print,rec,src,l_gal,b_gal,pos_offset,time,tsys, $
                           lid,typ,format=fmt1
                     end
                else:begin ; TMBIDL prints RA,DEC
                     print,rec,sname,sradec,vel,rxno,styp,pol,scan,tsys,time, $
                           FORMAT=fmt1
                     end
endcase
;
close,!onunit & close,!offunit        ;  does not hurt to close them both 
;                        
return
end
