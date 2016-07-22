;
pro test
;+
; NAME:
;       test
;
; PURPOSE: 
;       test: GRS_spectrum.pro
;
; CALLING SEQUENCE:
;       TEST
;
; INPUTS:
;       parameter_value
;
; KEYWORD PARAMETERS:
;       None.
;
; OUTPUTS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS: 
; 
; 
; PROCEDURES CALLED:
;
; EXAMPLES:
;
; NOTES:
;
;
; MODIFICATION HISTORY:
;   16 Sept 2005, T.M. Bania, Boston University, IAR 
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
fmt='(3I4,3x,2f7.4,1x,f8.4,3x,f9.7,3x,f12.7)'
;
common datacube,cube,hdr    ;  current FITS datacube data from !currentGRSfile
;
; gaussian beam weighting function.
c1=0.398942
c2=-1./(2.*!grsSigBeam*!grsSigBeam) &
;
l_gal=22.3 & b_gal=-0.4d &
;
getGRS,l_gal,b_gal,found,offset,lpix,bpix
;
delta_l=-!grsSpacing & delta_b=!grsSpacing &   ; spacing constant but watch signs!
;
lmap0=sxpar(hdr,'CRPIX1') & bmap0=sxpar(hdr,'CRPIX2') & ; map BRC
;
l_grs=(lpix-lmap0)*delta_l & b_grs=(bpix-bmap0)*delta_b & ; GRS position
print,l_grs,b_grs
;
idx=0
sumweight=0.
for i=lpix-1,lpix+1,1 do begin 
   for j=bpix-1,bpix+1,1 do begin 
         l=(i-lmap0)*delta_l & b=(j-bmap0)*delta_b & ; GRS position  
         offset=sqrt( (l-l_grs)^2 + (b-b_grs)^2)
         weight=c1*exp(c2*offset*offset)
         sumweight=weight+sumweight
         print,idx,i,j,l,b,offset,weight,sumweight,format=fmt
   idx=idx+1      
   endfor
endfor
;
return
end 
