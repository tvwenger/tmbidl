pro axoff,num,help=help
;+
; NAME:
;       AXOFF
;
;   axoff.pro   toggle OFF the labelling of the plot axes
;   ---------   Syntax: axoff,num,help=help   num=1 -> suppress x-axis only
;               ---------------------------       2 -> suppress x+y axis 
;                                             blank -> suppress x-axis only
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'axoff' & return & endif
;
if n_params() eq 0 then num=1
;
case num of 
            1: begin
               !xtitle_old=!x.title    ;  store the x and y axes labels
               !ytitle_old=!y.title
               !x.title=''
               end
         else: begin
               !xtitle_old=!x.title    ;  store the x and y axes labels
               !ytitle_old=!y.title
               !x.title=''
               !y.title=''
               end
endcase
;
return
end
