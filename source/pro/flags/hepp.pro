;+
; NAME:
;       HEPP
;
;            ============
;            Syntax: hepp
;            ============
;
;   hepp    Flag the  channels at the position of the He++ O++ 146alpha, 173eta, 
;   ----    194-10, 211-11, He++ O++ 146 alpha, 173eta, 194-10, 211-11
;           recomb lines for pn1 setup
;           center 8370 MHz
;
; V5.0 July 2007
;-
pro hepp
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN
;
; define channel array
;
xchan=fltarr(9)
xchan=[1340.4,1060.7, 998.0,$
       2087.1,2024.4,2016.5,$
       3259.6,2980.6,2918.0]
label=['H173\eta','He173\eta','C173\eta',$
       'He++146\alpha','C++146\alpha','O++146\alpha',$
       'H190\kappa','He190\kappa','C190\kappa']
color=fltarr(9)
color=[!yellow,!yellow,!yellow,$
       !magenta,!magenta,!magenta,$
       !gray,!gray,!gray]
;
; get x data range  -- automatically flip for freq axis
;
xmin=min(!x.crange,max=xmax)
;
for i=0,n_elements(xchan)-1 do begin
    if !xx[xchan[i]] gt xmin and !xx[xchan[i]] lt xmax then $
       flg_id,!xx[xchan[i]],textoidl(label[i]),color[i]
endfor
;
@CT_OUT
return
end
