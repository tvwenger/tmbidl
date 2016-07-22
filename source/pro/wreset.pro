pro wreset,help=help
;+
; NAME:
;       WRESET
;
;            ========================
;            Syntax: wreset,help=help
;            ========================
;
;   wreset   Reset window from specialized window to either LINE or 
;   ------   CONTinuum graphics window.
;
;     =====> Used to kill off windows from BSEARCH, RADIOM, QLOOK4, GRS
;-
; V5.0 July 2007
; V5.1 aug08 tmb/lda changed to system variable for window IDs
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'wreset' & return & endif
;
wdelete             ; delete current window
;
case !line of       ; choose either LINE or CONTinuum window
;
           1: begin
              wset,!line_win
              wshow,!line_win,iconic=0
              end
;
           0: begin
              wset,!cont_win
              wshow,!cont_win,iconic=0
              end
;
          endcase
;
!p.multi=0
!p.position=[0.13,0.15,0.93,0.80]   ; restore normal graphics plot box parameters
;
return
end
