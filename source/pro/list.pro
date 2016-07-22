pro list,start,stop,help=help
;+
; NAME:
;       LIST
;
;            =============================================
;            Syntax: list, start_rec#, stop_rec#,help=help
;            =============================================
;
;   list   List contents of either ONLINE or OFFLINE  data file 
;   ----   for record index range start,stop. 
;          Default is to list entire file is no parameters passed.
;          Invokes REC_INFO which chooses either ONLINE or OFFLINE ffiles.
;          Toggle between these files via ONLINE / OFFLINE commands.
;
;-
; MODIFICATION HISTORY:
; Summer 2006 modified to work with GRS data
; Aug 2007 modified to work with CONTinuum data 
; V5.0 July 2007
; 06feb08 dsb increase header to accomodate 16 char sources
; 17jul08 tmb increase size of scan# to accomodate Arecibo data
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
on_ioerror, eof
if keyword_set(help) then begin & get_help,'list' & return & endif
;
if n_params() eq 0 then begin 
   start=0 
   stop=!recmax
   endif 
;
if n_params() eq 1 then stop=!recmax
;
if stop ge !recmax then stop=!recmax
;
case 1 of
         !GRSMODE eq 1:begin
hdr=' Rec#          Source    L_gal   B_gal Offset  Nrec  RMS   Line     Type'
                       end
            !LINE eq 0:begin
hdr=' Rec#   Source             R.A.         Dec.   Vel  Rx   Type Pol  Scan# '
hdr=hdr+' Tsys  t_intg'
                       end
                  else:begin
hdr=' Rec#   Source             R.A.         Dec.   Vel  Rx   Type Pol  Scan# '
hdr=hdr+' Tsys  t_intg'
                       end 
;
endcase
;
print
print,hdr
print
;
k=0L
for i=start,stop do begin & rec_info,i & k=k+1 & endfor &
goto, out
;
eof:
    print,'EOF on datafile at record = '+fstring(k,'(I4)')
    close_datafile
    return 
;
out: 
return
end
