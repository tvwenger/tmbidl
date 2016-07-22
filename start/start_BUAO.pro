pro start_BUAO,filename,help=help
;+
; NAME:
;       START_BUA)
;
;            =====================================================
;            Syntax: start_BUAO,fully_qualified_filename,help=help
;            =====================================================
;
;   start_BUAO   INITIALIZES TMBIDL for BUAO data.
;   ----------   Boston University - Arecibo Observatory
;                Galactic HI Survey
;
;               If 'filename' passed, asks for file type. 
;               Attaches accordingly.
;-
; V5.0 September 2007  ??? tmb
; V7.0 10jul2013 tmb - migrating ancient code 
;               
;-
;
on_error,!debug ? 0 : 2
on_ioerror, fault
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'start_BUAO' & return & endif
;
;print
print,'==========================================='
print,'Initializing TMBIDL for BUAO HI Survey data'
print,'==========================================='
;print
;
ftype=99
nparm=n_params()
if filename eq '' then nparm=0
case nparm of
     0: goto,no_file_name_input
  else: goto,process_input_file
endcase
process_input_file:
;
filename=strtrim(filename,2)
print,'Input file is: '+filename
print,'Is file SDFITS (=0), TMBIDL(=1), or NSAVE (=2) ??? '
read,ftype,prompt='File type is: '
case ftype of 
             0:begin ; translate the FITS file. never the case here
               init_data,filename
               end
             1:begin ; attach this tmbidl data file ONLINE
               datafile='ONLINE'
               print,datafile+' file is '+filename
               end
             2:begin ; attach this tmbidl data file as NSAVE
                     ; the key file must exist or you will be sorry
               datafile='NSAVE'
               nsdat=filename 
               len=strlen(nsdat) & len=len-4 &
               nskey=strmid(nsdat,0,len)+'.key'
               msg=datafile+' files are '+nsdat
               msg=msg+' and '+nskey
               end
          else:begin
               print
               print,'ERROR: Invalid file type choice!!'
               print
               goto,process_input_file
               end
endcase
;
no_file_name_input: 
;
!data_points=681  ; BUAO why isn't this 1024?
!nchan=!data_points 
; 
@tmbidl_header     ; define {tmbidl_header} with tweaked header info
; define the {tmbidl_data} structure complete with header and data
;
tmb=create_struct(name='tmbidl_data',tmb,'data',fltarr(!data_points))
;
@GLOBALS
;
package,'BUAO'   ; invoke BUAO HI Survey Analysis Package 
;
!config=-1        ; irrelevant for BUAO data
!recs_per_scan=1  ; ditto
gbt_win           ; initialize the plot window and iconify, perhaps
cgbt_win
;
!jrnl_file='../saves/jrnl_BUAO.log'
jfile=!jrnl_file     ; !vars passed by value not reference
journal,jfile        ; starts a journal file = !journal 
;
; act depending on input file type if any 
;
case ftype of 
             0: make_ONLINE  ; create ONLINE data file from SDSFITS
             1: begin        ; this is tmbidl format 
                attach,datafile,filename
                online
                end
             2: attach,datafile,nsdat,nskey ; tmbidl format to NSAVE
          else: 
endcase
               ;
nson           ; write protect the nsave file
line           ; for spectral line  mode
tp             ; TP mode
;
;
clrstk         ; must clear the STACK because IDL starts arrays at 0
;
online='ONLINE' & offline='OFFLINE' & nsave='NSAVE'
;
nsdat=''
nskey=''
;attach,nsave,nsdat,nskey
;

buaoSurvey='../data/buao/buao_survey.tmbidl'
attach,online,buaoSurvey
online
;
files
;
velo
;
fault:  begin
        print,!err_string
        return
        end
;
return
end
