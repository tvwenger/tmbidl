;
;   h90.pro   Flag in channels the position of the H90alpha, He90alpha, and C90alpha
;   -------   center/bw = 8877.00/50
;
pro h90
;
on_error,!debug ? 0 : 2
@CT_IN
;
; define channel array
;
xchan=fltarr(12)
xchan=[2412.1,2116.0,2049.5,$
       1906.5,1610.1,1543.6,$
       1870.2,1573.8,1507.3,$
       1745.3,1448.8,1382.4]
label=['H90\alpha','He90\alpha',' ',$
       'H113\beta','He113\beta',' ',$
       'H129\gamma','He129\gamma',' ',$
       'H177\theta','He177\theta',' ']
color=fltarr(12)
color=[!red,!red,!red,$
       !green,!green,!green,$
       !blue,!blue,!blue,$
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
