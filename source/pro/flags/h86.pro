;
;   h86.pro   Flag in channels the position of the H86alpha, He86alpha, and C86alpha
;   -------   center/bw = 10161.3027/50
;
pro h86
;
on_error,!debug ? 0 : 2
@CT_IN
;
; define channel array
;
xchan=fltarr(12)
xchan=[2048.0,1708.8,1632.8,$
       2349.9,2010.8,1934.7,$
       1835.4,1496.1,1420.0,$
       1214.1,874.6,798.4]
label=['H86\alpha','He86\alpha',' ',$
       'H108\beta','He108\beta',' ',$
       'H162\eta','He162\eta',' ',$
       'H169\theta','He169\theta',' ']
color=fltarr(12)
color=[!red,!red,!red,$
       !green,!green,!green,$
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
