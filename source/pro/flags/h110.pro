;
;   h110.pro   Flag in channels the position of the H110alpha, He110alpha, and C110alpha
;   -------   center/bw = 4875.38/12.5
;
pro h110
;
on_error,!debug ? 0 : 2
@CT_IN
;
; define channel array
;
xchan=fltarr(3)
xchan=[1648.4,2299.2,2445.3]
label=['H110\alpha','He110\alpha',' ']
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
