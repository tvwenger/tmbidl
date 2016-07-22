pro mkfit,help=help
;+
; NAME:
;       MKFIT
;
;            =======================
;            Syntax: mkfit,help=help
;            =======================
;
;   mkfit   smooths and does gaussians
;   -----   
;
;               Syntax: mkfit
;-
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'mkfit' & return & endif
;
smo,20
xx
lmarker
print,'How many gaussians? (0 uses old parameters'
ng=0
read,ng
if ng eq 0 then begin
    g
    return
    endif else begin
    gg,ng
endelse
;
return
end

