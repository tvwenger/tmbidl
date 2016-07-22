pro printrfreq,scan_number,help=help
;+
; NAME: PRINTRFREQ
;       
;
;            ========================================
;            Syntax: printRfreq,scan_number,help=help
;            ========================================
;
;   printrfreq  Fetch and print the rest frequencies (in MHz)
;   ----------  for all spectra associated with a scan number
;
;   KEYWORDS: \help gives help on syntax and function 
;
;-
; MODIFICATION HISTORY:
;
; V6.1  tmb 06march2011
;       tmb 20dec2011   added sky freq to output 
; V7.0  tmb 17may2013   added help again and !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'printrfreq' & return & endif
;
clearset
setscan,scan_number
clrstk
select
;
lineID=strarr(!acount)
freq=fltarr(!acount) & fsky=fltarr(!acount) 
for i=0,!acount-1 do begin 
    get,!astack[i]
    lid=strtrim(string(!b[0].line_id),2)
    lineID[i]=lid
    rfreq=!b[0].rest_freq/1.d+6   ; rest frequency in MHz
    freq[i]=rfreq
    sfreq=!b[0].sky_freq/1.d+6
    fsky[i]=sfreq
endfor
;
; now sort this stuff correctly 
;
z=sort(lineID)
lineIDsort=lineID[z]
freqsort=freq[z]
fskysort=fsky[z]
;
scn=!b[0].scan_num
scn=strtrim(string(scn),2)
src=strtrim(string(!b[0].source),2)
label1=src+'   Scan# = '+scn
label2='lineID  Rest Frequency  Sky Frequency'
label3='MHz'
print
print,label1
print,label2
fmt='(a,4x,f9.4,5x,f9.4,1x,a)'
for i=0,!acount-1 do begin 
    case 1 of
         i eq 0: print,lineIDsort[i],freqsort[i],fskysort[i],label3,format=fmt 
           else: print,lineIDsort[i],freqsort[i],fskysort[i],format=fmt 
    endcase
endfor
;
return
end
