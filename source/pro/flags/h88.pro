;
;   h88.pro   Flag in channels the position of the H88alpha, He88alpha, and C88alpha
;   -------   center/bw = 9505.00/50
;
pro h88
@CT_IN
;
on_error,!debug ? 0 : 2
;
; define channel array
;
xchan=fltarr(9)
xchan=[3456.9,3140.2,3069.2,$
       742.5,424.7,353.4,$
       2711.2,2394.1,2323.1]
label=['H88\alpha','He88\alpha',' ',$
       'H126\gamma','He126\gamma',' ',$
       'H173\theta','He173\theta',' ']
color=fltarr(9)
color=[!red,!red,!red,$
       !cyan,!cyan,!cyan,$
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
