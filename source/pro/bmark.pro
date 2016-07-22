pro bmark,help=help
;+
; NAME:
;       BMARK
;
;       =======================
;       SYNTAX: bmark,help=help
;       =======================
;
;   bmark  Draw NREGION boxes +/- 1.5 sigma from mean. 
;   -----  Boxes are 3 sigma high. 
;
;          Keywords:  /help  - gives this help
;-
;
;  V5.0 July 2007 tmb restored and fixed rtr's version
;  10 Aug 2007 tmb fixed bug in x-axis identification
;  NRSET and MRSET store the NREGIONs in the current x-axis units
; V5.0 July 2007 
; V6.2 March 2010 tmb tweaked to make PS output seamless
;
; V7.0 3may2013 tvw - added /help, !debug
;     28jun2013 tmb - added code to deal with any X-axis
;                     units using !nrtype
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'bmark' & return & endif
@CT_IN
;
; check to see if NREGIONs are set
if !nrset eq 0 then begin
                    print,'Cannot display NREGIONs as none are set yet'
                    return
                    end
; 
case !clr of 
       1: clr=!magenta
    else: clr=!d.name eq 'PS' ? !black : !white
endcase
get_clr,clr
;
; get data ranges
;
xmin = min(!x.crange, max=xmax)  ; in current x-axis units
ymin = min(!y.crange, max=ymax)
xrange = xmax-xmin
yrange = ymax-ymin
yincr=0.025*yrange
;
mask,dsig,index                  ; index is in channel (array location)  units
yy=dblarr(n_elements(index))
yy=!b[0].data[index]
ybar=mean(yy)
;
yplus=ybar+1.5*dsig 
yminus=ybar-1.5*dsig
;
; get NREGION's values in current axis units
;
nr=!nregion[0:2*!nrset-1]  ; get just what is there
nregions,nr,/noInfo,/noFlag
;
for i=0,2*!nrset-2,2 do begin
    nrstart=nr[i] & nrstop=nr[i+1] &
    if nrstart lt xmin then nrstart=xmin
    if nrstop  gt xmax then nrstop=xmax
    if nrstop  lt xmin then nrstop=xmin
    if nrstart ge xmin and nrstop le xmax $ 
       then begin
       plots,nrstart,yminus
       plots,nrstart,yplus,/continue,color=clr
       plots,nrstop, yplus,/continue,color=clr
       plots,nrstop, yminus,/continue,color=clr
       plots,nrstart,yminus,/continue,color=clr
       end
endfor
;
@CT_OUT
return
end
