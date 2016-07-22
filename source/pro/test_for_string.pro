function test_for_string,var,help=help
;+
; NAME:
;      TEST_FOR_STRING
;      test_for_string,var,help=help
;
;   test_for_string.pro   test to see if var is a string or not
;   -------------------   if string then return 1
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
if keyword_set(help) then begin & get_help,'test_for_string' & return,-1 & endif
         on_ioerror,var_is_string
         x=double(var)  ; conversion triggers i/o error if var is string
         goto, var_is_float
         var_is_string:    return,1
         var_is_float:     return,0
end
