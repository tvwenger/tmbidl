;
;   h91.pro   Flag in channels the position of the H91alpha, He91alpha, and C91alpha
;   -------   center/bw = 8584.8231/50
;             colors: alpha (red), beta (green), gamma (blue), delta
;             (cyan), epsilon (purple), others (grey)
;          
;
pro h91
;
on_error,!debug ? 0 : 2
@CT_IN
;
; define channel array
;
xchan=fltarr(12)
xchan=[2049.9,1763.2,1699.0,$
       2234.1,1947.6,1883.3,$
       1418.3,1131.5,1067.2,$
       3215.0,2928.8,2864.7]
label=['H91\alpha','He91\alpha',' ',$
       'H154\epsilon','He154\epsilon',' ',$
       'H179\theta','He179\theta',' ',$
       'H186\iota','He186\iota',' ']
;label=['H91\alpha','He91\alpha','C91\alpha',$
;       'H154\epsilon','He154\epsilon','C154\epsilon',$
;       'H179\theta','He179\theta','C179\theta',$
;       'H186\iota','He186\iota','C186\iota']
color=fltarr(12)
color=[!red,!red,!red,$
       !purple,!purple,!purple,$
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
