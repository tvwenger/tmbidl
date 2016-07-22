;+
;   bscan.pro   takes input l_gal and automatically shows the 
;   ---------   entire set of GRS b_gal spectra
;               each spectrum has the GRS beam  convolved with
;               adjacent data
;             
;               Syntax:  getlb,l_gal,b_gal,found,imap,offset
;                         
;                        with (l,b) in degrees
;-
pro bscan,l_gal,offset
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
fmt0='("(l,b)=(",f7.4,",",f7.4,"): Position is not in GRS database!")'
;
if N_params() eq 0 then begin
    print,'bscan.pro'
    print,'Shows GRS b_gal data at fixed l_gal'
    print,''
    print,'*******************************************************************'
    print,'SYNTAX:  `bscan,l_gal,offset'
    print
    print,'          input l_gal in degrees'
    print
    print,'                   offset -- angular difference in degrees between '
    print,'                             input (l_gal,b_gal) and position in GRS'
    print,'*******************************************************************'
    return
endif
;
b_gal=0.  ; first find the right datacube
findGRS,l_gal,b_gal,found,imap
;
fname=!grsIDLfiles[imap]
;
; is this TMB-IDL cube already loaded? If not, then load as ONLINE file
if fname ne !currentGRSfile then begin  ; faster not to go through 'attach'
                                 !online_data=fname
                                 !kon=!grsSize[2,imap] ; #recs in file
                                 close,!onunit
                                 openu,!onunit,!online_data
                                 print
                                 print,'ONLINE data file is ' + !online_data
                                 print
;                                 attach,'ONLINE',fname
                                 !currentGRSfile=fname
                                 end
;
bmin=!grsMaps[5,imap] & bmax=!grsMaps[4,imap] & ; get b_gal range
;
;     get terminal velocity
vt,l_gal,vt_dpc,vt_wbb
;
for b_gal=bmin,bmax,!grsSpacing do begin  
                                   Beamlb,l_gal,b_gal,found,offset
                                   !b[0].data=!b[0].data/0.48
                                   xx
                                   flag,vt_dpc,!magenta
                                   flag,vt_wbb,!green
                                   if !zline then zline
                                   wait,.5                   
endfor
;
return
end
