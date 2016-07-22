pro xrfi,xset,help=help
;+  
; NAME:
;       XRFI
;
;            ============================
;            Syntax: xrfi, xset,help=help
;            ============================
;
;   xrfi  Excise RFI from displayed spectrum. 'xset' 
;   ----  determines whether or not to set xrange or keep
;         current.  Default, xset=0, is to set xrange.
;         If xset=anyting but zero keeps current xrange.
;-
; V5.0 July 2007
;      1 July 2011 tmb tweaked to match rtr notes
; V7.0 03may2013 tvw - added /help, !debug
;-   
;
on_error,!debug ? 0 : 2
if keyword_set(help) then begin & get_help,'xrfi' & return & endif
;
if n_params() eq 0 then xset=0
;
cursor=!cursor
!cursor=1         ; force cursor on
;
try_again:
print,'Is RFI simple (s) or complex (c) ?'
pause,ians
case ians of 
            's': begin
                 if xset eq 0 then begin
                                   print,'Set xrange with cursor:'
                                   setx & xx &
                                   endif
                 rfi                 
                 end
            'c': begin
                 if xset eq 0 then begin
                                   print,'Set xrange with cursor:'
                                   setx & xx &
                                   endif
                 print,'Input # NREGIONs for MRSET'
                 nreg=0
                 read,nreg,prompt='Input # nregs: '
                 mrset,nreg
                 print,'Input order of baseline fit: '  
                 read,nreg,prompt='Input baseline nfit: '        
                 nrfi,nreg
                 end
           else: begin
                 print,'Not trying RFI excision'
                 end 
endcase
;
!cursor=cursor     ; return cursor to entry state
;
return
end
