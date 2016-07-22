;+
; NAME:
;       GRSdisplay
;
;            ================================================================
;            Syntax: grsdisplay,lgal=lgal,bgal=bgal,vlsr=vlsr,help=help,ps=ps
;            ================================================================
;
;   grsdisplay A procedure that displays  single spectrum with
;   ----------   l_gal,b_gal,Vlsr as input and flags the RRL
;                LSR velocity in one color and in another color 
;                flag velocities that are Vrrl +/- 10 km/s
;
;              Keyword 'ps' saves the plot as a PostScript file in
;                     '/idl/tmbidl/figures/'+outfile
;
; MODIFICATION HISTORY:
; V6.1 30Jan2010 JWR 
;       6Feb2011 JWR Modify so it does just a single spectrum 
;                    with l_gal,b_gal,Vlsr as input
;
pro grsdisplay,lgal,bgal,vlsr,help=help,ps=ps,outfile=outfile
;
on_error,2
compile_opt idl2
;
if Keyword_Set(help) then begin
   print, '======================================================================'
   print, 'Syntax: grsdisplay,lgal=lgal,bgal=bgal,vlsr=vlsr,help=help,ps=ps'
   print, 'displays  single spectrum with l_gal,b_gal,Vlsr as input '
   print, '  and flags the RRL LSR velocity in one color '
   print, '  and in another color flag velocities that are Vrrl +/- 10 km/s'
   print, 'creates plots in /idl/tmbidl/figures/outfile'
   print, 'uses:'
   print, ' Beamlb,lgal,bgal'
   print, ' flag,vlsr'
   print, '======================================================================'
   return
endif
;
if Keyword_Set(ps) then printon,outfile
;
Beamlb,lgal,bgal
xx
zline
vrrl=vlsr
if vrrl gt 0. then flag,vrrl
;
minvrrl=vrrl-10.
if minvrrl gt 0. then flag,minvrrl,color=!red
;
maxvrrl=vrrl+10.
if maxvrrl gt 0. then flag,maxvrrl,color=!red
;
if Keyword_set(ps) then printoff
;
END
