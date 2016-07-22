pro psclose,help=help
;+
; NAME:
;PSCLOSE -- close ps, open X.
;     
; PURPOSE:
;       To close the Postscript device and set the graphics output
;       device back to X Windows.
;     
; CALLING SEQUENCE:
;       PSCLOSE,help=help
;     
;
; SIDE EFFECTS:
;       The device is changed.
;
; RESTRICTIONS:
;       A PostScript file must be open.
;
; RELATED PROCEDURES:
;       PSOPEN
;-
; MODIFICATION HISTORY:
;       Written by Tim Robishaw in ancient times.
; TMBIDL v6.1 TMB 14mar2010 
; V7.0 03may2013 tvw - added /help, !debug
;-
if keyword_set(help) then begin & get_help,'psclose' & return & endif
; MAKE SURE WE HAVE POSTSCRIPT DEVICE OPEN...
if (!d.name ne 'PS') then begin
    message, 'DEVICE is not set to PS!', /INFO
    return
endif
; RESTORE PLOT DEFAULTS
!p=!p_old & !x=!x_old & !y=!y_old & !z=!z_old
; CLOSE THE POSTSCRIPT DEVICE...
device, /CLOSE_FILE
; SET THE GRAPHICS OUTPUT DEVICE TO X WINDOWS...
set_plot, 'X'
;
return
end; psclose
