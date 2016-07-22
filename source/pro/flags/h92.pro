;
;   h92.pro   Flag in channels the position of the H92alpha, He92alpha, and C92alpha
;   -------   center/bw = 8300.00/50
;
pro h92
;
on_error,!debug ? 0 : 2
@CT_IN
;
; define channel array
;
xchan=fltarr(15)
xchan=[1278.8,1001.3,939.1,$
       2553.6,2276.8,2214.6,$
       3364.0,3087.5,3025.4,$
       683.4,405.8,343.5,$
       1554.6,1277.3,1215.1]
label=['H92\alpha','He92\alpha',' ',$
       'H132\gamma','He132\gamma',' ',$
       'H145\delta','He145\delta',' ',$
       'H181\theta','He181\theta',' ',$
       'H181\iota','He181\iota',' ']
color=fltarr(12)
color=[!red,!red,!red,$
       !blue,!blue,!blue,$
       !cyan,!cyan,!cyan,$
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
