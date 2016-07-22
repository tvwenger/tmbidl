;+
;   l_vt.pro   takes input l_gal range and finds the terminal 
;   --------   velocity at each longitude.  writes this info to a file.
;               each spectrum has the GRS beam  convolved with
;               adjacent data\\
;
;               Finds the maximum terminal velocity at each l_gal         
;             
;               Syntax:  l_vt
;                         
; V5.0 August 2007
;
;-
pro l_vt
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
;
if N_params() ne 0 then begin
    print,'l_vt.pro'
    print,'Finds maximum Vt for all GRS l-gals'
    print,''
    print,'*******************************************************************'
    print,'SYNTAX:   l_vt'
    print,'*******************************************************************'
    return
endif
;
beam_state=!grsBeam & !grsBeam=1 & ; flag to stop 'getlb' from looking for datacube 
hor=fltarr(!grsNchan)
for i=0L,!grsNchan-1 do hor[i]=(i-!grsCenCh)*!grsDeltaV+!grsVcen
;
filename='/drang/data/VT.data'
openu,lun,filename,/get_lun,/append
;
for l_gal=56.0+2*!grsSpacing,57.0,!grsSpacing do begin
    b_gal=0.  ; first find the right datacube
    findGRS,l_gal,b_gal,found,imap
    fname=!grsIDLfiles[imap]
;   is this TMB-IDL cube already loaded? If not, then load as ONLINE file
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
    bmin=!grsMaps[5,imap] & bmax=!grsMaps[4,imap] & ; get b_gal range
    nlat=!grsSize[1,imap]
;
    bvmap=fltarr(!grsNchan,nlat)
    ver=fltarr(nlat)
    vtb=fltarr(nlat)
;   get terminal velocity
    vt,l_gal,vt_dpc,vt_wbb,vt_nmg
;   print,l_gal,vt_dpc,vt_wbb,vt_nmg,format=fmt
;
    idx=0
;   for b_gal=bmin,bmax,!grsSpacing do begin  
    for i=0,nlat-1 do begin
                   b_gal=bmin+!grsSpacing*i
                   Beamlb,l_gal,b_gal,found,imap,offset
;
                   ver[i]=b_gal
                   bvmap[*,idx]=!b[0].data
                   findVT,vt
                   vtb[i]=vt
                   idx=idx+1L                
                   endfor
;
    vmax=!xx[!data_points-1]
    vmin=0.4*(vt_dpc+vt_wbb)
    index=where(vtb lt vmax and vtb gt vmin)
    if index[0] eq -1 then goto, skip
    valid_lat=ver[index]
    valid_vt =vtb[index]
    vt_max=max(valid_vt)
    chmax=where(valid_vt eq vt_max)
    vt_lat=valid_lat[chmax]
    vt_lat=mean(vt_lat)      ; in case vmax is more than one channel 
;
    print,l_gal,vt_lat,vt_max
    fmt='(f7.4,1x,f7.4,1x,f8.4)'
    printf,lun,l_gal,vt_lat,vt_max,format=fmt
;
skip:
endfor
;
close,lun
!grsBeam=beam_state 
;
return
end
