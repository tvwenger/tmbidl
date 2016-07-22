pro makesrclist,sourcelist=sourcelist,noinfo=noinfo, $
                start=start, stop=stop, nsave=nsave, help=help
;+
;   NAME: MAKESRCLIST
;
;   makesrclist  Loop through the online/offline/nsave file and 
;   -----------  generate a unique list of source namess.
;   
;   ===============================================================
;   SYNTAX: makesrclist,sourcelist=sourcelist,noinfo=noinfo, $
;                       start=start,stop=stop,nsave=nsave,help=help
;   ===============================================================
;
;   OUTPUT: keyword 'sourcelist' contains byte array of source names.
;
;   OPTIONAL KEYWORDS:
;     -help:       gives this help
;     -noinfo:     supresses print
;     -start:      starting index
;     -stop:       stopping index
;     -nsave:      nsave=1 to use nsave records
;
;-
;MODIFICATION HISTORY:
;    16 July 2008 - Dana S. Balser
;    27 Jan 2009 - (dsb) add list with quotes to use as input
; v8.0 tmb - upgraded to standard format 
;-
;
on_error, !debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'makesrclist' & return & endif
;
; define defaults
if ~KeyWord_Set(nsave) then nsave=0
if (nsave eq 0) then begin
    maxrec = !recmax
endif else begin
    maxrec = !lastns
endelse
if ~KeyWord_Set(start) then start=0
if ~KeyWord_Set(stop)  then stop=maxrec
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
;
if ~KeyWord_Set(noinfo) then begin
    print, 'Number of sources = ', n_elements(srcListSort)
    print, ' '
    print, srcListSort
    print, ' '
    print, srcListSort2
endif
;
sourcelist=srcList
;
return
end
