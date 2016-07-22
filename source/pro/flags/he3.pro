;+
; NAME:
;       HE3
;
;            ===========
;            Syntax: he3
;            ===========
;
;   he3   Flag the channels at the position of the 3-He band 
;   ---   recomb lines for Dec03 setup also valid for jun04
;
;         9 feb 04 modification to shows flags only inside current x-axis display
;
; V5.0 July 2007
; tmb modified 4 Aug 07 to work for any x-axis definition
;-
pro he3
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN
;
; get data ranges
;
xmin=min(!x.crange,max=xmax)
ymin=min(!y.crange,max=ymax)
xrange = xmax-xmin
yrange = ymax-ymin
yincr=0.025*yrange
;
; 3He+
;
ch_he3=2020.3
;
if !xx[ch_he3] gt xmin and !xx[ch_he3] lt xmax then begin
   plots, ch_he3,ymin
   plots, ch_he3,ymax+yincr,/continue,thick=2.0,color=!green
   xyouts,ch_he3,ymax+yincr+yincr/4.,textoidl('^3He^+'),/data, $
         alignment=0.5,color=!green,charsize=2.0,charthick=2.0
endif
;
; define channel array
;
xchan=fltarr(10)
xchan=[3376.4,3087.7,3022.9,$
        999.2, 709.5, 644.4,$
       1645.9,1356.4,1291.6,2171.6]
label=['H114\beta','He114\beta','C114\beta',$
       'H130\gamma','He130\gamma','C130\gamma',$
       'H171\eta','He171\eta','C171\eta','H213\xi']
color=fltarr(10)
color=[!red,!red,!red,$
       !orange,!orange,!orange,$
       !yellow,!gray,!gray,!gray]
;
for i=0,n_elements(xchan)-1 do begin
    if !xx[xchan[i]] gt xmin and !xx[xchan[i]] lt xmax then $
       flg_id,!xx[xchan[i]],textoidl(label[i]),color[i]
endfor
;
@CT_OUT
return
end
