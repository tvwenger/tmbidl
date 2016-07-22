;
pro beamlook,l_gal,b_gal,found,offset,lpix,bpix
;+
; NAME:
;       beamlook
;
; PURPOSE: Show all GRS spectra within a single FCRAO GRS beam
;          centered at input (l,b) galactic position
;          Find 8 nearest neighbor positions and overplot in 
;                 red for 4 nearest and yellow for other 4 
;
; CALLING SEQUENCE:
;       beamlook,l_gal,b_gal,found,offset
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
;       offset -- angular difference in degrees between input (l_gal,b_gal)
;                 and position in GRS
;
;
; MODIFICATION HISTORY:
;   30 May 2006, written by T.M. Bania
;    8 June 2006, modified for IDL database by TMB
;
;   14 april 2013 tmb getlb's 'found' is now a keyword
;                     reshow's color is now a keyword
;-
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
if N_params() eq 0 then begin
    print,'beamlook.pro'
    print,'Finds a single (l,b) spectrum from GRS 13CO (1-0) IDL data cubes.'
    print
    print,'*******************************************************************'
    print,'SYNTAX:  `beamlook,l_gal,b_gal,found,offset'
    print
    print,'          input l_gal,b_gal in degrees'
    print
    print,'          Returns: found -- Boolean:  0 -> position NOT in GRS'
    print,'                                      1 -> position in GRS'
    print,'                   offset -- angular difference in degrees between '
    print,'                             input (l_gal,b_gal) and position in GRS'
    print,'*******************************************************************'
    return
endif
;
fmt0='(i3,2(f8.4),1x,f5.1,f8.5)'
;
; first get center spectrum
;
;getlb,l_gal,b_gal,found,imap,offset
getlb,l_gal,b_gal,imap,offset,found=found
;
xx
;
nlong=!grsSize[0,imap]
nlat =!grsSize[1,imap]
num_recs=!grsSize[2,imap]
;
delta_l=-!grsSpacing & delta_b=!grsSpacing &   ; spacing constant but watch signs!
lpix=!b[0].hor_offset-1L           ; from grs2idl =lidx+1
bpix=!b[0].ver_offset-1L           ;              =bidx+1
rec0=bpix+lpix*nlat
;
idx=0
;
for i=1,9 do begin
          case 1 of 
                    (i eq 1):begin
                             rec=rec0-nlat-1
                             clr=!yellow
                             end
                    (i eq 2):begin
                             rec=rec0-nlat
                             clr=!red
                             end
                    (i eq 3):begin
                             rec=rec0-nlat+1
                             clr=!yellow
                             end
                    (i eq 4):begin
                             rec=rec0-1
                             clr=!red
                             end
                    (i eq 5):begin
                             rec=rec0
                             clr=!white
                             end
                    (i eq 6):begin
                             rec=rec0+1
                             clr=!red
                             end
                    (i eq 7):begin
                             rec=rec0+nlat-1
                             clr=!yellow
                             end
                    (i eq 8):begin
                             rec=rec0+nlat
                             clr=!red
                             end
                    (i eq 9):begin
                             rec=rec0+nlat+1
                             clr=!yellow
                             end
                        else:print,'you lose: take off your clothes!'
          endcase
;
;
      get,rec
      pause
      reshow,color=clr
;      show
;
       l=!b[0].l_gal                  ; from grs2idl =l_grs
       b=!b[0].b_gal                  ;              =b_grs

       offset=sqrt((l-l_gal)^2+(b-b_gal)^2)*3600.
       print,idx,l,b,offset,!grsWeight[idx],format=fmt0
;       print,i,rec
;
      idx=idx+1
endfor
;
return
end 
