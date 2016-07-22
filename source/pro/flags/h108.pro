;
;   h108.pro   Flag in channels the position of the H108alpha, He108alpha, and C108alpha
;   -------   center/bw = 5149.99/12.5
;
pro h108
;
on_error,!debug ? 0 : 2
@CT_IN
;
; define channel array
;
xchan=fltarr(6)
xchan=[1627.2,2314.8,2468.8,$
       1350.6,2038.0,2192.2]
label=['H108\alpha','He108\alpha',' ',$
       'H155\gamma','He155\gamma',' ']
color=fltarr(6)
color=[!red,!red,!red,$
       !blue,!blue,!blue]
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
