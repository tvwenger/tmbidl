pro qav,rx_num,help=help
;+
; NAME:
;       QAV
;
;            ======================================
;            Syntax: qav, rx_#_to_average,help=help
;            ======================================
;
;   qav   From the existing selection criteria, fill the stack with
;   ---   all matching records, both polarizations, average, and flag.
;         Specify which receiver number (1->8, integer) via 'rx_num'
;         If rx_num not given, prompts for input.               
;-
;  V5.0 July 2007
;  V5.1 Feb  2008 rtr modified to work with any !config via flags
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'qav' & return & endif
;
rxid =['rx1','rx2','rx3','rx4','rx5','rx6','rx7','rx8']
;
if n_params() eq 0 then begin
                   print,'Error: Must specify receiver to average!'
                   print,'Syntax: qav,rx#'
                   ans=' '
              menu:
                   print,'Enter rx#  (<CR> or m for Menu)'
                   read,ans,prompt='RX_NUM='
                   case ans of 
                        '1': rx_num=1
                        '2': rx_num=2
                        '3': rx_num=3
                        '4': rx_num=4
                        '5': rx_num=5
                        '6': rx_num=6
                        '7': rx_num=7
                        '8': rx_num=8
                       else: begin
                                  print,'Receivers in this configuration:'
                                  print,'rx#  ->  
                                  print,' 1   rx1 : 3-He+ 
                                  print,' 2   rx2 : 91 alpha
                                  print,' 3   rx3 : 115 beta
                                  print,' 4   rx4 : 92 alpha
                                  print,' 5   rx5 : 3-He+
                                  print,' 6   rx6 : He++
                                  print,' 7   rx7 : 131 gamma
                                  print,' 8   rx8 : 132 gamma
                             goto,menu
                                  end
                   endcase
                   end
; 
      idx=rx_num-1      ; IDL array subscript convention !
      clrstk
      setid,rxid[idx]
      select
;      xroll
      avgstk
      copy,0,8
      flags
;
;
return
end
