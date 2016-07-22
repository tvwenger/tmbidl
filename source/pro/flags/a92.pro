;+
; NAME:
;      A92
;
;   a92  Flag in channels the position of the recomb lines for pn1 setup
;  ----  center 8325    92alpha, 165zeta, 181theta, 188iota
 ;
; V5.0 July 2007
;-
pro a92
; 
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN
;
; define channel array
;
xchan=fltarr(12)
xchan=[2731.4,2453.8,2391.5,$
       3602.6,3325.3,3263.1,$
       3326.8,3049.3,2987.1,$
       1915.6,1637.6,1575.3]
label=['H181\theta','He181\theta','C181\theta',$
       'H188\iota','He188\iota','C188\iota',$
       'H92\alpha','He92\alpha','C92\alpha',$
       'H165\zeta','He165\zeta','C165\zeta']
color=fltarr(12)
color=[!gray,!gray,!gray,$
       !gray,!gray,!gray,$
       !cyan,!cyan,!cyan,$
       !forest,!forest,!forest]
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
