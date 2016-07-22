pro idval,xchan,xval,help=help
;+
; NAME:
;      IDVAL
;
;  idval   Take x-axis channel number and returns the value !xx(xchan)
;  -----    
;                   If !chan then xval is in channels
;                      !freq                 frequency 
;                      !velo                 lsr velocity
;                      !elxx                 elevation
;                      !azxx                 azimuth
;                      !raxx                 right ascension
;                      !decx                 declination
;
;                      !vgrs                 GRS velocity axis
;
;          ==================================
;          Syntax: idval,xchan,xval,help=help
;          ==================================
;          xchan= x-axis channel number 
;          xval= x-axis value of that channel = !xx[xchan]
;-                      
; V5.0 July 2007 modified to reflect channels about center if FREQ x-axis
; V5.0 Feb  2008 tmb modified to force xchan to be integer
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'idval' & return & endif
;
def_xaxis,num_pts     ; fill !xx with x-axis values and find the 
                      ; number of points in the axis for the search
;
xchan=round(xchan)
xval=!xx[xchan]
;
if !verbose and not !batch then print,xchan,xval
;
return
end
