;
;   h105.pro   Flag in channels the position of the H105alpha, He105alpha, and C105alpha
;   -------   center/bw = 5601.95/12.5
;
pro h105
;
on_error,!debug ? 0 : 2
@CT_IN
;
; define channel array
;
xchan=fltarr(3)
xchan=[1590.4,2338.3,2506.0]
label=['H105\alpha','He105\alpha',' ']
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
