pro reshow,color=color,help=help
;+
; NAME:
;       RESHOW
;
;            =============================================
;            Syntax: reshow, sysvar_color_to_use,help=help
;            =============================================
;
;  reshow    Overplot existing plot using identical plot parameters.
;  ------
;                   If CHAN !chan  then x-axis is in channels
;                   FREQ !freq                    frequence
;                   VELO !velo                    lsr velocity
;
;             See SHOW for more information about x-axis.
;-
; V5.0 June 2007   
; V5.1 Jan  2008 tmb to work for PS files
;
; V6.0 21aug09 tmb NaN trap
;
; V6.1 19mar10 tmb tweaked for seamless PS output
; V7.0 03may2013 tvw - added /help, !debug
;
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'reshow' & return & endif
;
NaN=0
is_data_finite=size(where(finite(!b[0].data)))
if is_data_finite[0] eq 0 then begin    ; if true then there are NaNs
   print,'***===> DATA HAS NaNs !!!! CANNOT BE DISPLAYED <===***'
   flag_state=!flag & !flag=0 & hdr & !flag=flag_state
   !b[0].data=0.
   NaN=1
endif
;
@CT_IN
;
if ~Keyword_Set(color) then color=!red

case !clr of
             1: clr=color 
          else: clr=!d.name eq 'PS' ? !black : !white
endcase
;
def_xaxis
;
oplot,!xx,!b[0].data,color=clr
;
if NaN eq 1 then begin
   NaN=0
   qqq='!!!! NaN !!!! NaN !!!! NaN !!!!'
   xyouts,.2,.2,qqq,/normal,charsize=5.,charthick=3.,color=!yellow
endif
;
@CT_OUT
return
end
