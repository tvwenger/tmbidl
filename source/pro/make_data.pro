pro make_data,infile,outfile,help=help
;+
; NAME:
;       MAKE_DATA
;
;            ==========================================================
;            Syntax: make_data, SDFITS_infile, TMBIDL_outfile,help=help
;            ==========================================================
;
;
;   make_data   Create spectral line data file using the {tmbidl_data_v5.0} format.
;   ---------   
;               INPUT data is from SDFITS filled data file. 
;               !kon  counts number of data records currently in file
;               OUTPUT data is {tmbidl_data_v5.0} format to specified file
;               TMBIDL_outfile which must then be attached via ATTACH
;               command.
;
;               All file names must be fully qualified filenames.
;
;               Note:  Error generated if #spectral channels in INPUT
;                      does not match current {tmbidl_data_v5.0} definition.
;
;-
; MODIFICATION HISTORY:
;       written by TMB April 2004
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;       
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'make_data' & return & endif
;
if n_params() eq 0 then begin
   print,'Input file name= no quotes necessary'
   filein=''
   read,filein,prompt='Set SDFITS File Name: '
   infile=strtrim(filein,2)   ; trim blanks fore and aft
   if infile eq "" or infile eq " " then begin
             print,'Invalid Input file name'
             return
             endif
   find_file,infile
   print,'Output file name= no quotes necessary'
   fileout=''
   read,fileout,prompt='Set Output File Name: '
   outfile=strtrim(fileout,2)
   if outfile eq "" or outfile eq " " then begin
              print,'Invalid Input file name'
              return
              endif
endif
;
; Read the SDFITS data file 
;
openr,lun,infile,/get_lun
;
sdd = mrdfits(lun, 1, hdr, status=status) ; makes SDFITS data structure array
free_lun,lun
;
kount=long(n_elements(sdd))  & !kount=kount &  ;  set # records
print
print,'Scanning SDFITS data file ==> ' + infile
print,infile + ' Contains ' + fstring(kount,'(i5)') + ' records '
print
;
nchan=n_elements(sdd[0].data)
if nchan ne !data_points then begin
   print,'ABEND: '+'SDFITS spectra have '+nchan+' channels '
   print,'Current IDL session requires'+!data_points+' channels'
   return
endif
;
;  create the OUTPUT data file from an existing SDFITS file 
;
get_lun,lun
openw,lun,outfile 
;
out={tmbidl_data}               ;  convert SDFITS format to GBT format
;
iflag=!flag
if (!flag) then flagoff         ;  supress excessive i/o 
;
for i=0,(kount-1) do begin
    in=sdd[i]
    sd_to_gbt,in,out
    line_id=out.line_id         ; set line_id using subcorrelator band flag
    rxidrec,line_id
    out.line_id=line_id 
    writeu,lun,out
endfor
;
;
print
print,'Used SDFITS file '+infile
print,'Made {tmbidl_data} data file '+outfile+' with '+$
      fstring(kount,'(i5)')+' records'
print
; 
close,lun
!flag=iflag                      ; restore !flag to entry state
;
return
end







