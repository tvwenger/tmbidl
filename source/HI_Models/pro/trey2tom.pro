;===============================================================
; Batch script to translate Trey's code into TMBIDL structure
;===============================================================
; use !rec and !blkrec structures to make the translation
;              !blkrec flagis initialized to zero
;
!rec=!blkrec ; make sure that !rec is initialized
;
; pass the intensities
;
npts=n_vel
!rec.s_pts=npts
!rec.data[0:npts-1]=spect
!rec.ytype=byte('TB')
;
; pack info on the model parameters
;
sname=' '
gname,lgal,bgal,src=sname
!rec.source=byte(sname)

!rec.vel=0.
!rec.pol_id=byte(' H I')
;
; Annotate based on properties of the model 
;
percc=textoidl(' cm^{-3}')
kms=textoidl(' km s^{-1}')
maxr=textoidl('R_{max}')
tspin=textoidl('T_{s}')
sigma=textoidl('\sigma')
;
test=n_elements(model)
if test eq 1 then begin & den=denlos[0] & temp=tlos[0] & disp=siglos[0] & endif
if test ge 2 then begin & den=model[1]  & temp=model[0] & disp=model[2] & endif
;
label='n='+fstring(den,'(f3.1)')+' '
label=label+tspin+'='+fstring(temp,'(f4.0)')+' '
label=label+sigma+'='+fstring(disp,'(f3.0)')+' '
label=strmid(label,0,32)
;
!rec.line_id=byte(label)
;
mtype='   '
sdisk=' ExpDisk'
sclouds=' Clouds'
sspiral=' Spiral'
sdispgrad='DispGrad'
if  KeyWord_Set(expdisk)  then mtype=mtype+sdisk
if ~KeyWord_Set(noclouds) then mtype=mtype+sclouds
if  KeyWord_Set(smodel)   then mtype=mtype+sspiral
;!rec.scan_type=byte(mtype)
!rec.date=byte(mtype)
;
label=maxr+'='+fstring(rmax,'(f3.0)')+' '
label=label+'dx='+fstring(dx,'(f5.3)')+' '
if KeyWord_Set(dispgrad) then label=label+sdispgrad
label=strmid(label,0,32)
!rec.observer=byte(label)
;
; deal with the frequency axis 
;
!rec.rest_freq=1420.4058d+6
!rec.sky_freq =1420.4058d+6
!rec.ref_ch=!rec.s_pts/2.d
df=(double(dv)/!light_c)*!rec.rest_freq
!rec.delta_x=-df
; 
; This stuff to keep code from bombing with zero divides
;
!rec.tsys=1.
!rec.tcal=1.
;
; copy !rec to !b[0]
;
!b[0]=!rec
;
