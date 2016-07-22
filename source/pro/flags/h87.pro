;
;   h87.pro   Flag in channels the position of the H87alpha, He87alpha, and C87alpha
;   -------   center/bw = 9812.00/50
;
pro h87
;
on_error,!debug ? 0 : 2
@CT_IN
;
; define channel array
;
xchan=fltarr(15)
xchan=[1650.8,1323.1,1249.6,$
       3147.2,2820.0,2746.7,$
       1158.9,831.0,757.5,$
       862.0,534.0,460.4,$
       2708.1,2380.8,2307.5]
label=['H87\alpha','He87\alpha',' ',$
       'H137\delta','He137\delta',' ',$
       'H156\zeta','He156\zeta',' ',$
       'H171\theta','He171\theta',' ',$
       'H164\eta','He164\eta',' ']
color=fltarr(15)
color=[!red,!red,!red,$
       !cyan,!cyan,!cyan,$
       !gray,!gray,!gray,$
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
      if ((xchan[i] gt xmin) and (xchan[i]lt xmax)) then $
         flg_id,xchan[i],textoidl(label[i]),color[i]
endfor
;
@CT_OUT
return
end
