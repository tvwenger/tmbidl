;
;   h109.pro   Flag in channels the position of the H109alpha, He109alpha, and C109alpha
;   -------   center/bw = 5008.23/12.5
;
pro h109
;
on_error,!debug ? 0 : 2
@CT_IN
;
; define channel array
;
xchan=fltarr(6)
xchan=[2276.0,2945.0,3094.9,$
       1001.5,1669.8,1819.7]
label=['H109\alpha','He109\alpha',' ',$
       'H137\beta','He137\beta',' ']
color=fltarr(6)
color=[!red,!red,!red,$
       !green,!green,!green]
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
