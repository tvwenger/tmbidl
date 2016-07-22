;+
; NAME:
;       G131
;
;            ============
;            Syntax: g131
;            ============
;
;   g131   Flag the channels of the position of the 
;   ----   recomb lines for pn1 setup
;          center freq  8474 131Gamma,193kappa,164zeta,144delta
;
; V5.0 July 2007
;-
pro g131
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN
;
; define channel array
;
xchan=fltarr(12)
xchan=[1304.4,1021.2,  957.7,$
       1347.1,1063.9, 1000.4,$
       1789.5,1506.5, 1443.0,$
       3574.9,3292.6, 3229.3]
label=['H130\gamma','He130\gamma','C130\gamma',$
       'H193\kappa','He193\kappa','C193\kappa',$
       'H164\zeta','He164\zeta','C164\zeta',$
       'H144\delta','He144\delta','C144\delta']
color=fltarr(12)
color=[!green,!green,!green,$
       !gray,!gray,!gray,$
       !forest,!forest,!forest,$
       !blue,!blue,!blue]
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
