;+
;NAME:
;
;   ao2gbt.pro   Convert the Arecibo {corget} data structure into 
;   ----------   the GBT data structure {gbt_data} 
;                Does this on a record by record basis at present
;                      'in'  is {corget}   data structure input 
;                     'out'  is {gbt_data} data structure output 
;                   'nboard' is the number of the subcorrelator boards (tunings)
;                     'npol' is the number of polarizations sampled
;
; T.M. Bania June 2005
;-
pro ao2gbt,nboard,npol,in,out
;
on_error,!debug ? 0 : 2
;
out.source=in.(nboard).h.proc.srcname
out.observer=byte('3-Helium')
out.obsid=byte('A1804')
out.scan_num=in.(nboard).h.std.scannumber
;out.last_on =in.laston
;out.last_off=in.lastoff
;out.procseqn=in.procseqn
;out.procsize=in.procsize
out.line_id=byte('test')
; get the polarization ID -- the Stokes parameter of the data.
pol=-2L
case (pol) of
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
;  get the scan type
;
type=scantype(in.(nboard).h)
case (type) of
                     0: out.scan_type=byte('UNKNOWN')
                     1: out.scan_type=byte('CALON')
                     2: out.scan_type=byte('CALOFF')
                     3: out.scan_type=byte('ON')
                     4: out.scan_type=byte('OFF')
                  else: begin
                        out.scan_type=byte('UNKNOWN')
                        print,'Scan Type Unknown'
                        end
                endcase
;

out.lst=in.(nboard).h.pnt.r.lastRD*!radeg/15.d  ; LST in hrs, comes originally as radians
out.lst=out.lst*3600.d                      ;     in sec
out.frontend=byte('Xband')
;
az=in.(nboard).h.std.azttd*.0001D   ; Az in deg
za=in.(nboard).h.std.grttd*.0001D   ; ZA in deg 
el=90.D - za                     ; elevation in deg
;
tm=in.(nboard).h.std.postmms*.001D
dayno=in.(nboard).h.std.date mod 1000 + tm/86400D
year =in.(nboard).h.std.date / 1000
;
out.ra= in.(nboard).h.pnt.r.raJCumRd*!radeg 
out.dec=in.(nboard).h.pnt.r.decJCumRd*!radeg
out.az=az
out.el=el
;
out.date=byte(string(dayno)+' '+string(year))
;
out.rest_freq=in.(nboard).h.dop.freqBCRest  ; band center freq. in MHz
out.sky_freq=out.rest_freq + in.(nboard).h.dop.freqoffsets[0] 
out.rest_freq=out.rest_freq*1.D+6      ;                   in Hz
out.sky_freq=out.sky_freq*1.D+6      
;out.freqoff=in.foffref1  ; this is for frequency switching
out.bw=100.D/(2^in.(nboard).h.cor.bwnum)   ; observed bandwidth in MHz
out.bw=out.bw*1.d+6                  ;                    in Hz 
;
out.ref_ch=!data_points/2
out.delta_x=out.bw/double(!data_points)
;
out.vel=in.(nboard).h.dop.velorz         ; source velocity in km/s 
out.vel=out.vel*1.d+3               ;                     m/s
;out.vel_def=byte(in.veldef)
;out.vframe=in.vframe
out.rvsys=in.(nboard).h.dop.velObsProj*1.d+3  ; proj. los velocity in m/s
;
; Do Tsys and cals outside this proc using  't' and 'cals' 
;
out.tintg=in.(nboard).h.proc.iar[0]
;
; do not need these below
;out.feed=in.feed
;out.srfeed=in.srfeed
;out.beamxoff=in.beamxoff
;out.beameoff=in.beameoff
;out.sideband=byte(in.sideband)
;
out.data_points=!data_points
;
out.data=in.(nboard).d[*,npol]   ; one polarization 
;
return
end

