pro show,help=help,charsize=charsize
;+
; NAME:
;       SHOW
;
;       ========================================
;       SYNTAX: show,help=help,charsize=charsize
;       ========================================
;
;  show  Basic plot of data: plots data and header of contents of !b[0]
;  ----  Details of plot format chosen by def_xaxis.pro via: 
;               
;              If !chan  then x-axis is in channels       CHAN
;                 !freq                    frequency      FREQ
;                 !velo                    lsr velocity   VELO 
;                 !vgrs                    GRS velocity   VGRS
;                 COMMANDS BELOW ARE FOR CONTINUUM DATA ONLY
;                 !azxx                    azimuth deg    AZXX
;                 !elxx                    elevation deg  ELXX
;                 !raxx                    R.A. deg       RAXX
;                 !decx                    Dec. deg       DECX
;
; KEYWORDS: help     - gives this help
;           charsize - charsize for plot stuff, default is 2.0
;
;-
; MODIFICATION HISTORY:
;  V5.0  June 2007 
;  by TMB to preserve Color Table, and find y_axis units and type
;
; V6.0 26 June 2009 dsb/tmb  force x-axis to increase to the right
;      21 Aug 09 tmb  installed trap to catch undisplayable NaNs
;
; V6.1 27aug09 tmb made robust w.r.t. IDL window management 
;      19mar10 tmb tweaked to support seamless PS printing scheme
;      tvw 30jul2012 - added charsize keyword
;
; V7.0 03may2013 tvw - added /help, !debug
;      22jul2013 lda - added reset_rdplot at beginning
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'show' & return & endif
;
if ~keyword_set(charsize) then charsize=2.0
;
; reset display
if !d.name eq 'X' then reset_rdplot
;
; trap any NaNs in !b[0].data
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
window_state=!d.window ;  save current window unit
@CT_IN
;
def_xaxis    ;    define x-axis units via: CHAN, FREQ, VELO, etc. commands which
;                 set the flags listed above
def_yaxis    ;    define y_axis units and type via !b[0].yunits, !b[0].ytype
;
clr=!d.name eq 'PS' ? !black : !white
;
case 1 of                   ; choose whether this is LINE or CONTINUUM data
;                           ; N.B. => it uses y-axis from last SHOW 
!LINE eq 1: begin                    ;   LINE data case
;              plot,!xx,!b[0].data,/xstyle,/ystyle,charthick=2.0,color=clr
              plot,!xx,!b[0].data,/xstyle,/ystyle,xrange=[min(!x.range),max(!x.range)],$
                   charsize=charsize,charthick=2.0,color=clr
              end                    
        else: begin                    ;   CONTINUUM data case
;              plot,!xx[0:!c_pts-1],!b[0].data[0:!c_pts-1],/xstyle,/ystyle, $
;                   charthick=2.0,color=clr
              plot,!xx[0:!c_pts-1],!b[0].data[0:!c_pts-1],/xstyle,/ystyle, $
                   charsize=charsize,charthick=2.0,color=clr, $
                   xrange=[min(!x.range),max(!x.range)]
              end
endcase
;
if !plthdr then begin ; plot header if flag set 
    case !LINE of  ; choose LINE or CONTINUUM if LINE, what data? GBT or GRS?
               1: case !GRSMODE of ;   LINE header
                                1: case !clr of;   GRS header                  
                                             1: plt_grshdr ; x-term/clr
                                          else: printhdr   ; PS/BW
                                   endcase
                            else : case !clr of ;   GBT header 
                                             1: plthdr   ; x-term/clr
                                          else: printhdr ; PS/BW
                                   endcase
                  endcase
;
            else: case !clr of ;   CONTINUUM header
                            1:  pltChdr ; x-win
                         else:  pltChdr ; PS
                  endcase
    endcase
endif
;
@CT_OUT
;
if !zline  then zline                    ; plot zero intensity if flag set
if !srcvl  then srcvl                    ; flag for source position to go here
if !bmark  then bmark                    ; plot nregion zones if flag set 
if NaN eq 1 then begin
   NaN=0
   qqq='!!!! NaN !!!! NaN !!!! NaN !!!!'
   xyouts,.2,.5,qqq,/normal,charsize=5.,charthick=3.,color=clr
endif
;
copy,0,9                                   ; store copy in buffer 9

;
flush:
return
end
