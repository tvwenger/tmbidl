;+
;   aohe3.pro   Flag in channels the position of the 3-He band 
;   ---------   recomb lines for Dec03 setup
;               9 feb 04 rewritten to ensure that only flags within current display
;                        are drawn
;             Modified for BOZO jl05. 
;   BOZO flag
;
; V5.0 July 2007
;-
pro aohe3
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN
;
; get data ranges
;
xmin = !x.crange[0]
xmax = !x.crange[1]
ymin = !y.crange[0]
ymax = !y.crange[1]
xrange = xmax-xmin
yrange = ymax-ymin
yincr=0.025*yrange
;
; 3He+
;
ch_he3=250.90
if ((ch_he3 gt xmin) and (ch_he3 lt xmax)) then begin
   plots, ch_he3,ymin
   plots, ch_he3,ymax+yincr,/continue,thick=2.0,color=!green
   xyouts,ch_he3,ymax+yincr+yincr/4.,textoidl('^3He^+'),/data, $
         alignment=0.5,color=!green,charsize=2.0,charthick=2.0
endif
;
; define channel array
;
xchan=fltarr(5)
xchan=[761.5,906.30,938.8,$
       438.1,175.2]
label=['H130\gamma','He130\gamma','C130\gamma',$
       'H171\eta','H213\xi']
color=fltarr(5)
color=[!blue,!blue,!blue,$
       !gray,!gray]
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
