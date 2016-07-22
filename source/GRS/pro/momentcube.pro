function momentcube, A, H, Hnew,v1,v2, CHAN=CHAN, $
                     DONTBLANK=DONTBLANK, MOMENT=moment
;+
;
; PURPOSE:
;	create 2d moment image from cube
;
; CALLING SEQUENCE:	
;	map = momentcube(A,H,Hnew,v1,v2,/chan,moment=moment)
;	
; INPUTS:
;	A    :  input FITS cube in vlm format
;       H    :  input header structure
;       Hnew :  output header structure
;       v1  :  lower velocity
;       v2  :  upper velocity
;
; KEYWORD PARAMETERS
;     chan  :   if set use channel interval units (velocity default)
;     dontblank: By default, momentcube will use the BLANK fits header
;                value and automatically zero blanked values in order
;                to compute moments. If dontblank keyword is set, then
;                such blanking is not performed.
;     moment:   which moment to extract (moment=0 - integrated
;                                                   intensity
;                                              =1 - centroid velocity 
;                                              =2 - width
;                default is moment=0
;
; OUTPUTS:
;        Hnew : new header for output image
;        map : output 2d map
;
; EXAMPLE:
;  co = read_fits('somefile.fits',co_head)
;  int_intensity = momentcube(co,co_head,int_head,-10,10,moment=0)
;
; produces a 2-d integrated intensity image between -10 to 10 km/s 
; 
; Author:
; 	M. Heyer 4 Jan 2002 wrote newimage.pro that is starting point
; 	for this function
;       G. Narayanan, Sept 2002

on_error,!debug ? 0 : 2

if N_params() LT 2 THEN BEGIN
    print,'Syntax - map = momentcube(A,H,Hnew,v1,v2,moment=moment,/chan,/dontblank)'
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

I = intarr(2)
N = intarr(2)
N[0]=nx
N[1]=ny
;chan=0````
if keyword_set(chan) then begin
    I[0]=v1
    I[1]=v2
    if (v2 lt v1) then begin
        I[0]=v2
        I[1]=v1
    endif
endif else begin
    I[0] = crpix1+ fix((v1-crval1)/cdelt1)
    I[1] = crpix1 + fix((v2-crval1)/cdelt1)
    if (I[1] lt I[0]) then begin
        tmp = I[1]
        I[1]=I[0]
        I[0]=tmp
    endif
endelse

v=crval1+(findgen(nv)-(crpix1-1.))*cdelt1
print,"crval1 = ",crval1, " cdelt1 = ", cdelt1, "crpix1  = ", crpix1
print,"Integrating over channels ",I[0]," :",I[1]

if n_elements(moment) eq 0 then moment=0

case moment of
    0: begin
        T = fltarr(nx,ny)
    end
    1: begin
        T = fltarr(nx,ny)
        C=fltarr(nx,ny)
    end
    2: begin
        T = fltarr(nx,ny)
        C=fltarr(nx,ny)
        W=fltarr(nx,ny)
    end
endcase

for j =I[0], I[1] do begin
    T=T+B[j,*,*]
endfor 

if moment ge 1 then begin
    for j=I[0], I[1] do begin
        C = C + B[j,*,*]*v[j]
    endfor
    ind = where(T ne 0.0,complement=ind_comp)

    C[ind] = C[ind]/T[ind]
;    if (ind_comp ne -1) then C[ind_comp] = -1000.0     ; to avoid divide by zero problems
    if moment eq 2 then begin
        for j=I[0], I[1] do begin
            W = W + B[j,*,*]*v[j]^2
        endfor
        ind = where(T ne 0.0,complement=ind_comp)
        W[ind] = W[ind]/T[ind] - C[ind]^2
        if (ind_comp ne -1) then W[ind_comp] = -1000.0
    endif
endif

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
sxaddpar,Hnew,"VMIN",v1,"LOWER VELOCITY LIMIT"
sxaddpar,Hnew,"VMAX",v2,"UPPER VELOCITY LIMIT"
case moment of
    0: begin
        sxaddpar, Hnew, "MOMENT", 0, "Order of Moment"
        sxaddpar, Hnew, "BUNIT", "K.km/s", "Units"
    end
    1: begin
        sxaddpar, Hnew, "MOMENT", 1, "Order of Moment"
        sxaddpar, Hnew, "BUNIT", "km/s", "Units"
    end        
    2: begin
        sxaddpar, Hnew, "MOMENT", 2, "Order of Moment"
        sxaddpar, Hnew, "BUNIT", "km/s", "Units"
    end
endcase

sxdelpar,Hnew,"CRVAL3" 
sxdelpar,Hnew,"CRPIX3" 
sxdelpar,Hnew,"CDELT3" 
sxdelpar,Hnew,"CTYPE3" 

case moment of 
    0: begin
        T=T*abs(cdelt1)
        return, T
    end
    1: begin
        return, C
    end
    2: begin
        W = sqrt(W)
        return, W
    end
endcase


end

