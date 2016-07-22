;+
;NAME: makeSrcList.pro 
;
;PURPOSE: 
; Loop through the online/offline/nsave file and generate a unique list of sources
;   
;CALLING SEQUENCE: makeSrcList, start=start, stop=stop, nsave=nsave
;
;INPUTS:  
;
;OPTIONAL KEYWORDS:
;     -start:      starting index
;     -stop:       stopping index
;     -nsave:      nsave=1 to use nsave records
;
;OUTPUTS:
;
;EXAMPLE: makeSrcList
;
;MODIFICATION HISTORY:
;    16 July 2008 - Dana S. Balser
;    27 Jan 2009 - (dsb) add list with quotes to use as input
;-

pro makeSrcList, start=start, stop=stop, nsave=nsave

on_error,2
compile_opt idl2

; define defaults
if (n_elements(nsave) eq 0) then nsave=0
if (nsave eq 0) then begin
    maxrec = !recmax
endif else begin
    maxrec = !lastns
endelse
if (n_elements(start) eq 0) then start=0
if (n_elements(stop) eq 0) then stop=maxrec
if stop ge maxrec then stop=maxrec

; sort through the online/offline/nsave file
srcList = ['None']
srcList2 = ['None']
for i=start,stop do begin 
    if (nsave eq 0) then begin
        get,i
    endif else begin
        getns, i
    endelse
    sname=strtrim(!b[0].source,2)
    if (srcList[0] eq 'None') then begin
        srcList[0] = sname
        srcList2[0] = "'" + sname + "'"
    endif else begin
        foo = strmatch(srcList, sname)
        if (max(foo) eq 0) then begin
            srcList = [srcList,  sname]
            srcList2 = [srcList2,  ", '" + sname + "'"]
        endif
    endelse
endfor
; sort the source list
srcListSort = srcList[sort(srcList)]
srcListSort2 = srcList2[sort(srcList2)]

print, 'Number of sources = ', n_elements(srcListSort)
print, ' '
print, srcListSort
print, ' '
print, srcListSort2

return
end
