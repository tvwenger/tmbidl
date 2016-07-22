pro wrap,chan,reshow_flag,help=help
;+
; NAME:
;       WRAP 
;
;   wrap.pro   slide the !b[0] spectrum by #_channels via IDL SLIDE 
;   --------   #_channels < 0 wraps left, obviously! 
;              #_channels at appropriate end of spectrum set to 0  
;              since IDL SLIDE wraps the data 
;
;              if reshow_flag set to *any* number then RESHOW
;            
;              Syntax: wrap,#_channels[,reshow_flag],help=help
;              ===============================================
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'wrap' & return & endif
;
data=!b[0].data
copy,0,15
;
!b[15].data=shift(data,chan)
copy,15,0
;
nmax=!b[0].data_points
mask=abs(chan)
;
if chan gt 0 then !b[0].data[0:mask]=0.0 $
             else !b[0].data[nmax-1-mask:nmax-1]=0.0
;
if n_params() gt 1 then reshow
;
return
end


