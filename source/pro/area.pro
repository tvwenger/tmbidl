pro area,peak,area,help=help
;+
;NAME
;   AREA
;
;   area,peak,area,help=help
;
;   area.pro   Find peak and calculate area of spectrum
;   --------   Currently hardwired so that x-axis range for this
;              calculation is set by what is currently plotted
;   => N.B. => This works for *any* x_axis definition
;              
;              RETURNS peak,area -- do NOT input them
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'area' & return & endif
;
; get data ranges
;
xmin = !x.crange[0] 
xmax = !x.crange[1] 
idchan,xmin,chmin      ;  get min,max in channels
idchan,xmax,chmax      
if (chmin gt chmax) then begin
                         hold  = chmin
                         chmin = chmax
                         chmax = hold
                    endif
;
ymin = !y.crange[0]
ymax = !y.crange[1]
xrange = xmax-xmin     ;  ranges are in plot units
yrange = ymax-ymin
;
peak=max(!b[0].data[chmin:chmax])
area=total(!b[0].data[chmin:chmax])
;
dv= (!b[0].bw*!light_c)/!b[0].sky_freq
dv= dv/!nchan
area=area*dv           ;  in K km/sec
;
labpk='Peak = '
labar=' K  Area = '
labun=' K km/sec'
fmt='(a,f7.2,a,f9.1,a)'
if !flag then print,labpk,peak,labar,area,labun,format=fmt
;
return
end
