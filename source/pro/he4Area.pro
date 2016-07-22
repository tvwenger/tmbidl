pro he4Area,nreg,help=help
;+
; NAME:
;       he4Area
;
;  ==============================
;  SYNTAX: he4Area,nreg,help=help
;  ==============================
;
;  he4Area  Fit the area under the H and He RRLs and calculate He/H.  
;  -------  Either specify the nregions or use the cursor by default.
;
;  ==> N.B. These nregions bracket the line emission and so are
;           OPPOSITE of the way NREGIONs are used in e.g. b.pro 
;
;
;  PARAMETERS: nreg - list of nregions (e.g., [123,145,233,267])
;                     this is optional 
;
;  KEYWORDS:  help  gives this help
;
;  RELATED CODE:  he4Fit.pro does error propagation
;
;-
;MODIFICATION HISTORY:
;    18 Sep 2009 - Dana S. Balser 
; V7.0 18may2013 tmb updated to v7.0 
;      
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'he4area' & return & endif
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
; save cursor/flag state
cursor_state=!cursor
flag_state=!flag
; stop cursor routine from writing
!flag=1
; assume two nregions each of which brackets the line emission 
nr=fltarr(4)
; check if using cursor 
if n_params() eq 0 then begin
    ; use cursor to get regions
    curon
    print, 'Bracket the  He and then H emission with with 4 cursor clicks:'
    for i=0,3 do begin
        ccc,xpos,ypos
        idchan,xpos,xchan
        nr[i]=xchan
    endfor
endif else begin
    ; use parameters to get nregions
    for i=0,3 do begin
        idchan,nreg[i],xchan
        nr[i]=xchan
    endfor
endelse
;
; calculate He area
heArea=0.0
for i=min([nr[0],nr[1]]),max([nr[0],nr[1]]) do begin
    heArea = heArea + !b[0].data[i]
endfor
;
; calculate H area
hArea=0.0
for i=min([nr[2],nr[3]]),max([nr[2],nr[3]]) do begin
    hArea = hArea + !b[0].data[i]
endfor
;
; ratio
ratio = heArea/hArea
;
print, ratio, format = '("4He+/H+ ratio of line areas = ", f6.4)'
;
; return cursor and flag state
!flag=flag_state    
!cursor=cursor_state
;
return
end
