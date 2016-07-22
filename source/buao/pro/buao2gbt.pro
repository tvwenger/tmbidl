;+
;
;   buao2gbt.pro   Convert the BUAO HI structure into the internal
;   ------------   GBT data structure {gbt_data} 
;                  Does this on a record by record basis at present
;                      'in' is BUAO       data structure input dat[]
;                      rec  is BUAO data record number -> scan #
;                      hor  is horizontal offest in deltahor units
;                      ver  is vertical   offset in deltaver units
;
;                     'out' is {gbt_data} data structure output 
;                  
;-
pro buao2gbt,rec,hor,ver,in,out
;
out.observer=byte('Bania')
out.obsid=byte('HI Survey')
out.scan_num=rec               ;  BUAO record number in DA file 
out.last_on =in.nspectra       ;  = 1 if there is data here
out.last_off=in.dscan[0]       ;  original AO scan# dddy###
out.procseqn=long(in.epoch[0]) ;  observing epoch 
out.procsize=long(in.drec[0])  ;  some sort of record counter ?
out.line_id=byte('HI')
out.pol_id=byte('LIN') 
gl=in.gl & gb=in.gb &
out.l_gal=gl
out.b_gal=gb
out.hor_offset=double(hor)
out.ver_offset=double(ver)
type=fstring(in.gl,'(f5.2)')+fstring(in.gb,'(f5.2)')
type=strtrim(type,2)
out.scan_type=byte('BUAO')
out.source=byte(type)
out.date=byte('Boston University HI Survey')
;out.frontend=byte(in.frontend)
ra=0.d & dec=0.d &
glactc,ra,dec,2000.,gl,gb,2,/degree
out.ra=ra
out.dec=dec
out.lst=ra*240.d
;out.az=in.azimuth
out.el=90.0d - double(in.dza[0])        ;  from Zenith Angle
out.vel=0.00d
freq=1420.4058d+6               ;  rest freq in Hz
out.rest_freq=freq
out.sky_freq=freq
;out.freqoff=in.foffref1
out.ref_ch=341.d
dfx=-(0.51529d/!light_c)*freq   ;  delta freq of x-axis in Hz
out.delta_x=dfx
out.vel_def=byte('LSR')
;out.vframe=in.vframe
;out.rvsys=in.rvsys
out.bw=-dfx*double(n_elements(in.data))
ton=double(in.dtson[0]) & toff=double(in.dtsoff[0]) &
out.tsys=(ton+toff)/2.d
out.tsys_on  = ton
out.tsys_off = toff
out.tcal=double(in.dtcal[0])
out.tintg=double(in.dtintg[0])
;out.feed=in.feed
out.srfeed=double(in.wtot)               ; total weight
out.beamxoff=double(in.weight[0])        ; weight factor?
out.beameoff=double(in.fact[0])          ; ???
out.sideband=byte(' ')
out.data_points=n_elements(in.data)
out.data=in.data
;
return
end

