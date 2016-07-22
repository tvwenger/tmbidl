pro nscat,start,stop,stk=stk,help=help
;+
; NAME:
;       NSCAT
;
;   nscat   List contents of NSAVEs. /stk choses STACK records
;   -----   Otherwise lists NSAVE.
;           Uses the AVLOG format. (think CATalogNSaves)
;
;   ====================================================
;   SYNTAX: nscat,start_rec#,stop_rec#,stk=stk,help=help
;   ====================================================
;
;   KEYWORDS:  /help  gives this help
;              /stk   if set uses STACK else NSAVE file 
;
;-
; rtrsb  Sept 2009 variant of old catns command 
;        removes the !select option
;        adds keyword /stk; if stk uses the stack if not stk uses
;                           nsave file
; V5.0 June 2007 tmb changed format 
; V5.1 Feb  2008 tmb fixed format bug
;      Mar  2008 tmb added start,stop parameters
;                    to display only part of the STACK
;
; V7.0 15may2013 tmb added help and !debug and cleaned 
;                    documentation
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2  ; compile with long integers 
;
if keyword_set(help) then begin & get_help,'nscat' & return & endif
;
npar=n_params()
if keyword_set(stk) then begin
    print,'Catalog of NSAVES in the stack'
    if !acount eq 0 then begin 
       print,'STACK is empty'
       return
    endif  
;
    usestk=1    
    if npar eq 0 then begin
        start=0 
        stop=!acount-1         ; defaults to do all
    endif
;
    if npar eq 1 then stop=start
;
    if (stop lt start) then begin
        print,'Syntax: nscat,start,stop,/stk'
        print,'second argument must be = or > than the first'
        return
    endif
;
    if stop gt !acount-1 then stop=!acount-1
endif else begin
    print,'Cataloging NSAVE file'
    usestk=0
    if npar eq 0 then begin
        start=1 
        stop=!nsave_max        ; defaults to do all
    endif
;
    if npar eq 1 then stop=start
;
    if (stop lt start) then begin
        print,'Syntax: nscat,start,stop'
        print,'second argument must be = or > than the first'
        return
    endif
endelse
;
openr,!nslogunit,!nslogfile
nslog=intarr(!nsave_max)
readu,!nslogunit,nslog          ; ! apparently passed by value not reference
!nsave_log[0:!nsave_max-1]=nslog
close,!nslogunit
;
hdr='  #  NS#   Source          Line  Pol     Type      Tsys  Tintg'
fmt='(i4,1x,i4,1x,a16,1x,a4,2x,a3,1x,a12,f6.1,f7.1)'
;
print
print,hdr
;
copy,0,8      ;   copy buffer 0 to buffer 8 before you overwrite 0 with the log data
;
for i=start,stop do begin
       nsave=i
       if usestk gt 0 then nsave=!astack[i] 
       if (!nsave_log[nsave] eq 0) then goto,loop
;
       getns,nsave
       sname=strmid(!b[0].source,0,16)         ; truncate string to 16
       scan=!b[0].scan_num                     ; GBT scan number
       vel=!b[0].vel/1.d+3                     ; source velocity
       rxno=strtrim(string(!b[0].line_id),2)   ; 'receiver' # via line_id 
       pol=strtrim(string(!b[0].pol_id),2)     ; receiver polarization
       styp=string(!b[0].scan_type)            ; fetch scan_type
       tsys=!b[0].tsys                         ; Tsys in Kelvin       
       stintg=!b[0].tintg/3600.                  ; integration time in hours
;
       print,i,nsave,sname,rxno,pol,styp,tsys,stintg, FORMAT=fmt
;
loop:
;
   endfor
;
copy,8,0       ;  replace buffer 0 data 
;
return
end
