pro def_xaxis,num_pts,help=help
;+
; NAME:
;       DEF_XAXIS
;
;  def_xaxis   Define x-axis units. 
;  --------    Returns number of data points on axis, num_pts
;                   If !chan  then x-axis is in channels      line/continuum
;                      !freq                    frequency     line only
;                      !velo                    lsr velocity  line only
;                      !elxx                    elevation     continuum only
;                      !azxx                    azimuth              "   "
;                      !raxx                    right ascension      "   "
;                      !decx                    declination          "   "
;
;                      !vgrs                    lsr velocity for GRS survey
;                      !velx                    velocity for imported data
;                                               (see code for details 
;
;       ===================================
;       Syntax: def_xaxis,num_pts,help=help
;       ===================================
;
; V5.0 July 2007   TMB worked on chan/freq/lsr_vel accuracy vis a vis sideband
; 14 Aug 07 tmb modifed to get num_pts correct 
; 26 Oct 07 tmb modified to allow for different continuum data sizes
;           modified to allow absolute/relative continuum x-axis display
; V5.1 Nov 07
;           tmb modified so continuum always has 819 data channels max
;           this parses c_pts = !b[0].c_pts for plots and analyses
;           x-axis units now toggle with !relative
;
;      Mar 08 07
;           tmb modified so RA axis can deal with offset display
;           for sources that track their TCJs through 360=>0 deg
;
; 06feb09 tmb modified definition of center channel for VELOCITY
;             conversion of x-axis
;
; V6.0 June 2009 tmb/dsb 
;                Use the sign of !b[0].delta_x instead of !b[0].sideband.
;                Use !b[0].delta_x to calculate dv.
;
; v6.1 march 2010 tmb added comments about SDFITS getting the sideband wrong
;
; V7.0 3may2013 tvw - added /help, !debug
; V8.0 9jun2016 tmb - added !velx feature for imported velocity axis
;                     motivated by CfA 1.2m CO data. see code for details
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'def_xaxis' & return & endif
;
case !LINE of 
     0: begin
        !c_pts=!b[0].c_pts ; number of continuum data points 
        num_pts=!c_pts     ; if continuum mode restrict channels 
        end
  else: num_pts=n_elements(!b[0].data) ; number of spectral line data points 
endcase
;
case 1 of                   ; execute the boolean (1) true case
;
(!chan eq 1): case !LINE of 
                   0: xx=indgen(!c_pts) ; continuum
                else: xx = !xchan      ; line
              endcase
(!freq eq 1): begin 
              imax=n_elements(!b[0].data)
              faxis=fltarr(imax)
              fr0=!b[0].sky_freq
              ch0=!b[0].ref_ch
              df=!b[0].delta_x
              for i=0,imax-1 do faxis[i]=(fr0-(ch0)*df)+i*df
              xx=faxis/1.0e+06  ; freq. axis in MHz
              ;; xx is float array of frequencies
              end
(!velo eq 1): begin 
              ; xx=  is float array of lsr velocities
              imax=n_elements(!b[0].data)
              vaxis=fltarr(imax)
;              ch0=!b[0].ref_ch-1    ; redefine the center channel for dsb
              ch0=!b[0].ref_ch    
              ; velocity is inverted w.r.t. frequency
              dv = -!b[0].delta_x/!b[0].sky_freq*!light_c
              vel0=!b[0].vel/1.0D+3
              for i=0,imax-1 do vaxis[i]=((vel0-(ch0)*dv)+i*dv)
              xx=vaxis
; this code was used until v5.1 when we noticed that SDFITS was
; sending the incorrect sideband identification.
;
; dv= (!b[0].bw*!light_c)/!b[0].sky_freq
;              dv= dv/!nchan
;              vel0=!b[0].vel/1.0D+3
;              sideband=string(!b[0].sideband)
;              sideband=strtrim(sideband,2)
;              if sideband eq 'U' then sign=+1. $
;                                 else sign=-1.
;              for i=0,imax-1 do vaxis[i]=sign*((vel0-(ch0)*dv)+i*dv)
              end
(!vgrs eq 1): begin
              imax=n_elements(!b[0].data)
              vaxis=fltarr(imax)
              for i=0,imax-1 do vaxis[i]=(i-!grsCenCh)*!grsDeltaV+!grsVcen
              xx=vaxis
              end
(!velx eq 1): begin
;             useses !b[0] header info to hardwire velocity axis
              v0=!b[0].vel         ;  velocity at ref_ch [km/sec]
              ref_ch=!b[0].ref_ch  ;  reference channel
              dv=!b[0].delta_x     ; delta velocity per channel 
              imax=n_elements(!b[0].data)
              vaxis=fltarr(imax)
              for i=0,imax-1 do vaxis[i]=(i-ref_ch)*dv+v0             
              xx=vaxis
              end
(!azxx eq 1): begin 
              if !relative then !x.title='Azimuth Offset (arcsec)' $
                           else !x.title='Azimuth (degrees)'              
              ; xx is float array for azimuths
              !x_az= !b[0].data[1*!c_chan:2*!c_chan-1]
              if !relative then begin
                 avg=mean(!x_az[0:!c_pts-1])
                 !x_az=(!x_az-avg)*3600. ; arcseconds
                 end
              xx=!x_az[0:!c_pts-1]
              end
(!elxx eq 1): begin 
              if !relative then !x.title='Elevation Offset (arcsec)' $
                           else !x.title='Elevation (degrees)'              
              ; xx is float array for elevations
              !x_el= !b[0].data[2*!c_chan:3*!c_chan-1]
              if !relative then begin
                 avg=mean(!x_el[0:!c_pts-1])
                 !x_el=(!x_el-avg)*3600. ; arcseconds
                 end
              xx=!x_el[0:!c_pts-1]
              end
(!raxx eq 1): begin 
              ; xx is float array for right ascensions
              if !relative then !x.title='Right Ascension Offset (arcsec)' $
                           else !x.title='Right Ascension (degrees)'   
              !x_ra= !b[0].data[3*!c_chan:4*!c_chan-1]
              if !relative then begin
                 center=!b[0].ra
                 center_xra=!x_ra[(!c_pts-2)/2]
                 cdiff=center-center_xra
                 ; this deals with sources slewing through
                 ; RA 360=>0 deg.... SDFITS strikes again
                 if cdiff gt 1.0 then center=center-360.
                 !x_ra=(!x_ra-center)*3600. ; arcseconds
                 ; if flagged then make the cosDEC correction
                 if !cosdec then !x_ra=!x_ra*cos(!b[0].dec*!dtor)
                 end
              xx=!x_ra[0:!c_pts-1]
              end
(!decx eq 1): begin 
              ; xx is float array for declinations
              if !relative then !x.title='Declination Offset (arcsec)' $
                           else !x.title='Declination (degrees)'
              !x_dec=!b[0].data[4*!c_chan:5*!c_chan-1]
              if !relative then begin
                 center=!b[0].dec
                 !x_dec=(!x_dec-center)*3600. ; arcseconds
                 end
              xx=!x_dec[0:!c_pts-1]
              end
;
else:  print,'screwy x-axis definition'
endcase
;
!xx[0:num_pts-1]=xx     ;  copy current x-axis into global variable 
;
return
end
