pro setrec,recmin,recmax,help=help
;+
; NAME:
;       SETREC
;
;            ========================================
;            Syntax: setrec, recmin, recmax,help=help
;            ========================================
;
;   setrec   Set the record range for a SELECT search of
;   ------   ONLINE/OFFLINE data file.
;            If no input, prompts for !recmin,!recmax
;
;-
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'setrec' & return & endif
;
if n_params() eq 0 then begin
   !recmin=0 & !recmax=!kount-1 &
   print,'Select record range for searches is: '$
         +fstring(!recmin,'(i5)')+' to '+fstring(!recmax,'(i5)')
   print,'Syntax: setrec,min_rec#,max_rec#'
   return
endif
;
if recmax gt !kount-1 then recmax=!kount
if recmin lt 0 then recmin=0
;
!recmin=recmin & !recmax=recmax &
;
print,'Select record range for searches is: '$
      +fstring(!recmin,'(i5)')+' to '+fstring(!recmax,'(i5)')
;
return
end

