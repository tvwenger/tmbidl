pro get_source,source,ra,dec,epoch,error,help=help
;+
; NAME:
;       get_source
;
;            ======================================================
;            Syntax: get_source,SOURCE,ra,dec,epoch,error,help=help
;            ======================================================
;
;   get_source  Searches the Continuum Source Catalog (CSC) for
;   ----------  input SOURCE name. Returns the CSC source RA/DEC
;               position and epoch.   
;               Default file: ../v7.0/catalogs/source_catalog
;               Only J2000 and B1950 epochs allowed in CSC. 
;               Sets error=1 if source not in CSC.
;
;-
; V5.1 December 2007  
;
; modified 11Dec07 dsb  Add epoch as an output parameter. Comment
;                       precession code which is no longer needed.
;                       Use  get_coords to convert sexigesimal to
;                       decimal coordinates.
;
; V6.0 June 2009
; V7.0 3may2013 tvw - added /help, !debug
;     26jun2013 tmb - improved documentation 
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
on_ioerror,end_of_file
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'get_source' & return & endif
;
catalog=!source_catalog
openr,lun,catalog,/get_lun  
;
a=' '
hdr1=' ' & hdr2=' ' & hdr3=' '  & hdr4=' '  ;  file starts with 3 header lines
readf,lun,hdr1 & readf,lun,hdr2 & readf,lun,hdr3 & 
;
source=strtrim(source,2) 
error=0
catsource='NO MATCH!'
src=' ' & epoch=' ' & ra=0.0d & dec=0.0d
;
while not eof(lun)  do begin
      readf,lun,a
      xa=strsplit(a,' ',count=cols,/extract)
      src=xa[0]  &  src=strtrim(src,2)         
      if source eq src then begin
         catsource=src
         ; get coordinates RA/Dec in degrees
         ; this takes care of the -00 xx yy sign issue
         coordString=xa[1]+' '+xa[2]+' '+xa[3]+' '+xa[4]+' '+xa[5]+' '+xa[6]
         get_coords, coords, InString=coordString
         ra = coords[0]*15.d & dec=coords[1]
         ; get epoch
         epoch=xa[7] &  epoch=strtrim(epoch,2)
;         if epoch eq 'B1950' then begin
;            jprecess,ra,dec,ra_2000,dec_2000
;            ra=ra_2000 & dec=dec_2000 & epoch='J2000'
;        endif
      endif
endwhile
;
end_of_file:
if catsource ne 'NO MATCH!' then goto,egress
error=1 ; source not in CSC
; always print error message if source not in CSC
print,catsource+' '+source+' is not in Continuum Source Catalog '+catalog
goto,out
;
egress:
if not !batch then print,catsource+' '+epoch,ra,dec
;
out:
;
free_lun,lun
return
end



