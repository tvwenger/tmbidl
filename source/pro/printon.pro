pro printon,fname,eps=eps,portrait=portrait,help=help
;+
; NAME:
;       PRINTON
;
;       ===================================================
;       Syntax: printon,fully_qualified_file_name,eps=eps,$
;                       portrait=portrait,help=help
;       ===================================================
;
;   printon   Open a PostScript printfile named FNAME. 
;   -------   If FNAME omitted, default is !plotfile_default 
;             = ../tmbidl/figures/tmbidl.ps
;
;   keywords:  /eps      generates encapsulated .eps file
;              /portrait invoked Portrait mode plot
;                        TMBIDL default is Landscape
;-
; V5.0 July 2007
; V6.1 18mar2010 tmb trying to make PS useful to TMBIDL
;      03aug2010 tmb modified to do either .ps or .eps output
;                    fixed bug in CLR/BW treatment
;      10aug2010 tmb added portrait mode keyword 
; V7.0 03may2013 tvw - added /help, !debug
; v7.0  6may2013 tvw/tmb tweaked to be more general 
;                added !plotfile_default and capability to 
;                handle non-fully qualified file names 
;      12jun2013 tmb tweaked the documentation 
;+
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'printon' & return & endif 
;
@CT_IN
;
if ~Keyword_Set(eps) then ext='ps' else ext='eps'
;
if n_params() eq 0 then fname=!plotfile_default
;
fname=strtrim(fname,2)
fdecomp,fname,disk,dir,name,old_ext  ; find out where plots go
; if passed fname is not a fully qualified file name use default directory 
if dir eq '' then begin
   file_name=name
   fdecomp,!plotfile_default,disk,dir,name,old_ext 
   name=file_name
endif
;
psfilename = dir+name+'.'+ext        ; put fname into full file name
!plot_file=psfilename                ; store this name in !plot_file
;
if !flag then print,'Output going to PostScript file named ',psfilename
;
;pson,filename=psfilename,landscape=1      ; open PS file psfilename                    
;
; alas we have not been consistent as to how we deal with CLR/BW in
; generating plot stuff...
;
;
case 1 of 
      (!clr eq 0 and ext eq 'ps'): if ~Keyword_Set(portrait) $
                                      then psopen,psfilename,/landscape,/color $ ; BW .ps
                                      else psopen,psfilename,/color ; BW .ps
      (!clr eq 1 and ext eq 'ps'): if ~Keyword_Set(portrait) $ 
                                      then psopen,psfilename,/landscape,/color $ ; color .ps
                                      else psopen,psfilename,/color   ; color .ps
      (!clr eq 0 and ext eq 'eps'): if ~Keyword_Set(portrait) $ 
                                      then psopen,psfilename,/landscape,/color,/encap $; BW .eps
                                      else psopen,psfilename,/color,/encap ; BW .eps
      (!clr eq 1 and ext eq 'eps'): if ~Keyword_Set(portrait) $ 
                                      then psopen,psfilename,/landscape,/color,/encap $; color .eps
                                      else psopen,psfilename,/color,/encap ; color .eps
       else: print,!clr,ext,"what is going on?"
endcase
;
return
end
