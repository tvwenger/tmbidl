;+
; NAME:
;       PUTAVNS
;
;            =============================
;            Syntax: putavns, nsave_slot_#
;            =============================
;
;   putavns   Save buffer 0 to NSAVE region specified by !nsave 
;   -------   Similar to PUTNS **BUT** changes scan number to NSAVE 
;             slot number and offers option of overide of write protection
;
;                 N.B. SAVE is an IDL command!
;
;             !nsave_log[!nsave] is 1 if the !nsave slot has been written to
;             if ( (!protectns eq 1) and (!nsave_log[!nsave] ne 0) ) then 
;             offers option of override 
;
; MODIFICATION HISTORY:
; rtr fixed bug ma05
; March 09 RTR modified to change scan_num to NSAVE bin and
;                                 last_on to previous scan number
; 06/09    RTR fixed so that the size of !NSLOGFILE is preserved
;          old version increased the size to the maximum allowed
; V5.0 July 2007
;-
pro putavns,ns     ; either input the nsave location explicitly or use !nsave value
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if (n_params() eq 0) then ns=!nsave
;
!nsave=ns
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
   ans='no '
   read,ans,prompt='Do you wish to over ride this protection? (yes or anything else):'
   if (ans ne 'yes') then begin
                     print,'You responded ',ans,': not saving'
                     close,!nsunit
                     return
                     end
   endif
;
!b[0].scan_num=!nsave                  ;rtr change
!rec.last_on=!b[0].scan_num            ;rtr change    
;
;  change from LCP/RCP to LL/RR
;
pol=string(!b[0].pol_id)
pol=strtrim(pol,2)
case 1 of
          strmatch(pol,'LCP'):!b[0].pol_id=byte('LL ')
          strmatch(pol,'RCP'):!b[0].pol_id=byte('RR ')
                         else: ; pass string unchanged
endcase

;
!rec=!b[0]
nsave[!nsave]=!rec     ; copy buffer 0 to nsave = !nsave
print,'Wrote to NSAVE= ',!nsave
if (!nsave_log[!nsave] ne 0) then $
               print,'Overwritting data at NSAVE= '+fstring(!nsave,'(i4)')
;
!nsave_log[!nsave]=1    ;  flag that this NSAVE has data in it
;
close,!nsunit
openw,!nslogunit,!nslogfile     ; update !nsave_log file after this write
nslog=!nsave_log[0:!nsave_max-1]  ;rtr change
writeu,!nslogunit,nslog           ;rtr change
close,!nslogunit
;                        
return
end
