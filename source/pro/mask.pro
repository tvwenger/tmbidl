pro mask,dsig,index,help=help      
;+
; NAME:
;       MASK
;
;       ================================
;       SYNTAX:mask,dsig,index,help=help
;       ================================
;
; mask   Use NREGION information to extract x/y-axis values for 
; ----   fitting routines.  Returns rms in masked regions and 
;        index of nregion locations.  
;
;        RETURNS:  dsig  => rms of masked regions 
;                  index => NREGION locations in current x-axis units
;
;        index is used to parse the x/y-axis arrays for curve fits
;        index contains the channel numbers INSIDE the NREGIONs
;
;        KEYWORDS:  /help - gives this help
;
;-                   
; MODIFICATION HISTORY:
; TMB modified so mask works with any x-axis definition
; V5.0 12Aug2007
; V5.1  6Dec2007 modified to accomodate backwards continuum scans
;      25Feb2009 dsb modified to accomodate backwards velocity or frequency scans
;
; V6.0 June2009  adopted dsb version
;                N.B. dsb does not guarantee that the flipped freq axis work
;  6.1 31aug09 tmb fixed !nrset=0 bug. MASK needs a valid NREGION definition 
;      20jul12 tvw fixed bug where "index" is filled with all zeros
;                  because the for loop was never executed
; V7.0 03may2013 tvw - added /help, !debug
;      22may2013 tmb - added !verbose debug code at end 
;      28jun2013 tmb - added code that properly masks in any valid X-axis units
;                      no matter what native !nregion units are. uses !nrtype.
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
; Test to see if any NREGIONs are defined
if keyword_set(help) then begin & get_help,'mask' & return & endif
;
if !nrset eq 0 then begin
   print,'FATAL ERROR !!!'
   print,'NREGIONs are undefined and MASK requires valid NREGION definition'
return
endif
;
; get NREGION's values in current axis units
;
nr=!nregion[0:2*!nrset-1]  ; get just what is there
nregions,nr,/noInfo,/noFlag
;
nidx=0                                 ; establish size of compacted data arrays
for i=0,(2*!nrset-1),2 do begin
        idchan,nr[i+1],xchan1
        idchan,nr[i],xchan0
        nidx = nidx + (abs(xchan1[0]-xchan0[0])+1)
        endfor
index=intarr(nidx)
;  load data arrays with just these channels
kount=0
;
; CODE BELOW HERE MISSING FROM TVW'S VERSION 
;
;istep=1
;  adjust for backwards slewed continuum data
;typ=strtrim(string(!b[0].scan_type),2) & typ=strmid(typ,0,1)
;if typ eq 'B' and !chan ne 1 then istep=-1
; adjust if velocity scale is inverted for line data
;if (!b[0].delta_x gt 0.0) and (!velo eq 1) then istep=-1
; adjust if frequency scale is inverted for line data
;if (!b[0].delta_x lt 0.0) and (!freq eq 1) then istep=-1
;
;
for i=0,(2*!nrset-1),2 do begin   
        idchan,nr[i+1],xchan1
        idchan,nr[i],xchan0
        istep=1 
        if xchan0[0] gt xchan1[0] then istep=-1 
;       code line above from tvw this is a clever,
;       robust solution to the backwards x-axis problem
        for j=xchan0[0],xchan1[0],istep do begin                 
              index[kount]=j
              kount=kount+1
        endfor
endfor
;
if !verbose then begin & xx=!xx[index] & print,xx & end
;
yy=!b[0].data[index]
dsig=stddev(yy)
;
return
end
