pro boxcar,nch,help=help   ;  nch is the number of channels for the boxcar
;+
; NAME:
;       BOXCAR
;
;            =========================================
;            Syntax: boxcar, number_channels,help=help
;            =========================================
;
;   boxcar  Apply a boxcar smoothing function to !b[0].data
;   ------
;            number_channels is the number of channels for the boxcar 
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
if keyword_set(help) then begin & get_help,'boxcar' & return & endif
@CT_IN
;
if (n_params() eq 0) then begin
                     print,'Need to specify number of channels to smooth:  boxcar,#'
                     return
                     endif
if (nch le 2) then begin
              print,'Number of smoothing channels must exceed 2'
              return
              endif
;
copy,0,8         ;  copy raw data to buffer 8
;
!b[0].data = smooth(!b[0].data,nch)
;
clr=!green
get_clr,clr
oplot,!xx,!b[0].data,thick=2,color=clr
;
pause                              ; build in a pause  ans is any string
;
show
;
;
@CT_OUT
return
end
