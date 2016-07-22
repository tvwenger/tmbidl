pro lmarker,help=help
;+
; NAME:
;       LMARKER
;
;            ==========================
;            Syntax:  lmarker,help=help
;            ==========================
;
;   lmarker   Flags lines on basis of line id.  Assumes x-axis
;   -------   is in channels: CHAN mode. 
;             'cmarker' flags on basis of input rxno.
;-
; V5.0 July 2007  RTR invented this damn useful procedure
;                 TMB added some old tunings here
;                 We can go on indefinitely doing this.
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'lmarker' & return & endif
;
lid=strtrim(string(!b[0].line_id),2)
case lid of
    'HE3a': he3
     'A91': a91
    'B115': b115
     'A92': a92
     'H92': h92   ; old Feb04 tuning
    'HE3b': he3
    'HE++': hepp
    'G131': g131
    'G132': g132
;
;  Can add anything you wish to match !b[0].line_id
;
      else: print,'No Line ID match'
endcase
;
return
end
