pro setwin,set_state=set_state,restore_state=restore_state,help=help
;+
; NAME:
;       SETWIN
;
;    ========================================================================
;    Syntax: setwin,set_state=set_state,restore_state=restore_state,help=help
;    ========================================================================
;
;   setwin   Controls IDL window state for TMBIDL
;   ------   
;
;     =====> setwin, /set_state     <=== saves current window !d.window
;                                        to !window_state                              
;                                        and picks correct TMBIDL
;                                        graphics window
;
;            setwin, /restore_state <=== restores window: wset,!window_state
;
;-
; V6.1 27aug09  tmb make TMBIDL robust wrt IDL window management
;      23sept09 tmb account for possibility of PS device for hardcopy
;                   punt if window is not X WIN or MAC
;      22nov10  tmb deal with !map_win as well as !line_win and !cont_win
;                   define new !line state:
;              !line=0 => !cont_win
;                    1    !line_win
;                    2    !map_win
; V7.0 03may2013 tvw - added /help, !debug
; v8.0 18jun2015 tmb - fixed wenger's birthday bug 
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'setwinx' & return & endif
;
; punt if window is not X WIN or MAC
;
curwin=!d.name
xwin="X" & winwin="WIN" & macwin="MAC" &
if (curwin ne xwin) and (curwin ne winwin) and (curwin ne macwin) then begin
   print,' WARNING:  Current window '+curwin+' is not Xwin compatible'
   return
end
;
if Keyword_set(restore_state) then begin
           wset,!window_state  ; restore previous window assignment
           return
           endif
;
if Keyword_set(set_state) then begin
           !window_state=!d.window  ; save current window assignment           
;          figure out with TMBIDL graphics window to use
           case !line of       ; choose either LINE or CONTinuum window
;
                2: begin
                   wset,!map_win
                   wshow,!map_win,iconic=0
                   end
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

; 22nov10 tmb does not think the code below to be necessary
;!p.multi=0
;!p.position=[0.13,0.15,0.93,0.80]   ; restore normal graphics plot box parameters
;            
           return
        endif 
;
return
end
