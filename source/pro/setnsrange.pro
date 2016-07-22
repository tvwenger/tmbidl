pro setnsrange,nslow,nshigh,help=help
;+
;
;   setnsrange.pro   set the ns range for a SELECTNS search of 
;   ------------   NSAVE file. 
;                  If no input, prompts for !nslow,!nshigh
;
;                  Syntax:  setnsrange,nslow,nshigh,help=help
;-
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
if keyword_set(help) then begin & get_help,'setnsrange' & return & endif
;
;  find the last ns number in the NSAVE file
;
nsmax=!nsave_max
;
if (n_params() eq 0) then begin
                     !nslow=0 & !nshigh=nsmax &
                     print,'Select ns range for searches is: '$
                     +fstring(!nslow,'(i5)')+' to '+fstring(!nshigh,'(i5)')
                     print,'Syntax: setnsrange,low_ns#,high_ns#'
                     return
                     endif
;
if (nshigh gt nsmax) then nshigh=nsmax
if (nslow lt 0) then nslow=0
;
!nslow=nslow & !nshigh=nshigh &
;
print,'Select ns range for searches is: '$
      +fstring(!nslow,'(i5)')+' to '+fstring(!nshigh,'(i5)')
;
return
end

