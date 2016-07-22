pro rms,sigma,x_min,x_max,help=help
;+
; NAME:
;       RMS
;
;            ========================================
;            Syntax: rms, sigma, xmin, xmax,help=help
;            ========================================
;
;
;   rms    Calculate rms between xmin and xmax.
;   ---    CURON/CUROFF toggles how this is set
;
;          if !cursor=1 then set with the cursor, left to right
;                       else set via command line parameters xmin,xmax
;
;========> RETURNS: sigma = rms in current y-axis units
;-
; MODIFICATION HISTORY:
; V5.0 July 2007
; by tmb 27 July 2007 so that it works for ANY x-axis definition
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'rms' & return & endif
;
case 1 of                   ; execute the boolean (1) true case
;
(!cursor eq 1): begin 
                ccc,xpos,ypos
                idchan,xpos,chxpos
                xmin=chxpos
                ccc,xpos,ypos
                idchan,xpos,chxpos
                xmax=chxpos
                sigma=stddev(!b[0].data[xmin:xmax])       
                end
          else: begin
                idchan,x_min,chxpos
                xmin=chxpos
                idchan,x_max,chxpos
                xmax=chxpos
                sigma=stddev(!b[0].data[xmin:xmax])
                end
endcase
;
print,'RMS = ',sigma
;
return
end

