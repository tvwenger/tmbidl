;+
; NAME:
;       B_SUM
;
;   b_SUM   Takes input l_gal and calculates the GRS spectrum 
;   -----   summed over all latitudes.  Convolves each spectrum
;           with the GRS beam.  Returns average in !b[0].data
;           Skips past no data pixels.
;             
;    Syntax: b_sum,l_gal
;    ===================                        
;                  l_gal in degrees
;
; V5.0 August 2007
;
;-
pro b_sum,l_gal
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
if N_params() eq 0 then begin
    print,'b_sum.pro'
    print,'Calculates latitude averaged GRS spectrum at fixed l_gal'
    print,''
    print,'*******************************************************************'
    print,'SYNTAX:   b_sum,l_gal'
    print
    print,'          input l_gal in degrees'
    print
    print,'*******************************************************************'
    return
endif
;
b_gal=0.  ; first find the right datacube
findGRS,l_gal,b_gal,found,imap
;
beam_state=!grsBeam & !grsBeam=1 & ; flag to stop 'getlb' from looking for datacube 
deja_vu_state=!deja_vu & !deja_vu=0 & ; suppress AVE messages
;
fname=!grsIDLfiles[imap]
;
; is this TMB-IDL cube already loaded? If not, then load as ONLINE file
if fname ne !currentGRSfile then begin  ; faster not to go through 'attach'
         !online_data=fname
         !kon=!grsSize[2,imap] ; #recs in file
         close,!onunit
         openr,!onunit,!online_data
         print
         print,'ONLINE data file is ' + !online_data
         print
         !currentGRSfile=fname
         end
;
bmin=!grsMaps[5,imap] 
bmax=!grsMaps[4,imap]  ; get b_gal range
nlat=!grsSize[1,imap]
;
;for b_gal=bmin,bmax,!grsSpacing do begin  
ave   ; zero accum 
;
for i=0,nlat-1 do begin
      b_gal=bmin+!grsSpacing*i
;      if abs(b_gal) gt 0.125 then goto,skip
      Beamlb,l_gal,b_gal,found,imap,offset
      if !b[0].procseqn eq 0 then accum    ; GRS flag for valid data 
skip:
endfor
;
kount=!aaccum
copy,3,0
;
!b[0].scan_type=''                 
!b[0].scan_type=byte('B SUM')
!b[0].b_gal=0.
!b[0].tintg=60.*kount
;
!grsBeam=beam_state 
!deja_vu=deja_vu_state
;
return
end
