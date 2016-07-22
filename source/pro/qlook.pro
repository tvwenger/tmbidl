pro qlook,over_plot_flag, avg=avg,help=help
;+
; NAME:
;       QLOOK
;
;            ================================================
;            Syntax: qlook, over_plot_flag, avg=avg,help=help
;            ================================================
;
;   qlook  Take a quick look at all the subcorrelators with appropriate flags.
;   -----  SELECTS records in STACK and executes the LOOK command.  Can be
;          used for a single scan via SETSCAN.

;          If no over_plot_flag passed then no overplots.
;          ANY over_plot_flag does overplots.
;
;   Uses !config to pick correct flags for given ACS configuration:
;   
;        !config = 0 for 3-Helium flags'
;                = 1 for 7-alpha  flags'
;-
; MODIFICATION HISTORY:
; V5.0 July 2007
; by TMB 27 July 2007 to make it more efficient than rtr verions
; V5.1 TMB adds !config flag to pick ACS configuration
;
; V6.1 TMB 20 jan 2012 added avg keyword which if set shows average
;                      of records in the stack instead of each one
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'qlook' & return & endif
;
op=1
if n_params() eq 0 then begin
                   op=0                     
                   print,"Not overplotting the spectra"
                   endif
;
if !config eq -1 then begin
                 print
                 print,'Need to specify ACS configuration for correct flags!!!'
                 print
                 print,'!config = 0 for 3-Helium flags'
                 print,'!config = 1 for 7-alpha  flags'
                 print
                 return
                 endif
;
rxid =['rx1','rx2','rx3','rx4','rx5','rx6','rx7','rx8']
config=!config
;
for i=0,n_elements(rxid)-1 do begin
      clrstk
      setid,rxid[i]
      select
      rlook,rxid[i], avg=avg 
endfor
;
return
end
