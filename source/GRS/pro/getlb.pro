;+
;   getlb.pro   takes input (l_gal,b_gal) and loads nearest GRS spectrum 
;   ---------   from the appropriate IDL data file which is assumed
;               to be attached to the ONLINE file....
;             
;               Syntax:  getlb,l_gal,b_gal,found,imap,offset
;                         
;                        with (l,b) in degrees
;
;  V6.1 GRS 6 sept 2010  tmb turned found into a keyword
;
;-
pro getlb,l_gal,b_gal,imap,offset,found=found
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
fmt0='("(l,b)=(",f7.4,",",f7.4,"): Position is not in GRS database!")'
;
if N_params() eq 0 then begin
    print,'getlb.pro'
    print,'Finds a single (l,b) spectrum from GRS 13CO (1-0) data cubes.'
    print,''
    print,'*******************************************************************'
    print,'SYNTAX:  `getlb,l_gal,b_gal,imap,offset,found=found'
    print
    print,'          input l_gal,b_gal in degrees'
    print
    print,'          Returns: found -- Boolean:  0 -> position NOT in GRS'
    print,'                                      1 -> position in GRS'
    print,'                   imap  -- string file name for IDL datacube'
    print,'                            centered nearest to (l_gal,b_gal)'
    print,'                   offset -- angular difference in degrees between '
    print,'                             input (l_gal,b_gal) and position in GRS'
    print,'*******************************************************************'
    return
endif
;
; 6 sept 2010 don't know what this line below is here. i screws
;             up searching and fetching positions  tmb
; tmb is stupid.  this prevents looking again and again for the cube
; when one is making a map
if !grsBeam eq 1 then goto,deja_vu
;
findGRS,l_gal,b_gal,found,imap
;
if found eq 0 then begin  ;  Error! position does not exist in GRS 
                   print,l_gal,b_gal,format=fmt0
                   print
                   return
                   end
;
fname=!grsIDLfiles[imap]
;
; is this TMB-IDL cube already loaded? If not, then load as ONLINE file
if fname ne !currentGRSfile then begin  ; faster not to go through 'attach'
                                 !online_data=fname
                                 !kon=!grsSize[2,imap] ; #recs in file
                                 close,!onunit
                                 openr,!onunit,!online_data
;                                 print
;                                 print,'ONLINE data file is ' + !online_data
;                                 print
;                                 attach,'ONLINE',fname
                                 !currentGRSfile=fname
                                 end
;
deja_vu:
;
;fname=!grsIDLfiles[14]
l_map=!grsmaps[3,imap]
b_map=!grsmaps[5,imap]     ; fetch (l,b) of BRC map pixel 
;
nlong=!grsSize[0,imap] & nlat=!grsSize[1,imap] & max_rec=!grsSize[2,imap] &
;
delta_l=-!grsSpacing & delta_b=!grsSpacing &   ; spacing constant but watch signs!
;harwire lmap0,bmap0 for the nonce
;lmap0=4879.0487 & bmap0=179.86179 & ; BRC of map in GRS pixels w.r.t. GC 

;
; convert input (l_gal,b_gal) into cube pixels
;
;lpix=round((l_gal/delta_l)+lmap0)-1L
;bpix=round((b_gal/delta_b)+bmap0)-1L
;
lpix=round((l_gal-l_map)/delta_l)     ;  tmb removed a -1L  here
bpix=round((b_gal-b_map)/delta_b)
;<
rec=bpix+lpix*nlat
!currentGRSrec=rec                    ;  set global GRS record number
;
close,!onunit
openr,!onunit,!online_data
record = assoc(!onunit,!rec)    ; !rec is one {gbt_data} structure for the pattern
;
if ( rec gt !kon-1 ) then begin
   print,'EOF on ONLINE data file'
   close,!onunit
   return
   endif
;
!b[0]=record[rec]  ; copy record = rec into buffer 0
!data_points=!b[0].data_points
;
l_grs=(lpix)*delta_l+l_map & b_grs=(bpix)*delta_b+b_map & ; GRS position
offset=sqrt( (l_gal-l_grs)^2 + (b_gal-b_grs)^2 ) * 3600.  ; arcmin
offset=long(offset)          ; 
!b[0].beamxoff=offset        ; offset in arsec between commanded and GRS (l,b)
;
close,!onunit
;
;print,'Got record= ',rec
;     
;chan
;vgrs
;smo,3
;xx
;     get terminal velocity
;vt,l_gal,vt_dpc,vt_wbb
;flag,vt_dpc,!magenta
;flag,vt_wbb,!green
;                   
close,!onunit
;
return
end
