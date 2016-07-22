pro get_clr,clr,help=help
;+
; NAME:
;       GET_CLR
;
;            ==============================
;            Syntax: get_clr, clr,help=help
;            ==============================
;
;   get_clr   Tests to see if in CLR or BW mode and return proper
;   -------   color choice.

;             clr -> color to use in CLR mode
;-
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'get_clr' & return & endif
; determine if this is color plot or not
;
color=clr  ; color to use if CLR plot
;
case !clr  of 
               1: clr=color     ; if X window and CLR 
               0: begin
                  clr=!white
                  if !d.name eq 'PS' then clr=!black
                  end
endcase

;
return
end
