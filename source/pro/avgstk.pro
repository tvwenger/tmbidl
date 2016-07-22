pro avgstk,arg,help=help
;+
; NAME: 
;       AVGSTK
;
;   avgstk.pro   ACCUM and AVE the records in the STACK
;   ----------
;                'arg' controls averaging process:
;                 = 0 or none => ACCUM and AVE all records in STACK
;                 = 1         => ACCUM and AVE STACK records with editing
;                                displays each record which can be 
;                                discarded or edited for RFI
;                 = 2         => ACCUM and AVE all NSAVE locations in STACK   
;                 = else      => Displays MENU of options                   
;
;                 Sytax: avgstk,arg,help=help
;                 ---------------------------                               
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'avgstk' & return & endif
;
; DO NOT PUT A 'SHOW' IN THIS PROCEDURE!
; IF YOU WANT A SHOW IN 'AVGNS' MODIFY PROC 
; AND PUT IT IN YOUR TEST DIRECTORY AND RECOMPILE 'AVGNS'
; FROM THERE
;
if n_params() eq 0 then arg=0
;
retry:
case arg of 
            0: begin
               for i=0,!acount-1 do begin 
;                                    fetch,abs(!astack[i]) 
                                    acquire,abs(!astack[i])
                                    accum 
               endfor 
               ave 
               show 
               end
            1: bam            ; ACCUM and AVE records in STACK with editing
            2: avgns          ; ACCUM and AVE all NSAVE locations in STACK 
;          'm': begin
;               arg=33
;               goto,retry
;               end
         else: begin
               print,'Syntax: avgstk,arg where options are -> '
               print,'   arg= 0 or none => ACCUM and AVE all records in STACK'
               print,'        1         => ACCUM and AVE STACK records with editing'
               print,'                     displays each record which can be ACCUMed,'
               print,'                     discarded, or edited for RFI and ACCUMed'
               print,'        2         => ACCUM and AVE all NSAVE locations in STACK'
               print,'        anything else gives this MENU'     
               return
               end
endcase
;
;
return
end
