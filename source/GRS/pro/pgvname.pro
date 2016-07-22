;+
; NAME:
;       PGVNAME
;
;            =============================================
;            Syntax: PGVNAME,gvname,lgal,bgal,vlsr,out=out
;            =============================================
;
;   PGVNAME  procedure to parse an input GVNAME string and
;   -------  return the lgal,bgal,vlsr float values together
;            with a formatted string for output to a file.
;
;   KEYWORDS: out => gvname+lgal+bgal+vlsr as a formatted string
;
; MODIFICATION HISTORY:
;
; v6.1 tmb 11feb2011 
;
;-
pro pgvname,gvname,lgal,bgal,vlsr,out=out 
;
on_error,2        ; on error return to top level
compile_opt idl2  ; compile with long integers 
;
;gvname='G18.156+0.099+53.0'
;
lgal=float(strmid(gvname,1,6))
bgal=float(strmid(gvname,7,6))
vlsr=float(strmid(gvname,13,strlen(gvname)-13))
;
out=gvname+' '+fstring(lgal,'(f6.3)')+' '
out=out+fstring(bgal,'(f6.3)')+' '
out=out+fstring(vlsr,'(f6.1)')+' '
print,out
;
return
end
