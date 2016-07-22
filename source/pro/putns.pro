pro putns,ns,erase=erase,help=help
;+
; NAME:
;      PUTNS
;
;            =====================================
;            Syntax: putns, nsave_slot_#,help=help
;            =====================================
;
;   putns  Save buffer 0 to NSAVE region specified by 'ns' argument.
;   -----  If ns not given then ns=!nsave, else !nsave=ns.
;          Save to !nsavefile and update !nsave_log in !nslogfile.
;          !nsave_log[] array flags which slots already have data 
;          !nsave_log(!nsave)=1 if !nsave already has data 
;          if ((!protectns eq 1) and (!nsave_log(!nsave) eq 1)) 
;             then do NOT overwrite this saved data 
;
;          ==> NSON/NSOFF toggle write protection
;          ==> FLAGON/FLAGOFF toggle extra output
;
;          ==> N.B. Beware! SAVE is an IDL command! Do not use it!
;
;          ==> N.B. Beware! IF Boolean ERASE keyword is set then
;              nsave slot will be erased irrespective of NSON
;-
; V5.0 July 2007
; V5.1 Feb  2008 tmb to give ablity to erase an NSAVE entry
; June 08 fixed small bug in how !nsave_log was being set. LDA.
;
; March 09 RTR modified to change scan_num to NSAVE bin and
;                                 last_on to previous scan number
; 06/09    RTR fixed so that the size of !NSLOGFILE is preserved
;          old version increased the size to the maximum allowed
;
; V6.0 June 2009 
; V6.1 29jan2010 tmb DUH!  Added code that copies the contents of the 
;      NS# about to be written into buffer !b[15] so one can recover
;      these data if the write was erroneous
; N.B.: This is ONLY done IF the NSAVE slot in question has previously
;       written data in it....
; V7.0 03may2013 tvw - added /help, !debug
;-
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'putns' & return & endif
;
if n_params() eq 0 then begin
                   ns=!nsave
                   erase=0
endif
if n_params() ne 1 then erase=0
;
!nsave=ns
;
; IF NS has data already in it then save it into !b[15]
if !nsave_log[!nsave] eq 1 then begin 
   copy,0,14 & getns,ns & copy,0,15 & copy,14,0 
endif
;
openu,!nsunit,!nsavefile       ;  associate nsave with the nsave.dat file 
nsave = assoc(!nsunit,!rec)    ;  !rec is one {gbt_data} structure for the pattern
;
openr,!nslogunit,!nslogfile    ;  fetch latest version of !nsave_log
nslog=intarr(!nsave_max)
readu,!nslogunit,nslog
!nsave_log[0:!nsave_max-1]=nslog
close,!nslogunit
;
if ( (!protectns eq 1) and (!nsave_log[!nsave] ne 0) ) then begin
   print,'PROTECTED against overwriting data at NSAVE= '+fstring(!nsave,'(i4)')
   close,!nsunit
   return
   endif
;
;  change from LCP/RCP to LL/RR
;  code below makes us backwards compatible for versions 3.0 and
;  earlier 
;
pol=string(!b[0].pol_id)
pol=strtrim(pol,2)
case 1 of
          strmatch(pol,'LCP'):!b[0].pol_id=byte('LL')
          strmatch(pol,'RCP'):!b[0].pol_id=byte('RR')
                         else: ; pass string unchanged
endcase
;
!rec=!b[0]
!rec.scan_num=!nsave                   ;rtr change
!rec.last_on=!b[0].scan_num            ;rtr change    
;
nsave[!nsave]=!rec     ; copy buffer 0 to nsave = !nsave
print,'Wrote to NSAVE= ',!nsave
if (!nsave_log[!nsave] ne 0) then $
               print,'Overwritting data at NSAVE= '+fstring(!nsave,'(i4)')
;
!nsave_log[!nsave]=1                ; flag that this NSAVE has data in it
if Keyword_Set(erase) then !nsave_log[!nsave]=0  ; if /erase then wipe this nsave
;
close,!nsunit
openw,!nslogunit,!nslogfile     ; update !nsave_log file after this write
nslog=!nsave_log[0:!nsave_max-1]  ;rtr change
writeu,!nslogunit,nslog           ;rtr change
close,!nslogunit
;                        
return
end
