pro cqlook,brec,erec,help=help
;+
; NAME:
;       CQLOOK
;
;            ============================================
;            Syntax: cqlook, begin_rec, end_rec,help=help
;            ============================================
;
;   cqlook  Take a quick look at the continuum data records
;   -----   in the OFFLINE data file.  Intended for real time
;           data quality check.
;     ==>  SUBTRACTS A DC OFFSET <===
;          Puts all continuum scans into CHAN mode.
;          Flags the center channel.
;
; MODIFICATION HISTORY:
; V5.1 14 Jan 2008  TMB 
;       7 Mar 2008  TMB had to move chan command because of NRAO bug
;       wrt !c_pts. grrr
; V7.0 3may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'cqlook' & return & endif
;
;chan 
;
for i=brec,erec do begin
      get,i
      if i eq brec then chan
      freex
      dc=mean(!b[0].data[5:!c_pts-5])
      !b[0].data[0:!c_pts-1]=!b[0].data[0:!c_pts-1]-dc
      case i eq brec of
             1: begin
                max=max(!b[0].data[5:!c_pts-5],min=min)
                !y.range=[min,max] & !y.range=1.25*!y.range
                xx 
                center=(!c_pts+1)/2 
                flag,center 
                end
          else: reshow
      endcase
      pause,ians
endfor
;
return
end
