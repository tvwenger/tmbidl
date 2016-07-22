pro init_NSAVE,help=help
;+
; NAME:
;       INIT_NSAVE
;
;            ============================
;            Syntax: init_nsave,help=help
;            ============================
;
;   init_NSAVE   Initialize NSAVE files at startup (or any other time).  
;   ----------   Asks whether or not to use existing ~nsave.dat and 
;                ~nsave.log files or to make new ones with either the 
;                default, or new file names;
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'init_NSAVE' & return & endif
;
; DO YOU WANT TO MAKE AN FRESH NSAVE FILE?
print,'Current NSAVE file is:'
print,'Nsave file= ' + !nsavefile , ' LUN= ' + fstring(!nsunit,'(I3)')
print,'NSlog file= ' + !nslogfile , ' LUN= ' + fstring(!nslogunit,'(I3)')
print
print,'Do you want to make a new NSAVE file? (y/n: n means use the above files)'
ians=' ' & fdata=' ' & flog=' ' &
read,ians,prompt='Make NSAVE? (y or n):'
;
if (ians eq 'y') then begin             ; create the NSAVE.DAT and NSAVE.LOG files
   try_again: 
   print,'Do you want to OVERWRITE (o) these files or MAKE new ones (n) ?'
   read,ians,prompt='Overwrite or New? (o or n)'
   case ians of 
       'o': begin ; Overwrite case.
            print,'Overwriting NSAVE files'
            make_nsave
            end
       'n': begin
            print,'Enter name of the NSAVE data file (no quotes)'
            read,fdata,prompt='NSAVE data file name:'
            print,'Enter name of the NSAVE log file (no quotes)'
            read,flog,prompt='NSAVE log file name:'
            make_nsave,fdata,flog
            end
      else: begin
            print,'Invalid entry: Please type "o" or "n"'
            goto, try_again
            end
   endcase
endif
;
print
print,'Nsave file= ' + !nsavefile , ' LUN= ' + fstring(!nsunit,'(I3)')
print,'NSlog file= ' + !nslogfile , ' LUN= ' + fstring(!nslogunit,'(I3)')
print
;
return
end
