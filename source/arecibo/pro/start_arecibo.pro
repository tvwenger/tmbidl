;+
;NAME:
;
;   start_arecibo,infile   INITIALIZES THIS PACKAGE
;   --------------------   
;                 Attaches 'infile' <- raw Arecibo telescope data file
;
;                 Prompts for infile name if not supplied
;                 Hardwired for the 3-He experiment at Arecibo
;
;                 Syntax: start_arecibo,"fully_qualified_in_file_name"
;                 ----------------------------------------------------
;
; T.M. Bania, July 2005
;-
pro start_arecibo,infile
;
on_error,!debug ? 0 : 2
;
if (n_params() eq 0) then begin
               print,'Input file name= no quotes necessary'
               filein=''
               read,filein,prompt='Set Telescope Data File Name: '
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
@init_files                 ; script to define all files
init_data_bozo,infile       ; <======= *** Telescope raw data file name *****
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
make_bozo_ONLINE            ; create ONLINE data file from {gbt_data} structure 
;
init_NSAVE                  ; do you want to make an NSAVE file?
;
files                       ; show which files are being used 
;
clrstk                      ; must clear the STACK because IDL starts arrays at 0
;
fname=!online_data          ; select ONLINE data file for searches if one exists
if (fname ne '') then online 
;
return
end
