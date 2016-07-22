pro pause,c_ans,i_ans,help=help,delay=delay,dt=dt
;+
;NAME
;   PAUSE
;  
;   ===============================================
;   Syntax: pause,character_answer,integer_answer,$
;                 help=help,delay=delay,dt=dt
;   ===============================================
;
;   pause Read single character from the keyboard.
;   ----- Returns the answer as both a character AND integer.
;         (if conversion possible, else integer_answer=-1)
;     ==> Keyword DELAY provides true pause via IDL 'wait'.
;         If set, only delays execution, does NOT read kbrd.
;
;   OUTPUTS:  character_answer
;             integer_answer
;
; ==> VERY USEFUL FOR QUERY/ANSWER CODING AS IT DOES NOT <==
;   REQUIRE A <CR> TO GET THE ANSWER AS IS THE CASE FOR 'READ'            
;
;   KEYWORDS:  /help    gives help
;              /delay   pauses execution does NOT read kbrd
;              /dt      /pause delay time (default=2 sec)
;
;-
; V5.0 July 2007
; V5.1 30jul08 tmb Made more flexible by adding return of character
;                  and integer
; V6.1 23May2012 tmb adds IDL WAIT command to give ability to 
;      slow execution of code 
;
; V7.0 03may2013 tvw - added /help, !debug
;      28may2013 tmb - finally adds /delay /dt 
;      16jul2013 tmb/dsb/tvw - print out cans so you know what you did
; V8.0 07jul2016 tmb corrected /help info anent dt default time
;-
;
on_error,!debug ? 0 : 2
on_ioerror,conversion_error
compile_opt idl2
;
if  KeyWord_Set(help) then begin & get_help,'pause' & return & end
if ~KeyWord_Set(dt) then dt=2.0d
if  KeyWord_Set(delay) then goto,skip_the_read 
;
c_ans=get_kbrd(1)
;
print,c_ans
;
i_ans=long(c_ans) ; conversion triggers i/o error 
;
goto,out
conversion_error: i_ans=-1
goto,out
;
skip_the_read:
wait,dt          ; pause dt seconds without read
;
out:
;print,'The integer equivalent is = ',i_ans
;
return
end
