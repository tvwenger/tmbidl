;+
; NAME:
;       PARSE_ARCHIVE_LHEAD
;
; Parse an input archive record structure in LINE_HEADER format 
; into meaningful data. Returns a named structure 'rec_out'
; that has meaningful tag names and correct variable type.
;     
; Syntax: parse_archive_LHEAD,archive_structure_in,parsed_structure_out
; =====================================================================
;
; V5.0 July 2007
;-
pro parse_archive_LHEAD,rec_in,rec_out
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
rec=rec_in
name='LHEAD'
;
; for write_archive_LHEAD.pro
;
tag_names=['archive_type','source','scan','lineid','type','pol',$
           'ra','dec','epoch','l_gal','b_gal','srcvel','date','lst',$
           'ha','za','az','el','fsky', 'frest','bw','tcal','tsys','tintg']
ntags=n_elements(tag_names)
;
archive_type=rec.(0)
source=rec.(1)
scan=long(rec.(2))
lineid=rec.(3)
type=rec.(4)
pol=rec.(5)
ra=float(rec.(6))
dec=float(rec.(7))
epoch=float(rec.(8))
l_gal=float(rec.(9))
b_gal=float(rec.(10))
srcvel=float(rec.(11))
date=rec.(12)
lst=float(rec.(13))
ha=float(rec.(14))
za=float(rec.(15))
az=float(rec.(16))
el=float(rec.(17))
fsky=float(rec.(18))
frest=float(rec.(19))
bw=float(rec.(20))
tcal=float(rec.(21))
tsys=float(rec.(22))
tintg=float(rec.(23))
;
tag=tag_names[0]             ; first make the named array
arc=create_struct(name=strname,tag,archive_type)
;
; now fill the structure
;
arc=create_struct(arc,tag_names[1],  source)
arc=create_struct(arc,tag_names[2],  scan)
arc=create_struct(arc,tag_names[3],  lineid)
arc=create_struct(arc,tag_names[4],  type)
arc=create_struct(arc,tag_names[5],  pol)
arc=create_struct(arc,tag_names[6],  ra)
arc=create_struct(arc,tag_names[7],  dec)
arc=create_struct(arc,tag_names[8],  epoch)
arc=create_struct(arc,tag_names[9],  l_gal)
arc=create_struct(arc,tag_names[10], b_gal)
arc=create_struct(arc,tag_names[11], srcvel)
arc=create_struct(arc,tag_names[12], date)
arc=create_struct(arc,tag_names[13], lst)
arc=create_struct(arc,tag_names[14], ha)
arc=create_struct(arc,tag_names[15], za)
arc=create_struct(arc,tag_names[16], az )
arc=create_struct(arc,tag_names[17], el )
arc=create_struct(arc,tag_names[18], fsky )
arc=create_struct(arc,tag_names[19], frest )
arc=create_struct(arc,tag_names[20], bw )
arc=create_struct(arc,tag_names[21], tcal )
arc=create_struct(arc,tag_names[22], tsys )
arc=create_struct(arc,tag_names[23], tintg )
;
rec_out=arc
;
flush:
return
end
