;+
; NAME:
;       STACKINFO
;
;            ===========================
;            Syntax: stackinfo,help=help
;            ===========================
;
;   stackinfo  List contents of STACK. Shows !b[0]. :
;   ---------  scan_num source scan_type line_id rest_freq [MHz]
;
;   KEYWORDS:
;             HELP switch to return Command Syntax 
;             READ swith to read keyboard input continuously
;                  enter 'q' to QUIT 
;             PS   switch to generate PostScript output 
;
;-
; MODIFICATION HISTORY:
;  01 july 2011  TMB 
;  v7.0 18jul2013 tmb - rewrote and extended 
;
;-
pro stackinfo,help=help
;
on_error,2        ; on error return to top level
compile_opt idl2  ; compile with long integers 
;
if Keyword_Set(help) then begin & get_help,'stackinfo' & return & endif
;
if !acount eq 0 then begin & print,'STACK is empty' & return & endif & 
;
for i=0,!acount-1 do begin
    if i eq 0 then begin & print,'STACK contains:'
       print,' #   Source  Type    ID    Frest'
    endif
    getns,!astack[i]
    blk=' '
    nreg=!b[0].scan_num
    snreg=fstring(nreg,'(i4)')
    src=strtrim(string(!b[0].source),2)
    typ=strtrim(string(!b[0].scan_type),2)
    id=strtrim(string(!b[0].line_id),2)
    frest=!b[0].rest_freq/1.d+6
    sfrest=fstring(frest,'(f7.2)')
    msg=snreg+blk+src+blk+typ+blk+id+blk+sfrest
    print,msg
endfor
;
return
end
