pro readFitsGBT,file,fdata,table=table,ifPath=ifPath,help=help
;+
;  NAME: readFitsGBT
;
;  readFitsGBT  Read GBT raw fits files and return results.
;  -----------
; 
;  ==================================================================
;  SYNTAX: readFitsGBT,file,fdata,table=table,ifPath=ifPath,help=help
;  ==================================================================
;
;  INPUTS:  
;          file        FITS file to read 
;                      *must* be fully qualified file name
;
;  OUTPUTS:
;          fdata       Fits data (structure)
;
;  KEYWORDS:
;          help        give this help
;          table       table number (default = 1)
;          ifPath      print IF path
;
;-
;MODIFICATION HISTORY:
;    31 July 2009 - Dana S. Balser 
; V7.0 20may2013 tmb integrated to v7.0 
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'readfitsgbt' & return & endif
;
;set defaults
if ~keyword_set(table)  then table=1
if ~keyword_set(ifPath) then ifPath=0
;
; open file and read data
openr, lun, file, /get_lun
fdata = mrdfits(lun, table, hdr, status=status)
close, lun
free_lun,lun
;
; if ifPath is set then parse IF fits file and 
; print the transforms parameter
if ifPath then begin
    b = fdata.backend
    t = fdata.transforms
    for i = 0,n_elements(b)-1 do begin
        foo = strsplit(t[i],';',/extract)
        print, b[i]
        print, ' '
        for j = 0,n_elements(foo)-1 do begin
            print, foo[j]
        endfor
    endfor
endif
;
return
end
