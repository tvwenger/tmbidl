;+
; NAME:
;       getgrsBeam
;
; PURPOSE: Fetch an input (l,b) galactic position from the GRS
;          IDL database and convolve adjoing voxels with the FCRAO beam
;
; CALLING SEQUENCE:
;       getgrsBeam,l_gal,b_gal
;
; INPUTS:
;       l_gal and b_gal in degrees.
;
; KEYWORD PARAMETERS:
;       None.
;
; OUTPUTS:  GRS spectrum which is weighted average of FCRAO beam atop
;           GRS data
;
; MODIFICATION HISTORY:
;   31 May 2006, written by T.M. Bania
;   8 June 2006, TMB modified from FITS to IDL database
;
; v6.1 26 oct 2010 TMB fixed structure defining bug.
;                      turned found into keyword 
;                      added overlay keyword
;
;-
pro getgrsBeam,l_gal,b_gal,offset,found=found,overlay=overlay
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
;
fmt0='(i3,2(f8.4),1x,f5.1,f8.5,f9.5,i3)'
;
;
!b[0]=!rec      ; initialize the TMB-IDL structure
;
if N_params() eq 0 then begin
    print,'getgrsBeam.pro'
    print,'Finds a single (l,b) spectrum from GRS 13CO (1-0) IDL data cubes.'
    print,'Convolves the FCRAO beam atop the GRS dataset centered here'
    print,'********************************************************************'
    print,'SYNTAX:  getgrsBeam,l_gal,b_gal,offset,found=found,overlay=overlay'
    print
    print,'          input l_gal,b_gal in degrees'
    print
    print,'          Returns: found -- Boolean:  0 -> position NOT in GRS'
    print,'                                      1 -> position in GRS'
    print,'                   offset -- angular difference in degrees between '
    print,'                             input (l_gal,b_gal) and position in GRS'
    print,'********************************************************************'
    return
endif
;
;  First get center GRS spectrum 
;
getlb,l_gal,b_gal,imap,offset,found=found
;
center_offset=!b[0].beamxoff
;
;!grsBeam=1 ; force getGRS to stay in the same cube
;
if KeyWord_set(overlay) then xx
;
nlong=!grsSize[0,imap]
nlat =!grsSize[1,imap]
num_recs=!grsSize[2,imap]
nchan=!b[0].data_points
;
delta_l=-!grsSpacing & delta_b=!grsSpacing &   ; spacing constant but watch signs!
lpix=!b[0].hor_offset-1L           ; from grs2idl =lidx+1
bpix=!b[0].ver_offset-1L           ;              =bidx+1
rec0=bpix+lpix*nlat
;
if !verbose then begin
   print,l_gal,b_gal,found,offset
   print,lpix,bpix,rec0
endif
;
!grsSpect[0:!grsNchan-1]=0. ; initialize GRS spectrum - default is 659 channels
nspec=0.     ; number of spectra:  i.e. flags gaussian beam average, etc. 
;
idx=0
sumweight=0.
spectrum=!grsSpect
;
for i=1,9 do begin
      case 1 of 
               i eq 1:rec=rec0-nlat-1
               i eq 2:rec=rec0-nlat
               i eq 3:rec=rec0-nlat+1
               i eq 4:rec=rec0-1
               i eq 5:rec=rec0
               i eq 6:rec=rec0+1
               i eq 7:rec=rec0+nlat-1
               i eq 8:rec=rec0+nlat
               i eq 9:rec=rec0+nlat+1
            else:
     endcase
;
        get,rec
        weight=!grsWeight[idx]
        spectrum=spectrum+weight*!b[0].data
;
        l=!b[0].l_gal                  ; from grs2idl =l_grs
        b=!b[0].b_gal                  ;              =b_grs
        offset=sqrt((l-l_gal)^2+(b-b_gal)^2)*3600.            
;
        idx=idx+1
        sumweight=weight+sumweight
        nspec=nspec+1
        if !verbose then print,idx,l,b,offset,weight,sumweight,nspec,format=fmt0
endfor
;
get,rec0  ; stuff !b[0] header with central pixel values
; 
; change header for beam averaged spectrum
;
!b[0].tintg=float(nspec)*60.
;
!grsSpect=spectrum/sumweight ; weighted average
;
!b[0].data=!grsSpect
;
mask,dsig            ; get RMS in nregion:  will need case statement
                     ; here to deal with different nchans
                     ; maybe not.... look at default nrset above...
!b[0].tsys=dsig      ; replace Tsys with RMS in NREGIONs
;print,dsig,' RMS in NREGIONs'
;
if KeyWord_set(overlay) then reshow else xx
;
tagtype,'BEAM'  ; annotate !b[0] to flag this as a convolved beam spectrum
;
;!grsBeam=0     ; return getGRS to normal functioning--look for FTS
;                cube closest in position to input l_gal,b_gal
;
!b[0].beamxoff=center_offset
;
return
end 
