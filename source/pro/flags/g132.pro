;+
; NAME:
;       G132      
;
;            ============
;            Syntax: g132
;            ============
;
;   g132   Flag the  channels of the position of the               
;   ----   recomb lines for pn1 setup
;          center freq 8280  132gamma, 145delta, 156eps
;
; V5.0 July 2007
;-
pro g132
;
on_error,!debug ? 0 : 2
compile_opt idl2
@CT_IN
;
; define channel array
;
xchan=fltarr(9)
xchan=[0915.2,0638.4,0576.2,$
       1725.6,1449.1,1387.0,$
       3551.2,3275.4,3213.5]
label=['H132\gamma','He132\gamma','C132\gamma',$
       'H145\delta','He145\delta','C145\delta',$
       'H156\epsilon','He156\epsilon','C156\epsilon']
color=fltarr(12)
color=[!orange,!orange,!orange,$
       !blue,!blue,!blue,$
       !purple,!purple,!purple]
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
