;+
;
;   start_buao,SDFITS_file   INITIALIZES THIS PACKAGE
;   ----------------------   
;                            Creates ONLINE data file from VAX file 
;                            Prompts for VAX file name if not supplied
;
;                           Syntax: start_gbt,"fully_qualified_SDFITS_file_name"
;-
pro start_buao,infile
;
on_error,2
;
if (n_params() eq 0) then begin
               print,'Input file name= no quotes necessary'
               filein=''
               read,filein,prompt='Set SDFITS File Name: '
               infile=strtrim(filein,2)   ; trim blanks fore and aft
               if ( (infile eq "") or (infile eq " ") ) then begin
                                   print,'Invalid Input file name'
                                   return
                                   endif
               find_file,infile ; does this file exist?
endif
;
 
;
;  Define the IDL data reduction system: data structure and global system variables 
;
@buao_files                 ; script to define all files
buao_survey                 ; define BUAO dataset
;
@gbt_data                   ; script to define {gbt_data} data structure
;
@globals                    ; script to define system variables
; 
gbt_win                     ; initialize the plot window and iconify, perhaps
;
jfile=!jrnl_file            ; !vars passed by value not reference
journal,jfile               ; starts a journal file = !journal 
;
attach,1,'/idl/idl/buao/data/buao_survey.gbt' ; ONLINE survey data file 
online
;
init_NSAVE                  ; do you want to make an NSAVE file?
;
files                       ; show which files are being used 
;
clrstk                      ; must clear the STACK because IDL starts arrays at 0
;
velo                        ; x-axis in velocity units
;
print,'============================================='
print,'BUAO_IDL loaded from directory= '+getenv('PWD')
print,'============================================='
;
return
end
