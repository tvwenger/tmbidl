;
;   test_for_string.pro   test to see if var is a string or not
;   -------------------   if string then return 1
;
function test_for_string,var
;
         on_ioerror,var_is_string
         x=double(var)  ; conversion triggers i/o error if var is string
         goto, var_is_float
         var_is_string:    return,1
         var_is_float:     return,0
end
;
;=============================================================================
;+
; NAME:
;       READ_TABLE
;
;            ========================
;            Syntax: read_table, rows
;            ========================
;
;   read_table   Read a table in arbitrary format.
;   ----------   Entries in table must be separated by one or more ' '
;                Automatically defines the data structure. 
;                Tag naming conventions limit format of the table
;                    column labels
;                Puts data in global system structure array !data[]
;
;   CURRENTLY HARDWIRED FOR HII REGION CATALOG
;
;
; V5.0 July 2007
;-
pro read_table,rows
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
fname='/idl/idl/GRS/hii_cat.dat'
;
openr,lun,fname,/get_lun
;
a=' '
kount=0
while (eof(lun) ne 1) do begin
      readf,lun,a
      kount=kount+1
endwhile
;
;print
;print,'File ',fname,' contains ',kount, ' total records'
;print
close,lun
rows=kount-1    ; first rec is the header
;                    rows are the number of data records in this file
openr,lun,fname
;
hdr1=' ' &  hdr2=' ' & hdr3=' '    ;  file starts with three line header
                                  ;  911 characters per record
readf,lun,hdr1 
;readf,lun,hdr2
;readf,lun,hdr3
;print,hdr1
;print,hdr2
;print,hdr3
;print
;
;   define the IDL data structure :  get tag_names from hdr1
;                                    get data type from variable 'a'
;                                    which contains the last data record
;
tag_name=strsplit(hdr1,' ',count=tags,/extract)
;
;print,'number of columns = ',tags
;
xa=strsplit(a,' ',count=cols,/extract)
if (tags ne cols) then begin
                       print,'not all columns have valid label'
                       return
                       end
;
;sname='hii'
;rec=create_struct(name=sname,'src',xa[0])
;rec=create_struct(name=sname,'index',0) ; structure name is fname
;print,size(rec)
;
for k=0,cols-1 do begin ; append each column to structure sname
    tag=tag_name[k]     ; distinguish between floats and strings
;    print,k,tag
    var=xa[k]
    if k eq 0 then begin
                   rec=create_struct(tag,' ')
                   goto,loop
                   end
    case (test_for_string(var)) of
         0: rec=create_struct(rec,tag,0.0d)
         1: rec=create_struct(rec,tag,' ')
    endcase
loop:
endfor
;
defsysv,'!table', replicate(rec,rows)     ; define global system data structure
;
;print,size(!table)
;
for i=0,rows-1 do begin                  ; fill this structure with table data
;
    readf,lun,a
;    print,a
    xa=strsplit(a,' ',count=cols,/extract)  
                     ; generate array of substrings via ' '
;   print,xa         ;  cols is the number of substrings generated 
                     ;  i.e. number of columns in table
      for j=0,cols-1 do begin
          var=xa[j]
          case (test_for_string(var)) of
               0: !table[i].(j) = double(var)
               1: !table[i].(j) = var
          endcase
      endfor
;print,!table[i].(0),!table[i].(2),!table[i].(3), !table[i].(4)
endfor
;
;print,!table[0]
;print,!table[rows-1]
;
ntags=n_tags(!table) & names=tag_names(!table) &
for i=0,ntags-1 do begin
      tag_val=!table[0].(i)
      result=size(tag_val)
      type=result[1]
      ;print,names[i],tag_val,type
endfor
;
punt:
return
end
