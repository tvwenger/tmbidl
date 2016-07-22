pro init_MESS,help=help
;+
; NAME:
;       INIT_MESS
;
;            ===========================
;            Syntax: init_mess,help=help
;            ===========================
;
;   init_MESS   Initialize MESSage files at startup. 
;   ---------   Asks whether or not to use existing message file
;               or to make a new one with either the default, 
;               or a new file name
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'init_MESS' & return & endif
;
; DO YOU WANT TO MAKE AN FRESH MESSAGE FILE?
print,'Current MESSAGE file is:'
print,'Message file= ' + !messfile , ' LUN= ' + fstring(!messunit,'(I3)')
print
print,'Do you want to make a new MESSAGE file? (y/n: n means use the above file)'
ians=' ' & fmess=' ' & 
read,ians,prompt='Make MESSAGE file? (y or n):'
;
if (ians eq 'y') then begin             ; create the MESS. 
   try_again: 
   print,'Do you want to OVERWRITE (o) this file or a MAKE new one (n) ?'
   read,ians,prompt='Overwrite or New? (o or n)'
   case ians of 
       'o': begin ; Overwrite case.
            print,'Overwriting MESS files'
            make_mess
            end
       'n': begin
            print,'Enter name of the MESSAGE file (no quotes)'
            read,fmess,prompt='MESSAGE file name:'
            make_mess,fmess
            end
      else: begin
            print,'Invalid entry: Please type "o" or "n"'
            goto, try_again
            end
   endcase
endif
;
print
print,'Message file= ' + !messfile , ' LUN= ' + fstring(!messunit,'(I3)')
print
;
return
end
