pro ploton,fname, no_header=no_header,help=help
;+
; NAME:
;       PLOTON
;
;            ===================================================
;            Syntax: ploton, fully_qualified_file_name,help=help
;            ===================================================
;
;   ploton   Open a PostScript printfile named FNAME. 
;   ------   If FNAME omitted, default is 'idl.ps' in 
;            directory !plot_file
;
;            At BU this plot lives at: /idl/tmbidl/figures/idl.ps
;-
; V5.0 July 2007
;
; V6.1 tmb 22oct09  
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'ploton' & return & endif
;
if (n_params() eq 0) then fname='idl'
;
fname=strtrim(fname,2)
fdecomp,!plot_file,disk,dir,name,ext      ; find out where plots go
if ext EQ '' then ext = 'ps'
psfilename = disk+dir+fname+'.'+ext       ; put fname into full file name
!plot_file=psfilename                     ; store this name in !plot_file
;
pson,filename=psfilename,landscape=1      ; open PS file psfilename                    
;                                           save current display unit for printoff
clr                                       ; force a color plot
if Keyword_Set(no_header) then !plthdr=0  ; suppress the plot header
;
return
end
