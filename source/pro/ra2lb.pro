PRO ra2lb,gl,gb,ra,dec,epoch,j_flag, degree=degree, fk4 = fk4,help=help
;+
; NAME:
;       RA2LB
;
;            =======================================================================
;            Syntax: ra2lb,gl,gb,ra,dec,epoch,j_flag,degree=degree,fk4=fk4,help=help
;            =======================================================================
;
;   ra2lb    Converts RA,DEC to L_GAL,B_GAL and vice versa
;   -----    using the ASTROLIB procedure GLACTC
;
;            ==> Syntax: ra2lb,gl,gb  <==
;                ...................
;            This fetches the RA/DEC/EPOCH from !b[0] 
;            and returns the galactic position.     
;
; GLACTC.pro
; ==========
; CALLING SEQUENCE: 
;       GLACTC, ra, dec, year, gl, gb, j, [ /DEGREE, /FK4, /SuperGalactic ]
;
; INPUT PARAMETERS: 
;       year     equinox of ra and dec, scalar       (input)
;       j        direction of conversion     (input)
;               1:  ra,dec --> gl,gb
;               2:  gl,gb  --> ra,dec
;
; INPUTS OR OUTPUT PARAMETERS: ( depending on argument J )
;       ra       Right ascension, hours (or degrees if /DEGREES is set), 
;                         scalar or vector
;       dec      Declination, degrees,scalar or vector
;       gl       Galactic longitude, degrees, scalar or vector
;       gb       Galactic latitude, degrees, scalar or vector
;
;       All results forced double precision floating.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;       /DEGREE - If set, then the RA parameter (both input and output) is 
;                given in degrees rather than hours. 
;       /FK4 - If set, then the celestial (RA, Dec) coordinates are assumed
;              to be input/output in the FK4 system.    By default,  coordinates
;              are assumed to be in the FK5 system.    For B1950 coordinates,
;              set the /FK4 keyword *and* set the year to 1950.
;-
; MODIFICATION HISTORY:
; V5.1 tmb 5aug08
;      tmb 17sept08  never finished the procedure for the general case!
;
; V6.0 tmb 20July09  removed explicity printing of the RA,DEC and
; L-gal/B-gal
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
npar=n_params()
if npar lt 2 or keyword_set(help) then begin & get_help,'ra2lb' & return & endif
;       
case npar of 
     2:begin      ; do the hardwired TMBIDL case
       ra=!b[0].ra        ; RA/DEC in degrees in header
       dec=!b[0].dec
       epoch=!b[0].epoch
       j_flag=1
       if epoch eq 1950. $
                then GLACTC,ra,dec,epoch,gl,gb,j_flag,/DEGREE,/FK4 $
                else GLACTC,ra,dec,epoch,gl,gb,j_flag,/DEGREE
       end
  else:begin ; do the general case based on input j_flag
       if epoch eq 1950. $
                then GLACTC,ra,dec,epoch,gl,gb,j_flag,/DEGREE,/FK4 $
                else GLACTC,ra,dec,epoch,gl,gb,j_flag,/DEGREE
       end
endcase
;
fmt='("L_gal = ",f8.4,"  B_gal = ",f8.4," RA = ",f8.4," Dec = ",f8.4)'
;if not !batch then print,gl,gb,ra,dec,format=fmt
;
return
end
