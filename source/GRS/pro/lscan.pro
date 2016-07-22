;+
;   lscan.pro   takes input l_gal and displays spectra over l_range
;   ---------   at constant b_gal. each spectrum has the GRS beam  
;               convolved with adjacent data
;             
;               Syntax:  lscan,l_gal,b_gal,l_range,found,imap,offset
;                         
;                        with (l,b) in degrees
;-
pro lscan,l_gal,b_gal,l_range,offset
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
fmt0='("(l,b)=(",f7.4,",",f7.4,"): Position is not in GRS database!")'
;
if N_params() eq 0 then begin
    print,'lscan.pro'
    print,'Shows GRS l_gal data at fixed b_gal over l_range'
    print,''
    print,'*******************************************************************'
    print,'SYNTAX:  `lscan,l_gal,b_gal,l_range,offset'
    print
    print,'          input l_gal,b_gal,l_range in degrees'
    print
    print,'                   offset -- angular difference in degrees between '
    print,'                             input (l_gal,b_gal) and position in GRS'
    print,'*******************************************************************'
    return
endif
;
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
lmin=l_gal &  lmax=l_gal+l_range &
;
;
for l_gal=lmin,lmax,!grsSpacing do begin  
                                   Beamlb,l_gal,b_gal
                                   xx
;                                  get terminal velocity
                                   vt,l_gal,vt_dpc,vt_wbb
                                   flag,vt_dpc,!magenta
                                   flag,vt_wbb,!green
                                   wait,.5                   
endfor
;
return
end
