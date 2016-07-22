pro parse_archive_FITINFO,rec_in,rec_out,help=help
;+
; NAME:
;       PARSE_ARCHIVE_FITINFO
;
; Parse an input archive record structure in FITINFO format 
; into meaningful data.  Returns a named structure 'rec_out'
; that has meaningful tag names and correct variable type.
;
; =========================================================================
; Syntax:
; parse_archive_FITINFO,archive_structure_in,parsed_structure_out,$
;                       help=help
; =======================================================================
;
; V5.0 July 2007
; V7.0 May 2013 tmb/tvw added /help and updated error handling
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'parse_archive_FITINFO' & return & endif
;
rec=rec_in
name='FITINFO'
;
; for write_archive_FITINFO.pro
;
tag_names=['archive_type','nfit','nunit','nrset','nregs','ngauss', $
           'agauss','gsigma']
;
archive_type=rec.(0)
nfit=long(rec.(1))
nunit=rec.(2)
nrset=long(rec.(3))
idx=4
nreg=lonarr(2*nrset)
for i=0,2*nrset-1 do begin & nreg[i]=long(rec.(i+idx)) & end
idx=idx+2*nrset
ngauss=long(rec.(idx))
idx=idx+1
a_gauss=fltarr(3*ngauss)                                       
g_sigma=fltarr(3*ngauss)                                       
for i=0,3*ngauss-1 do begin & a_gauss[i]=float(rec.(i+idx)) & end
idx=idx+3*ngauss
for i=0,3*ngauss-1 do begin & g_sigma[i]=float(rec.(i+idx)) & end
;
tag=tag_names[0]             ; first make the named array
arc=create_struct(name=strname,tag,archive_type)
;
; now fill the structure
;
arc=create_struct(arc,tag_names[1],nfit)
arc=create_struct(arc,tag_names[2],nunit)
arc=create_struct(arc,tag_names[3],nrset)
arc=create_struct(arc,tag_names[4],nreg)
arc=create_struct(arc,tag_names[5],ngauss)
arc=create_struct(arc,tag_names[6],a_gauss)
arc=create_struct(arc,tag_names[7],g_sigma)
;
rec_out=arc
;
flush:
return
end
