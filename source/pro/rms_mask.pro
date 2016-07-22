pro rms_mask,sigma,help=help
;+
; NAME:
;       RMS_MASK
;
;            =================================
;            Syntax: rms_mask, sigma,help=help
;            =================================
;
;   rms_mask  Calculate RMS of data within the NREGIONs.
;   --------  If no NREGIONs are set, returns RMS for
;             plotted x-axis range 
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'rms_mask' & return & endif
;
xmin = !x.crange[0]
xmax = !x.crange[1]
;
case !nrset of 
               0: mask,sigma
            else: sigma=stddev(!b[0].data[xmin:xmax])
endcase
;
print,'RMS inside NREGION zones= ',sigma
;
return
end

