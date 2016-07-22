pro editstk,src=src,bad=bad,help=help
;+
; NAME:
;       EDITSTK 
;
;        =========================================
;        SYNTAX: editstk,src=src,bad=bad,help=help
;        =========================================
;
;   editstk  Edit the contents of the STACK.
;   -------  Thus refines results of general SELECTs.
;            Makes EPAVs easier for sources with 
;            multiple tunings or other errors.  
;
;   KEYWORDS: 
;      help - gives this help
;      src  - list of source names that need editing 
;      bad  - list of records to delete from STACK 
;             IDs the record by 'typ':
;             typ=strmid(string(!b[0].scan_type),0,3)
;
;  ==> If no 'src' and 'bad' then hard wired for HRDS
;      and 'bad' referes to daily averages
;
;   EXAMPLE: editstk,src=['S209','3C84'],bad=['S02','S01']
;   ------------------------------------------------------
;
;-
; MODIFICATION HISTORY:
; V6.1 02 Apr 2011 tmb 
;      19 Apr 2011 tmb  added 3C84 and fixed 'where' bug
;
; V7.0 28may2013 tmb generalized code !debug help 
;      18jul2013 tmb rewrote to eliminat goto's
;                    improved documentation 
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'editstk' & return & endif
;
if ~keyword_set(src) then src=['S209','3C84'] 
;   list of sources that need editing  

if ~keyword_set(bad) then bad=['S02','S01']  
;  STACK records to delte e.g. 
;  daily averages to expunge from STACK
;  S209 S2 and 3C84 S1 have different tunings
;  must expunge from the average
;
nedits=n_elements(src)
for n=0,nedits-1 do begin
if !src eq src[n] then begin ; only do this if source name matches
        npts=n_elements(!astack[0:!acount-1])
        stk=intarr(npts)
        kount=0
        for i=0,!acount-1 do begin 
            getns,!astack[i]
            typ=string(!b[0].scan_type)
            typ=strmid(typ,0,3)
            if typ eq bad[n] then begin
               stk[kount]=!astack[i]
               kount=kount+1
            endif
        endfor
; now subtract the bad records from the STACK
;
        idx=where(stk ne 0, count)
        if count ne 0 then begin
        recs=stk[idx]
        for i=0,n_elements(recs)-1 do begin
            sub,recs[i]
        endfor
     endif
endif  ; source match loop
;
endfor ; n loop 
;
flush:
return
end
