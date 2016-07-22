pro sd_to_gbt,in,out,help=help
;+
; NAME:
;       SD_TO_GBT
;
;            ================================================
;            Syntax: sd_to_gbt, in_struc, out_stric,help=help
;            ================================================
;
;   sd_to_gbt   Convert the SDFITS structure into the {TMBIDL_DATA}
;   ---------   structure. Does this on a record by record basis. 
;
;               'in'  is SDFITS data structure input sdd[]
;               'out' is {TMBIDL_DATA} data structure output 
;
;============>  Invoked by MAKE_DATA and MAKE_ONLINE
;-
; MODIFICATION HISTORY:
; V5.0 July 2007
; by tmb 27jul07 to set 'yunits' and 'ytype' to defaults 'K' and 'TA'
;    tmb 05aug08 to add EPOCH information to the TMBIDL header
;
; v6.1 tmb 05feb11 to accomodate NRAO's change of SDFITS variable 
;                  names:  BEAMXOFF -> FEEDXOFF
;                          BEEMEOFF -> FEEDEOFF
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'sd_to_gbt' & return & endif
;
out.source=byte(in.object)
out.observer=byte(in.observer)
out.obsid=byte(in.obsid)
out.scan_num=in.scan
out.last_on =in.laston
out.last_off=in.lastoff
out.procseqn=in.procseqn
out.procsize=in.procsize
out.line_id=byte(in.sampler)
; get the polarization ID -- the Stokes parameter of the data.
case (in.crval4) of
                     1: out.pol_id=byte('I')
                     2: out.pol_id=byte('Q')
                     3: out.pol_id=byte('U')
                     4: out.pol_id=byte('V') 
                    -1: out.pol_id=byte('RR')
                    -2: out.pol_id=byte('LL')
                    -3: out.pol_id=byte('RL')
                    -4: out.pol_id=byte('LR')
                    -5: out.pol_id=byte('XX')
                    -6: out.pol_id=byte('YY')
                    -7: out.pol_id=byte('XY')
                    -8: out.pol_id=byte('YX')
                  else: begin
                        out.pol_id=byte('I')
                        print,'Polarization ID failure -- Stokes I assumed'
                        end
                endcase
;
out.scan_type=byte(in.obsmode)
out.lst=in.lst
out.date=byte(in.date_obs)
;
; calculate modified Julian Date (see ASTROLIB)
;
obsdate=in.date_obs
year=long(strmid(obsdate,0,4))
month=long(strmid(obsdate,5,2))
day=long(strmid(obsdate,8,2))
juldate,[year,month,day],jd
;
out.frontend=byte(in.frontend)
out.ra=in.crval2
out.dec=in.crval3
out.epoch=in.equinox
out.az=in.azimuth
out.el=in.elevatio
out.vel=in.velocity
out.sky_freq=in.obsfreq
out.rest_freq=in.restfreq
out.freqoff=in.foffref1
out.ref_ch=in.crpix1
out.delta_x=in.cdelt1
out.vel_def=byte(in.veldef)
out.vframe=in.vframe
out.rvsys=in.rvsys
out.bw=in.bandwid
out.tsys=in.tsys
if ( strmid(in.obsmode,13,2) eq 'ON' ) then out.tsys_on  = in.tsys $
                                       else out.tsys_off = in.tsys
out.tcal=in.tcal
out.tintg=in.exposure
out.feed=in.feed
out.srfeed=in.srfeed
;
; SDFITS kwords changed:  discovered 5 feb 2011
; filter this change via JD of observations
; SDFITS Break point JD assumed here to be:  2011 01 01 => jd0
;
juldate,[2011,01,01],jd0
;
case  1 of 
     jd ge jd0: begin 
                out.beamxoff=in.feedxoff
                out.beameoff=in.feedeoff
                end
          else: begin
                out.beamxoff=in.beamxoff
                out.beameoff=in.beameoff
                end
endcase
;
out.sideband=byte(in.sideband)
out.data_points=n_elements(in.data)
out.data=in.data
;
out.yunits=byte('K')
out.ytype =byte('TA')
;
return
end

