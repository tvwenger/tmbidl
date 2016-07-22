;
pro findGRS,l_gal,b_gal,found,imap,dist
;+
; NAME:
;       findGRS
;
; PURPOSE: Search for the correct survey data file given
;          an input (l,b) galactic position.  Finds FITS cube
;          whose center is closest to requested position.
;
; CALLING SEQUENCE:
;       findGRS,l_gal,b_gal,found,GRS_file_name
;
; INPUTS:
;       l_gal and b_gal in degrees.
;
; KEYWORD PARAMETERS:
;       None.
;
; OUTPUTS:
;       found -- Boolean:  0 -> position NOT in GRS
;                          1 -> position in GRS
;       imap -- index in !grsFiles[] array of GRS file for (l_gal,b_gal)
;      
;       dist -- distance between requested (l,b) and map center in degrees
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
;   18 May 2006, written by T.M. Bania
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
fmt0='("(l,b)=(",f7.4,",",f7.4,"): Position is not in GRS database!")'
fmt1='("(l,b)=(",f7.4,",",f7.4,") is in file ",a)'
;
pad=!grsHPBW/2.
;
found=0
imap=-1
for i=0,!grsNfiles-1 do begin
                 l_cen=!grsMaps[0,i] & b_cen=!grsMaps[1,i] &
                 l_max=!grsMaps[3,i] & l_min=!grsMaps[2,i] &
                 b_max=!grsMaps[4,i] & b_min=!grsMaps[5,i] &
; soften the boundaries by HPBW/2
                 l_max=l_max+pad & b_max=b_max+pad &
                 l_min=l_min-pad & b_min=b_min-pad &
   case 1 of 
          (l_gal ge l_min and l_gal le l_max and b_gal ge b_min and b_gal le b_max): $
                 begin
                 case found of 
                            0: begin
                               imap=i
                               dist=sqrt((l_gal-l_cen)^2+(b_gal-b_cen)^2)
                               print,!grsIDLFiles[i]+' Dist= ',dist*3600.,i
                               end
;                for positions in multiple in multiple data cubes pick
;                cube that has position nearest the center 
                            1: begin
                               dist2=sqrt((l_gal-l_cen)^2+(b_gal-b_cen)^2)
                               print,!grsIDLFiles[i]+' Dist= ',dist2*3600.,i
                               If dist2 lt dist then begin
                                           print,'second cube is closer'
                                           dist=dist2
                                           imap=i
                                       endif
                               end
                          else: 
                 endcase
                 found=1
                 end
           else: ; found no match
   endcase
endfor
;                 print,!grsIDLFiles[imap]+' Dist= ',dist*3600.,imap
;                     ;
if (found eq 0) then begin  ;  Message that position does not exist in GRS 
                     print,l_gal,b_gal,format=fmt0
                     print
                     return
                     end
; position exists in GRS
GRS_file_name=!grsIDLFiles[imap]
;print,l_gal,b_gal,GRS_file_name,format=fmt1
;
return
end 
