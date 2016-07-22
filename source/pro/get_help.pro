pro get_help,proname,help=help
;+
; NAME:
;       GET_HELP
;
;    ===================================================================
;    Syntax: get_help,proname,help=help
;    ===================================================================
;
;   get_help  output the documentation of a procedue.
;   --------  PROCEDURE MUST BE COMPILED
;             everything between ';+' and ';-' is printed.
;             uses code from 'which.pro'
;
;   KEYWORDS: help - displays help info
;-
; MODIFICATION HISTORY:
; 9 april 2012 tvw
; V7.0 3may2013 tvw - added /help, !debug
;      20jul2013 tvw - fixed bug where routine_info would crash at
;                      Green Bank because it was printing the entire
;                      list of routine sources, then picking out the
;                      one we want
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2  ; compile with long integers
;
if keyword_set(help) then begin
    get_help,'get_help'
    return
endif
;
; modification of code from which.pro
;
; IF .PRO SUFFIX INCLUDED, DROP IT...
proname = strtrim(proname,2)
if strmatch(proname,'*.pro', /FOLD_CASE) $
  then proname = strmid(proname,0,strlen(proname)-4)
; SEARCH THE CURRENTLY-COMPILED PROCEDURES AND FUNCTIONS FIRST...
pindx = where(which_find_routine(proname),presolved)
findx = where(which_find_routine(proname,/FUNCTIONS),fresolved)

; IF PROCEDURE OR FUNCTION WAS FOUND, IS IT UNRESOLVED...
punresolved = total(which_find_routine(proname,/UNRESOLVED))
funresolved = total(which_find_routine(proname,/UNRESOLVED,/FUNCTIONS))

if (presolved and not punresolved) OR $
   (fresolved and not funresolved) then begin

    ; THE PROCEDURE OR FUNCTION WAS FOUND...
    ;resolved_routine = (presolved AND not fresolved) ? $
    ;  (routine_info(/SOURCE))[pindx].PATH : $
    ;  (routine_info(/SOURCE,/FUNCTIONS))[findx].PATH
   resolved_routine = (presolved AND not fresolved) ? $
      (routine_info(strupcase(proname),/SOURCE)).PATH : $
      (routine_info(strupcase(proname),/SOURCE,/FUNCTIONS)).PATH

    ;print, 'Currently-Compiled Module '+strupcase(proname)+' in File:'
    ;print, resolved_routine, format='(A,%"\N")'
    fname=resolved_routine

endif $
else begin 
    print, strupcase(proname), format='("Module ",A," Not Compiled.",%"\N")'
    return
endelse
;
; end which.pro code
;
str=''
openr,lun,fname,/get_lun
while ~eof(lun) do begin
    readf,lun,str
    check=strmid(str,0,2)
    ;
    if check eq ';+' then begin
        print,str
        while ~(check eq ';-') do begin
            readf,lun,str
            print,str
            check=strmid(str,0,2)
        endwhile
        break
    endif
endwhile
free_lun,lun
;
return
end
