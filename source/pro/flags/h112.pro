;
;   h112.pro   Flag in channels the position of the H112alpha, He112alpha, and C112alpha
;   -------   center/bw = 4619.94/12.5
;
pro h112
;
on_error,!debug ? 0 : 2
@CT_IN
;
; define channel array
;
xchan=fltarr(3)
xchan=[1672.0,2288.8,2427.2]
label=['H112\alpha','He112\alpha',' ']
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
