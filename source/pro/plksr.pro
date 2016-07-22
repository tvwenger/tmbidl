pro plksr,chan,xpos,ypos,help=help
;+
; NAME:
;       PLKSR
;

;   plksr.pro    Invoke cursor and read its position once.  
;   ---------    
;                Modified KURSOR routine for PSEUDO LINE ANALYSIS.
;                Flags position read by cursor and flags another
;                channel shifted by 'chan' amount input
;
;        Syntax: plksr,chan,xpos,ypos,help=help
;        ======================================
;
;                chan      ==> number of channels to shift for second flag
;                xpos,ypos ==> cursor read position in PLOT units
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'plksr' & return & endif
@CT_IN
;
ccc,xpos,ypos
;
clr=!green
sxpos=fstring(xpos,'(I5)')
flg_id,xpos,sxpos,clr
;
clr=!yellow
offset=xpos+chan
soffset=fstring(offset,'(I5)')
flg_id,offset,soffset,clr
;
@CT_OUT
return
end

