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
;
;   read_table.pro   read a table in arbitrary format
;   --------------   entries in table must be separated by one or more ' '
;                    automatically defines the data structure 
;                    tag naming conventions limit format of the table
;                    column labels
;                    puts data in global system structure array !data[]
;
pro read_table,fname 
;
on_error,!debug ? 0 : 2
;
if (n_params() eq 0) then  fname='/idl/idl/survey/physparam2.dat'
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
print
print,'File ',fname,' contains ',kount, ' total records'
print
close,lun
;
rows=kount-3       ; first three records are headers
;                    rows are the number of data records in this file
openr,lun,fname
;
;
hdr1=' ' & hdr2=' ' & hdr3=' '    ;  file starts with three line header
                                  ;  911 characters per record
readf,lun,hdr1 
readf,lun,hdr2
readf,lun,hdr3
print,hdr1
print,hdr2
print,hdr3
print
;
;   define the IDL data structure :  get tag_names from hdr1
;                                    get data type from variable 'a'
;                                    which contains the last data record
;
tag_name=strsplit(hdr1,' ',count=tags,/extract)
;
print,'number of columns = ',tags
;
xa=strsplit(a,' ',count=cols,/extract)
if (tags ne cols) then begin
                       print,'not all columns have valid label'
                       return
                       end
rec=create_struct(name=fname,'src',xa[0]) ; create structure fix '3C385' issue
                                          ; structure name is fname
;
print,size(rec)
;
for k=0,cols-1 do begin
    tag=tag_name[k]
    var=xa[k]
    case (test_for_string(var)) of
         0: rec=create_struct(rec,tag,0.0d)
         1: rec=create_struct(rec,tag,' ')
    endcase
endfor
;
defsysv,'!data', replicate(rec,rows)     ; define global system data structure
;
for i=0,rows-1 do begin                  ; fill this structure with table data
;
    readf,lun,a
;    print,a
    xa=strsplit(a,' ',count=cols,/extract)  
                     ; generate array of substrings via ' '
;   print,xa         ;  cols is the number of substrings generated 
                     ;  i.e. number of columns in table
      !data[i].(0) = xa[0] ; first entry is string (the '3C385' problem)
                           ; TMB no longer recalls what the above means....
;      !data[i].(cols-1) = xa[cols-1] ; string at last entry is problem too...
      for j=1,cols-1 do begin
          var=xa[j]
          case (test_for_string(var)) of
               0: !data[i].(j) = double(var)
               1: !data[i].(j) = var
          endcase
      endfor
endfor
;
print,!data[0]
print,!data[rows-1]
;
ntags=n_tags(!data) & names=tag_names(!data) &
for i=0,ntags-1 do begin
      tag_val=!data[0].(i)
      result=size(tag_val)
      type=result[1]
      print,names[i],tag_val,type
endfor
;
return
end
