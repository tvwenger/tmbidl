;
;   h106.pro   Flag in channels the position of the H106alpha, He106alpha, and C106alpha
;   -------   center/bw = 5445.62/12.5
;
pro h106
;
on_error,!debug ? 0 : 2
@CT_IN
;
; define channel array
;
xchan=fltarr(3)
xchan=[1603.6,2330.6,2493.6]
label=['H106\alpha','He106\alpha',' ']
color=fltarr(3)
color=[!red,!red,!red]
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
