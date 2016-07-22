pro cmarker,nrx1,help=help
;+
; NAME:
;       CMARKER
;
;   cmarker.pro   Plots line id flags for input receiver, nrx1.
;   -----------   Assumes x-axis is in channels: CHAN mode
;                 Default is nrx1=1
;                 'lmarker' flags on basis of Line ID
;
;                 Syntax: cmarker,nrx1,help=help
;                 ==============================
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'cmarker' & return & endif
;
if n_params() eq 0 then begin
                   nrx1=1
                   end
;
loop:
      case nrx1 of
                1: he3
                2: a91
                3: b115
                4: a92
                5: he3
                6: hepp
                7: g131
                8: g132
             else: begin
                   print,'Bogus receiver assignment to CMARKER'
                   nrx=1
                   goto, loop
                   end
      endcase
return
;
end

