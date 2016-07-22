pro comment,msg,help=help
;+
; NAME:
;      COMMENT
;
;   comment.pro   Writes a string into !b[0].history for annotation.
;   -----------   msg_max character maximum from {tmbidl_data};  
;                 routine truncates to fit.
;        =======> Executing 'comment' continues to concatenate
;                 these strings onto !b[0].history
;
;          Syntax: comment,msg,help=help  <== 'msg' is a string
;          ==========================================
;
; V5.0 July 2007  TMB modifies so COMMENT does NOT override
;                 information potentially written by 'history'
; v5.1 28jan09 tmb tweakes to stop truncation at rehash....
; V7.0 03may13 tvw - added /help, !debug
; v7.1 19aug13 tvw - fixed bug where size not being written right
;                    if history is empty to start
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'comment' & return & endif
;
; how big is !b[0].history?
max_size=n_elements(!b[0].history)    
; has 'history' put anything here?
current_size=long(string(!b[0].history[0:2])) 
; tvw fix
if current_size lt 4 then current_size=4
;
msg_max=max_size-current_size
;
blk=' '
comment='COMMENT ' ; HISTORY always write a blank at the end.
;                    if COMMENT is used alone it should not start
;                    with a blank
;
if (n_params() eq 0) then begin
                     msg=' '
                     read,msg,prompt='Input comment: '
                     endif
; 
msg=comment+msg+blk  ; force message header and a blank at the end
msg_size=strlen(msg)
if msg_size ge msg_max then begin
                       msg=strmid(msg,0,msg_max-1)
                       msg=msg+blk ; for blank at end
                       endif
; 
if msg_size gt msg_max then print,'OOPS TMB got the index wrong by one again!'
;
new_size=current_size+msg_size
size=fstring(new_size,'(I3)')
!b[0].history[0:2]=byte(size)  ;  write current size of history
;
; tvw fix
start=current_size
stop =current_size+msg_size-1
!b[0].history[start:stop]=byte(msg)
; 
return
end

