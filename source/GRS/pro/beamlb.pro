;
pro Beamlb,l_gal,b_gal,found,imap,offset
;+
; NAME:
;       Beamlb
;
; PURPOSE: Fetch an input (l,b) galactic position from the GRS
;          IDL database and convolve adjoing voxels with the FCRAO
;          beam.  Do this silently and leave result in !b[0].data.
;          THIS IS THUS SUITABLE FOR BATCH PROCESSING. 
;
; CALLING SEQUENCE:
;       Beamlb,l_gal,b_gal
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
;   10 June 2006, written by T.M. Bania
;   14 August 2007, modified for TMBIDL v5.0
;
; v6.1 TMB changed found to keyword
; 1feb2011 tmb fixed subtle bug preventing Gaussian errors to be had
;              turned out to be the 'BEAM' label.  the 'B' made 
;              pro mask think the data were backwards continuum
;              scans. !!!
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
;
fmt0='(i3,2(f8.4),1x,f5.1,f8.5,f9.5,i3)'
;
;
!b[0]={tmbidl_data}      ; initialize the TMB-IDL structure
;
if N_params() eq 0 then begin
    print,'Beamlb.pro'
    print,'Finds a single (l,b) spectrum from GRS 13CO (1-0) IDL data cubes.'
    print,'Convolves the FCRAO beam atop the GRS dataset centered here'
    print,'*******************************************************************'
    print,'SYNTAX:  Beamlb,l_gal,b_gal,found,offset'
    print
    print,'          input l_gal,b_gal in degrees'
    print
    print,'          Returns: found -- Boolean:  0 -> position NOT in GRS
    print,'                                      1 -> position in GRS'
    print,'                   offset -- angular difference in degrees between '
    print,'                             input (l_gal,b_gal) and position in GRS'
    print,'*******************************************************************'
    return
endif
;
;  First get center GRS spectrum 
;
getlb,l_gal,b_gal,found=found,imap,offset
;
center_offset=!b[0].beamxoff
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
;print,l_gal,b_gal,found,offset
;print,lpix,bpix,rec0
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
;            only process if spectrum has valid data
             if !b[0].procseqn eq 0 then begin
                weight=!grsWeight[idx]
                spectrum=spectrum+weight*!b[0].data
;
                l=!b[0].l_gal                  ; from grs2idl =l_grs
                b=!b[0].b_gal                  ;              =b_grs
                offset=sqrt((l-l_gal)^2+(b-b_gal)^2)*3600.            
                !b[0].beamxoff=offset
;
                sumweight=weight+sumweight
                nspec=nspec+1
;             print,idx,l,b,offset,weight,sumweight,nspec,format=fmt0
            end
;
    idx=idx+1
endfor
;
get,rec0  ; stuff !b[0] header with central pixel values
; 
; change header for beam averaged spectrum
;
tagtype,'CONVOLVED'     ;  annotate spectrum as average over GRS beam
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
!b[0].beamxoff=center_offset
;
;reshow
;
return
end 
