pro cat,start,stop,help=help
;+
; NAME:
;      CAT
;
;   ================================
;   SYNTAX: cat,start,stop,help=help
;   ================================
;
;   cat   Lists information about contents of STACK 
;   ----  (think: CATalog)
;
;   KEYWORDS:  /help - gives this help 
;-  
; V5.0 July 2007
; V5.1 Feb  2008 tmb fixed format of header for larger source name
;      Mar  2008 tmb added capability of displaying only part of
;                    the STACK
;      15aug08 tmb added filter to make proper choice
;                  between CAT and CATNS command using !select value
;                  !select=0 => CAT !select=1 => CATNS
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'cat' & return & endif
;
if !acount eq 0 then begin & print,'STACK is empty' & return & endif & 
;
npar=n_params()
if npar eq 0 then begin
             start=0 & stop=!acount-1 & ; defaults to do all
                  end
;
if npar eq 1 then stop=start
;
if (stop lt start) then begin
                       print,'Syntax: cat,start,stop'
                       print,'second argument must be = or > than the first'
                       return
                       end
;
if stop gt !acount-1 then stop=!acount-1
;  is CAT really the command you want?
if !select eq 1 then begin & catns,start,stop & return & endif
;
hdr=' Rec#   Source             R.A.         Dec.   Vel  Rx   Type Pol  Scan# '
hdr=hdr+' Tsys  t_intg'
;
print
print,hdr 
print
;
for i=start,stop do begin 
    if !astack[i] gt !recmax then begin 
                     print,'Invalid record number in STACK'
                     return & endif &
    rec_info,!astack[i]
endfor
;
return
end
