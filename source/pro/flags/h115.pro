;+
; NAME:
;       H115
;
;            ============
;            Syntax: h115
;            ============
;
;   h115  Flag the channels of the position of H115 beta
;   ----  recomb lines for Dec03 setup
;
;         9 feb 04 modification to shows flags only inside current x-axis display
;
; V5.0 July 2007
;-
pro h115
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN
;
; define channel array
;
xchan=fltarr(15)
xchan=[3089.5,2808.1,2745.1,$
        789.6, 507.3, 444.0,$
       3681.3,3400.3,3337.2,$
        976.3, 694.1, 630.8,$
       2300.7,2019.8,1955.8]
label=['H115\beta','He115\beta','C115\beta',$
       'H144\delta','He144\delta','C144\delta',$
       'H155\epsilon','He155\epsilon','C155\epsilon',$
       'H180\theta','He180\theta','C180\theta',$
       'H187\iota','He187\iota','C187\iota']
color=fltarr(15)
color=[!red,!red,!red,$
       !blue,!gray,!gray,$
       !purple,!gray,!gray,$
       !gray,!gray,!gray,$
       !gray,!gray,!gray]
;
; get x data range
;
xmin = !x.crange[0]
xmax = !x.crange[1]
;
for i=0,n_elements(xchan)-1 do begin
      ;print,xchan[i],' ',label[i],color[i]
;
      if ((xchan[i] gt xmin) and (xchan[i] lt xmax)) then $
         flg_id,xchan[i],textoidl(label[i]),color[i]
endfor
;
@CT_OUT
return
end
