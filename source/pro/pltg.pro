pro pltg,help=help
;+
; NAME:
;       PLTG
;
;            ======================
;            Syntax: pltg,help=help
;            ======================
;
;   pltg   Annotate plot with gaussian fit values.
;   ----   Assumes data are in !a_gauss
;-
;  V5.0 July 2007
;  V6.1 March 2010 tmb tweak for seamless PS output
; V7.0 03may2013 tvw - added /help, !debug
;
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
if keyword_set(help) then begin & get_help,'pltg' & return & endif
@CT_IN
; 
case !clr of 
       1: clr=!magenta
    else: clr=!d.name eq 'PS' ? !black : !white
endcase
;
a=!a_gauss[0:3*!ngauss-1]
lab='       P        C         W'
off=-.03
get_clr,clr
;
xyouts,.13,.81,lab,/normal,charsize=1.5,charthick=2.0,color=clr ; label
;
for i=0,!ngauss-1 do begin
        h=a[0+3*i]
        c=a[1+3*i]
        w=a[2+3*i]
        sh=fstring(h,'(f10.3)')
        sc=fstring(c,'(f10.3)')
        sw=fstring(w,'(f10.3)')
;
        y=.77+i*off
        xyouts,.13,y,sh,/normal,charsize=1.5,charthick=2.0,color=clr ; peak
        xyouts,.22,y,sc,/normal,charsize=1.5,charthick=2.0,color=clr ; center
        xyouts,.31,y,sw,/normal,charsize=1.5,charthick=2.0,color=clr ; width
endfor
;
@CT_OUT
return
end
