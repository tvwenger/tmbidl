function mkrmsimage, A, H, Hnew,window, chan=chan, DONTBLANK=DONTBLANK
                     
;+
;
; PURPOSE:
;	Create rms image from spectral data cube
;
; CALLING SEQUENCE:	
;	rms = mkrmsimage(A,H,rmsH,window,/chan,moment=moment)
;	
; INPUTS:
;	A    :  input FITS cube in vlm format
;       H    :  input header structure
;     window :  vector containing spectral windows to exclude from 
;               polynomial calculation 
;
; KEYWORD PARAMETERS
;     chan  :   if set use channel interval units (velocity default)
;     dontblank: By default, momentcube will use the BLANK fits header
;                value and automatically zero blanked values in order
;                to compute moments. If dontblank keyword is set, then
;                such blanking is not performed.
;
; OUTPUTS:
;        rms : 2d image with rms values
;        rmsH : header for rms
;
; EXAMPLE:
;  co = read_fits('somefile.fits',co_head)
;  w=[20,25, 35,40]
;  rms = mkrmsimage(co,co_head,rmsH,w)
;
; Author:
; 	M. Heyer 20 Nov 2002 

on_error,!debug ? 0 : 2

if N_params() LT 4 THEN BEGIN
    print,'Syntax - rms = mkrmsimage(A,H,rmsH,window,/chan,/dontblank)'
    return, 0
endif


; calculate the x-axis (velocity) for plotting purposes    
crpix1=sxpar(H,"CRPIX1")
crval1=sxpar(H,"CRVAL1")
; convert velocity to km/s
crval1=crval1/1000.
cdelt1=sxpar(H,"CDELT1")
cdelt1=cdelt1/1000.
ctype1=sxpar(H,"CTYPE1")
crpix2=sxpar(H,"CRPIX2")
crval2=sxpar(H,"CRVAL2")
cdelt2=sxpar(H,"CDELT2")
ctype2=sxpar(H,"CTYPE2")
crpix3=sxpar(H,"CRPIX3")
crval3=sxpar(H,"CRVAL3")
cdelt3=sxpar(H,"CDELT3")
ctype3=sxpar(H,"CTYPE3")

nv=sxpar(H,"NAXIS1")
nx=sxpar(H,"NAXIS2")
ny=sxpar(H,"NAXIS3")
blank = sxpar(H,"BLANK")

; zero out all blanked values
B = A
if not keyword_set(dontblank) then begin 
    ind = where(B eq blank, count)
    if (count gt 0) then B[ind] = 0.0
endif


;chan=0````
sz=size(window)
nw=floor(sz(1)/2.)
if (nw ne sz(1)/2.) then begin
    print,'window vector must contain an even number of elements'
    return, 0
endif

; determine baseline window from input window vector
x=findgen(nv)
for iw=1,nw do begin
 v1=window(2*(iw-1))
 v2=window(2*(iw-1)+1)
 if keyword_set(chan) then begin
    xch1=v1
    xch2=v2
    if (v2 lt v1) then begin
        xch1=v2
        xch2=v1
    endif
 endif else begin
    xch1 = (crpix1-1)+ fix((v1-crval1)/cdelt1)
    xch2 = (crpix1-1)+ fix((v2-crval1)/cdelt1)
    if (xch2 lt xch1) then begin
        tmp = xch2
        xch2=xch1
        xch1=tmp
    endif
 endelse
 
 idx=where(x ge xch1 and x le xch2, ct)
 if (iw eq 1) then begin 
   index=idx
 endif else begin
   index=[index,idx]
 endelse
endfor 

; find unique channels which define baseline window
xw=index(uniq(index,sort(index)))
; now fnd all channels which lie outside this window
xw1=lonarr(nv)-1   ; initialize all values to -1
xw1(xw)=xw         ; 
xb=where(x ne xw1, ct)

; Now that baseline channels are established, step thru each spectrum,

RMS=fltarr(nx,ny)

for j=0,ny-1 do begin
 for i=0,nx-1 do begin
    RMS(i,j)=stddev(B(xb,i,j))
 endfor
endfor
    
; Add FITS headers o
Hnew=H
sxaddpar,Hnew,"CRVAL1",crval2,"DEGREES"
sxaddpar,Hnew,"CRPIX1",crpix2
sxaddpar,Hnew,"CDELT1",cdelt2,"DEGREES"
sxaddpar,Hnew,"CTYPE1",ctype2
sxaddpar,Hnew,"CRVAL2",crval3,"DEGREES"
sxaddpar,Hnew,"CRPIX2",crpix3
sxaddpar,Hnew,"CDELT2",cdelt3,"DEGREES"
sxaddpar,Hnew,"CTYPE2",ctype3
sxaddpar,Hnew,"NAXIS", 2
sxaddpar,Hnew,"NAXIS1",nx
sxaddpar,Hnew,"NAXIS2",ny
sxaddpar,Hnew,"NAXIS3",1
sxaddpar,Hnew,"NAXIS4",1

sxdelpar,Hnew,"CRVAL3" 
sxdelpar,Hnew,"CRPIX3" 
sxdelpar,Hnew,"CDELT3" 
sxdelpar,Hnew,"CTYPE3" 
sxaddhist,'FCRAO/IDL mkrmsimage Program',Hnew
sxaddhist,'RMS Windows',Hnew
info=string(window)
sxaddhist,info,Hnew

return,RMS
end
