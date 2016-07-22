;
;   h89.pro   Flag in channels the position of the H89alpha, He89alpha, and C89alpha
;   -------   center/bw = /50
;
pro h89
;
on_error,!debug ? 0 : 2
@CT_IN
;
; define channel array
;
xchan=fltarr(12)
xchan=[2842.6,2536.4,2467.7,$
       1440.4,1133.6,1064.8,$
       2138.0,1831.6,1762.8,$
       3960.2,3654.4,3585.9]
label=['H89\alpha','He89\alpha',' ',$
       'H140\delta','He140\delta',' ',$
       'H175\theta','He175\theta',' ',$
       'H188\kappa','He188\kappa',' ']
color=fltarr(12)
color=[!red,!red,!red,$
       !cyan,!cyan,!cyan,$
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
