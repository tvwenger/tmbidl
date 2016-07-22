pro look,op,help=help
;+
; NAME:
;       LOOK
;
;            =====================================
;            Syntax: look, overplot_flag,help=help
;            =====================================
;
;   look  Use STACK locations to ACQUIRE spectra and plot them with a DC level
;   ----  subtracted.  Routine assumes x,y-axes are set properly.
;   
;         overplot_flag determines whether overplots are used:
;
;         If op  is omitted or le 0 then no overplots
;         If op  is gt 0 then overplots
;-
; MODIFICATION HISTORY:
; RTR modifed to take overplot_flag.
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'look' & return & endif
;
if (n_params() eq 0) then begin
                          op=0                     
                          print,"not overplotting"
                 endif
;
dcon               ;  turn DC level remove ON
;
acquire,!astack[0]
rec_info,!astack[0]
show
;
if (op gt 0) then begin
;
                  for i=1,!acount-1 do begin 
                      acquire,!astack[i] 
                      pause
                      rec_info,!astack[i]
                      reshow 
                  endfor 
endif else begin
;
           for i=1,!acount-1 do begin 
               acquire,!astack[i] 
               pause
               rec_info,!astack[i]
               show 
           endfor
       endelse
scn=!b[0].scan_num
!last_look=scn    
;
dcoff              ;  turn DC level remove OFF  
;
return
end

