pro aoflags,help=help
;+
; NAME:
;       AOFLAGS
;
;            =========================
;            Syntax: aoflags,help=help
;            =========================
;
;   aoflags  ARECIBO OBSERVING VERSION HARDWIRED ONLY FOR ARECIBO 
;   -------  
;
; MODIFICATION HISTORY:
; 6JAN09 tmb 
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'aoflags' & return & endif
;
if !line ne 1 and !chan ne 1 then begin
         print,"Cannot show flags !"
         print,"Must be spectral line data displayed in channels."
         return
endif
;
rxid=strmid(string(!b[0].line_id),0,3)
;
case rxid of
          'rx1': g132
          'rx2': b115
          'rx3': a91
          'rx4': he3
         'G132': g132
         'B115': b115
          'A91': a91
          'He3': he3
           else: print,'Invalid Correlator Configuration!!!'
endcase
;
return
end
