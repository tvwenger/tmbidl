;
;   h107.pro   Flag in channels the position of the H107alpha, He107alpha, and C107alpha
;   -------   center/bw = 5295.05/12.5
;
pro h107
;
on_error,!debug ? 0 : 2
@CT_IN
;
; define channel array
;
xchan=fltarr(3)
xchan=[1617.3,2324.2,2482.8]
label=['H107\alpha','He107\alpha',' ']
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
