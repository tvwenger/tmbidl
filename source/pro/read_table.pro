;+
; NAME:
;       READ_TABLE
;
; ========================================================================
; Syntax: read_table,fname,data=data,global=global,help=help,silent=silent
; ========================================================================
;
;   read_table  Generic read of a space delimited table.  Creates a 
;   ----------  structure "data" with tag names defined by the second 
;               line of a 3 line header. 'fname' is mandatory and must 
;               be a fully qualified file name.
;
;               Reads a table in arbitrary format.
;               First three line in table are header information;
;                 Line 1 :  Table Name
;                 Line 2 :  Column labels that become tag names
;                 Line 3 :  Column units. Can be blank.
;               Entries in table must be separated by one or more ' '
;               Automatically defines the data structure and its tags.
;               Tag naming conventions limit format of column labels.
;               Returns table data as structure named by 
;               Keyword data=structure_name 
;               If the Keyword /global is set then also makes system
;               variable global structure named !data[]
;
;   EXAMPLE     data=' '; <== forces data to be a string
;               read_table,fname,data=data  <== returns structure array
;                                               data.[num_rows].(columns)
;
;   KEYWORDS    HELP   - if set gives this help
;               DATA   - MANDATORY: defines the data structure name
;                        structure is local in scope.
;               GLOBAL - if set also defines a global system variable
;                        structure
;               HEADER - if set returns 3 element character array 
;                        containing the 3 header rows 
;               SILENT - if set supresses I/O for batch processing 
;
;   ============================
;   SYNTAX: test_for_string,var
;   ============================
;
;   test_for_string  Function used by read_table to test to see if 
;   ---------------  'var' is a string or not. 
;                    If string then returns 1
;
;
;-
; MODIFICATION HISTORY:
; V6.0 20Aug2009 TMB 
; V6.1 08feb2010 tmb generalized so that now you input the structure
;                     name which is returned as local structure
;                     if /global keyword is set then a global
;                     system variable structure is also defined
;      24feb2010 tmb fix bug wherein lun is left open
;                    this rapidly exhausts the lun's during debugging
;     22sept2010 tmb added help for when things go wrong.
;     20jan 2010 tmb cleanup up code and made use of KeyWord "data"
;                    more lucidly 
;     10feb2011 tmb add help keyword 
; V7.0 03may2013 tvw - added /help, !debug
; v7.1 12jun2014 tmb/tvw - added bad_conversion code whilst parsing 
;                          WISE catalog file.  Brought help documentation
;                          up to v7.1 standard
; v8.0 28may2015 tmb - adds SILENT keyword to supress IO 
;
;-
;
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
;   read_table   read a table in arbitrary format
;   ----------   entries in table must be separated by one or more ' '
;                automatically defines the data structure 
;                tag naming conventions limit format of the table
;                column labels
;                puts data in the Keyword data=structure_name and returns
;                if the Keyword /global is set then also makes system
;                variable global structure named !data[]
;
;
pro read_table,fname,data=data,global=global,help=help,header=header,silent=silent
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help)  then begin & get_help,'read_table' & return & endif
if n_params() eq 0    then begin & print,'ERROR! You MUST supply a data file name !'
                                   get_help,'read_table' & return & endif
if ~keyword_Set(data) then begin & print,'ERROR! You MUST input a name for the data structure !'
                                   get_help,'read_table' & return & endif
;

;
openr,lun,fname,/get_lun
;
a=' '
kount=0
while eof(lun) ne 1 do begin
      readf,lun,a & kount=kount+1
endwhile
;
if ~KeyWord_Set(silent) then begin
    print
    print,'File ',fname,' contains ',kount, ' total records'
    print
endif
close,lun
;
rows=kount-3       ; first three records are headers
;                    rows are the number of data records in this file
openr,lun,fname
;
hdr1=' ' & hdr2=' ' & hdr3=' '    ;  file starts with three line header
                                  ;  
;
readf,lun,hdr1 & readf,lun,hdr2 & readf,lun,hdr3
;
if ~Keyword_Set(silent) then begin
    print,hdr1 & print,hdr2 & print,hdr3 & print
endif
;
header=[[hdr1],[hdr2],[hdr3]]     ;  store in KeyWord for return 
;
;   define the IDL data structure :  get tag_names from hdr2
;                                    get data type from variable 'a'
;                                    which contains the last data record
;
tag_name=strsplit(hdr2,' ',count=tags,/extract)
;
if ~Keyword_Set(silent) then print,'number of columns = ',tags
;
;print,a   ;  if things go awry, look at what exactly is in
;             that last record that you read above
;
xa=strsplit(a,' ',count=cols,/extract)
if tags ne cols then begin
                     print,'not all columns have valid label'
                     return
                     end
;
; initialize the structure
tag=tag_name[0]
var=xa[0]
case test_for_string(var) of
     0: rec=create_struct(tag,0.0d)
     1: rec=create_struct(tag,' ')
endcase
; now do the rest
for k=1,cols-1 do begin
    tag=tag_name[k]
    var=xa[k]
    case (test_for_string(var)) of
         0: rec=create_struct(rec,tag,0.0d)
         1: rec=create_struct(rec,tag,' ')
    endcase
endfor
;
data=replicate(rec,rows)                 ; define the structure 'data'
;
for i=0,rows-1 do begin                  ; fill this structure with table data
;
    readf,lun,a
;    print,a
    xa=strsplit(a,' ',count=cols,/extract) 
                     ; generate array of substrings via ' '
;   print,xa         ;  cols is the number of substrings generated 
                     ;  i.e. number of columns in table
    data[i].(0) = xa[0] ; first entry is string (the '3C385' problem)
                           ; TMB no longer recalls what the above means....
;      data[i].(cols-1) = xa[cols-1] ; string at last entry is problem too...
      for j=1,cols-1 do begin
          var=xa[j]
          on_ioerror,bad_conversion
          case test_for_string(var) of
               0: data[i].(j) = double(var)
               1: data[i].(j) = var
            endcase

      endfor
endfor
;
goto, evil_goto_command_based_skip
bad_conversion: 
begin
print,'Bad conversion of ',data[i].(j),' for '+data[i].(0)
return
end
;
evil_goto_command_based_skip:
; print first and last data records 
;
if ~KeyWord_Set(silent) then begin
    print,data[0]
    print,data[rows-1]
endif 
;
ntags=n_tags(data) & names=tag_names(data) &
for i=0,ntags-1 do begin
      tag_val=data[0].(i)
      result=size(tag_val)
      type=result[1]
      if ~Keyword_Set(silent) then print,names[i],tag_val,type
endfor
;
if Keyword_Set(global) then begin
   defsysv,'!data',data
   if ~KeyWord_Set(silent) then print,'Table data now also in system structure !data'
endif
;
free_lun, lun
;
return
end
