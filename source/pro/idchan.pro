pro idchan,xval,xchan,help=help
;+
; NAME:
;      IDCHAN
;
;  idchan    Takes xaxis value and returns channel number of !xx array 
;  ------    element whose value is closest.  i.e. finds channel number
;                associated with an x-axis value in one of the following 
;                co-ordinate systems:
;                   If !chan  then x-axis is in channels
;                      !freq                    frequency 
;                      !velo                    lsr velocity
;                      !elxx                    elevation
;                      !azxx                    azimuth
;                      !raxx                    right ascension
;                      !decx                    declination
;
;             ==================================
;             Syntax:idchan,xval,xchan,help=help   
;             ==================================  
;             xval=  x-axis value xchan= channel in !b[0] with that value
;-
; V5.0 July 2007
;
; V6.0 20 Aug 2009 lda fixed bug wherein there might be multiple
;                  minima for a cursor read 
;
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'idchan' & return & endif
;
def_xaxis,num_pts               ; fill !xx with x-axis values and find the 
                                ; number of points in the axis for the search
xarr=fltarr(num_pts)            ; calculate absolute difference 
xarr[0:num_pts-1]=xval 
xarr=abs(!xx[0:num_pts-1]-xarr)
;
xchan=(where (xarr eq min(xarr)))[0] ; channel is at the minimum
;
if !verbose and not !batch then print,xval,xchan
;
return
end
