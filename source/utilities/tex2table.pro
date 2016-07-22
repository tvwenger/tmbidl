pro tex2table,fname,help=help,output=output,data=data
;+
; NAME:
;       tex2table
;
;       ===============================================
;       SYNTAX: tex2table,fname,output=output,data=data
;       ===============================================
;
;   tex2table  Converts LaTeX-type table data file
;   ---------  into a read_table.pro type data table
;
;               Note: Can't use anything with spaces in the values!
;                     i.e., 1 & 2 & 3 4 5 & 6 & 7
;                     won't work because 3 4 5 have spaces!
;                 
;   INPUT: fname -- LaTeX type table
;
;   OUTPUT: read_table.pro type data table
;           default is ../../tables/tex2table.txt
;
;   KEYWORDS:
;              HELP - get syntax help
;              OUTPUT - output file name 
;              DATA - get data via read_table
;-
; MODIFICATION HISTORY:
;
; V1.0 TVW 31may2012
; TMBIDL v7.0 17jul2013 tmb - changed names and added to
;                             v7.0/utilities/
;
;
;-
on_error,2        ; on error return to top level
compile_opt idl2  ; compile with long integers 
;
if keyword_set(help) || n_params() eq 0 then begin
   get_help,'tex2table' & return 
endif
;
if ~keyword_set(output) then output="../../tables/tex2table.txt"
openw,lun2,output,/get_lun
;
first=1
;
openr,lun,fname,/get_lun
;
name=" "
read,name,prompt="info for head of table? "
printf,lun2,name
;
while ~eof(lun) do begin
   string=" "
   readf,lun,string
   split=strsplit(string,"&\",/extract)
   nstrs = n_elements(split)-1
   ;
   if first then begin
      print,string
      ;
      titlestr=""
      unitstr=""
      for i=0,nstrs-1 do begin
         print,"What are the headers to go with this info? (Title, units)"
         print,split[i]
         title=" "
         unit=" "
         read,title,prompt="title? "
         read,unit,prompt="units? "
         titlestr += title + " "
         unitstr += unit + " "
      endfor
      printf,lun2,titlestr
      printf,lun2,unitstr
      first=0
   endif
   ;
   printstr=""
   for i=0,nstrs-1 do printstr+=split[i]+" "
   printf,lun2,printstr
endwhile
;
close,lun
close,lun2
;
if keyword_set(data) then read_table,output,data=data
;
return
end
