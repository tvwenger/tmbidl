pro cflip,help=help
;+
; NAME:
;       CFLIP
;
;            =======================
;            Syntax: cflip,help=help
;            =======================
;
;   cflip  flip !b[0].c_pts continuum data point record
;   -----  store the flipped data in !b[15]
;     
; MODIFICATION HISTORY:
; V5.1 TMB 
;
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'cflip' & return & endif
;
cpts=!b[0].c_pts
copy,0,15
for i=0,cpts-1 do begin
      !b[15].data[i]=!b[0].data[cpts-1-i]
endfor
;
return
end
