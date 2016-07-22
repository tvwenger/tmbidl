pro catns,start,stop,help=help
;+
; NAME:
;       CATNS
;
;       ==================================
;       SYNTAX: catns,start,stop,help=help (think CATalogNSaves)
;       ==================================
;
;   catns   List contents of STACK  catalog of NSAVE records
;   -----   Uses the AVLOG format.
;           Uses !select to figure out whether data are in NSAVEs   
;-
;
; V5.0 June 2007 tmb changed format 
; V5.1 Feb  2008 tmb fixed format bug
;      Mar  2008 tmb added start,stop parameters
;                    to display only part of the STACK
;      15aug08 tmb added filter to make proper choice
;                  between CAT and CATNS command using !select value
;                  !select=0 => CAT !select=1 => CATNS
;                  !select is set by select.pro 
; V7.0 3may2013 tvw - added /help, !debug
; V7.1 6aug2013 tmb - cleaned up documentation
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
if keyword_set(help) then begin & get_help,'catns' & return & endif
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
                       print,'Syntax: catns,start,stop'
                       print,'second argument must be = or > than the first'
                       return
                       end
;
if stop gt !acount-1 then stop=!acount-1
;  is CATNS really the command you want?
if !select eq 0 then begin & cat,start,stop & return & endif
;
openr,!nslogunit,!nslogfile
nslog=intarr(!nsave_max)
readu,!nslogunit,nslog          ; ! apparently passed by value not reference
!nsave_log[0:!nsave_max-1]=nslog
close,!nslogunit
;
hdr0='STACK'
hdr='  #  NS#   Source      Line  Pol     Type      Tsys  Tintg'
fmt='(i3,1x,i4,1x,a12,1x,a4,2x,a3,1x,a12,f6.1,f7.1)'
;
print
print,'STACK of NSAVEs in '+ !nsavefile + ' contains: '
print
print,hdr0
print,hdr
;
copy,0,8      ;   copy buffer 0 to buffer 8 before you overwrite 0 with the log data
;
for i=start,stop do begin
       nsave=!astack[i] 
       if (!nsave_log[nsave] eq 0) then goto,loop
;
       getns,nsave
       sname=strmid(!b[0].source,0,12)         ; truncate string to 12
       scan=!b[0].scan_num                     ; GBT scan number
       vel=!b[0].vel/1.d+3                     ; source velocity
       rxno=strtrim(string(!b[0].line_id),2)   ; 'receiver' # via line_id 
       pol=strtrim(string(!b[0].pol_id),2)     ; receiver polarization
       styp=string(!b[0].scan_type)            ; fetch scan_type
       tsys=!b[0].tsys                         ; Tsys in Kelvin       
       stintg=!b[0].tintg/60.                  ; integration time in minutes
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
