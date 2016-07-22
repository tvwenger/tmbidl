pro annotate,help=help
;+
; NAME:
;       ANNOTATE
;
;            ==========================
;            Syntax: annotate,help=help
;            ==========================
;
;
;   annotate  annotate plot with arbitrary information.
;   --------
;             YOU MUST CODE YOUR OWN INFORMATION THIS IS A SHELL!
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
;
if keyword_set(help) then begin & get_help,'annotate' & return & endif
;
@CT_IN
;
; top level of info
;
title='ARECIBO COMPOSITE PNe: NGC6210 + NGC6891'
xyouts,.10,.85,title,/normal,charsize=3.0,charthick=3.0, $
       color=!magenta                                          ; 
;
tintg=!b[0].tintg/3600.
tintg=fstring(tintg,'(f4.1)')
tintg=tintg+' hour integration'
xyouts,.15,.75,tintg,/normal,charsize=2.0,charthick=2.0, $
       color=!red
;
res='8.4 km/s resolution'
xyouts,.15,.70,res,/normal,charsize=2.0,charthick=2.0, $
       color=!red
;
; ID the lines -- use data units 
;
he3=textoidl('^3He^+')
x=276. & y=1.60 &
xyouts,x,y,he3,/data,alignment=0.5,color=!magenta, $
               charsize=3.0,charthick=2.0
hgam=textoidl('H130\gamma')
x=763. & y=4.45 &
xyouts,x,y,hgam,/data,alignment=0.5,color=!green, $
                charsize=2.0,charthick=2.0
heta=textoidl('H171\eta')
x=438. & y=1.30 &
xyouts,x,y,heta,/data,alignment=0.5,color=!green, $
               charsize=2.0,charthick=2.0
;
plots,900.,-0.50
plots,941.,-0.50,/continue,thick=3.0,color=!red
label='1 MHz'
x=920.5 & y=-0.8 &
xyouts,x,y,label,/data,alignment=0.5,color=!red, $
                 charsize=3.,charthick=3.   
;
sigma3=3*0.30404649
label=textoidl('3\sigma')
plots,150.,+sigma3/2.
plots,150.,-sigma3/2.,/continue,thick=3.0,color=!red
x=150. & y=sigma3/2.+.05 &
xyouts,x,y,label,/data,alignment=0.5,color=!red, $
                 charsize=3.,charthick=3.
;
plots,262.,-0.50
plots,298.,-0.50,/continue,thick=3.0,color=!red
label='30 km/s'
x=280. & y=-0.8 &
xyouts,x,y,label,/data,alignment=0.5,color=!red, $
                 charsize=3.,charthick=3.
;
@CT_OUT
return
end
