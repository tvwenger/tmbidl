;+
; NAME:
;      A91
;
;   a91   the position of the H91alpha, He91alpha, and C91alpha
;   ---   recomb lines for jn04 setup
;
; V5.0 August 2007
; tmb modified all such procedures to work with any x-axis definition
;-
pro a91
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN
;
; define channel array
;
xchan=fltarr(12)
xchan=[2192.1,1905.5,1841.2,$
       2376.4,2089.8,2025.6,$
       1209.4,1273.7,1560.5,$
       3006.9,3071.1,3357.2]
label=['H91\alpha','He91\alpha','C91\alpha',$
       'H154\epsilon','He154\epsilon','C154\epsilon',$
       'C179\theta','He179\theta','H179\theta',$
       'C186\iota','He186\iota','H186\iota']
color=fltarr(12)
color=[!cyan,!cyan,!cyan,$
       !purple,!purple,!purple,$
       !gray,!gray,!gray,$
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
