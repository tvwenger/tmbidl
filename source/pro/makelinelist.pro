pro makelinelist,linelist=linelist,noinfo=noinfo, $
                 start=start,stop=stop,nsave=nsave,help=help
;+
;   NAME: MAKELINELIST
;
;   makelinelist  Loop through the online/offline/nsave file and 
;   ------------  generate a unique list of line ID's.
;   
;   ================================================================
;   SYNTAX: makelinelist,linelist=linelist,noinfo=noinfo, $
;                        start=start,stop=stop,nsave=nsave,help=help
;   ================================================================
;
;   OUTPUT:  KeyWord 'linelist' holds byte array of line ID's
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
; v8.0 11jul2014 tmb/tvw - created for VEGAS based on dsb's
;                          makesrclist.pro 
;-
;
on_error, !debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'makelinelist' & return & endif
;
; define defaults
if ~KeyWord_Set(nsave) then nsave=0
if nsave eq 0 then begin
   maxrec = !recmax
endif else begin

    maxrec = !lastns
endelse
;
if ~KeyWord_Set(start) then start=0
if ~KeyWord_Set(stop)  then stop=maxrec
if stop ge maxrec then stop=maxrec

; sort through the online/offline/nsave file
List =  ['None']
List2 = ['None']
for i=start,stop do begin 
    if nsave eq 0 then begin
        get,i
    endif else begin
        getns, i
    endelse
    lineID=strtrim(!b[0].line_id,2)
    if List[0] eq 'None' then begin
       List[0] = lineID
       List2[0] = "'" + lineID + "'"
    endif else begin
       foo = strmatch(List, lineID)
       if max(foo) eq 0 then begin
          List =  [List,  lineID]
          List2 = [List2,  ", '" + lineID + "'"]
        endif
    endelse
endfor
; sort the source list
ListSort = List[sort(List)]
ListSort2 = List2[sort(List2)]
;
if ~KeyWord_Set(noinfo) then begin
  print
  print, 'Number of Line tunings = ', n_elements(ListSort)
  print, ' '
  print, ListSort
  print, ' '
  print, ListSort2
endif
;
linelist = List
;
return
end
