pro table2tex,data,help=help,fname=fname,decim=decim
;+
; NAME:
;       table2tex
;
;    ========================================================
;    SYNTAX: table2tex,data,help=help,fname=fname,decim=decim
;    ========================================================
;
;   table2tex  Takes read_table.pro type data structure and 
;   ---------  writes a TeX-type data file for use in LaTeX
;              tables. 
;                 
;   INPUT:  'data' read_table.pro type data structure
;
;   OUTPUT: LaTeX style data file.
;           Default is '../tmbidl/tables/table2tex.tex'
;
;
;   KEYWORDS:
;              HELP  - get syntax help
;              FNAME - name of output LaTeX data file
;                      overwrites data file 
;              DECIM - array of integers giving formatting 
;                      information for each column of output
;                      data. must have 
;                      n_elements(decim)=n_elements(tag_names(data))
;                      if -1 ==> column is string
;                          0 ==> column is integer
;                          n ==> column is float with number 
;                                of decimal places = n
;
;-
; MODIFICATION HISTORY:
;
; V1.0 TVW 20jun2012
;      tvw 28jun2012 - added decim. changed functionality
;      tvw 14may2013 - replace - with $-$ before writing to file
; modified for TMBIDL v7.0 - 18jul2013 tmb changed names 
;
;-
on_error,2        ; on error return to top level
compile_opt idl2  ; compile with long integers 
;
if keyword_set(help) then begin & get_help,'table2tex' & return & endif
;
if n_elements(decim) ne n_elements(tag_names(data)) then begin
   print,"n_elements(decim) must equal n_elements(tag_names(data))"
   return
endif
;
if ~keyword_set(fname) then fname='../../tables/tables2tex.tex'
;
num_entries=n_elements(data)
print,"This data has ",num_entries," elements"
;
openw,lun,fname,/get_lun
;
for i=0,num_entries-1 do begin
   line=""
   for j=0,n_elements(tag_names(data))-1 do begin
      case decim[j] of
         -1: format='(A-0)'
          0: format='(i-0)'
       else: format='(F-0.'+string(decim[j])+')'
    endcase
      if j eq n_elements(tag_names(data))-1 then line+=fstring(data[i].(j),format)+' \\ ' $
                                            else line+=fstring(data[i].(j),format)+' & '
   endfor
   line=repstr(line,'-','$-$')
   printf,lun,line
endfor
;
close,lun
;
return
end
