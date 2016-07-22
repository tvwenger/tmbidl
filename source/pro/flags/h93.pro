;
;   h93.pro   Flag in channels the position of the H93alpha, He93alpha, and C93alpha
;   -------   center/bw = 8045.60/50
;
pro h93
;
on_error,!debug ? 0 : 2
@CT_IN
;
; define channel array
;
xchan=fltarr(12)
xchan=[2049.8,1781.2,1720.9,$
       2829.8,2561.3,2501.3,$
       1483.4,1214.5,1154.2,$
       1504.4,1235.6,1175.3]
label=['H93\alpha','He93\alpha',' ',$
       'H167\zeta','He167\zeta',' ',$
       'H183\theta','He183\theta',' ',$
       'H190\iota','He190\iota',' ']
color=fltarr(12)
color=[!red,!red,!red,$
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
