;+
; NAME:
;       sky_freq
;
;            ======================================
;            Syntax: sky_freq, chan
;            ======================================
;
;   sky_freq Gives sky frequency of channel chan
;   ----     if chan is omitted, invokes cursur  
;         
;
; From V5.0 July 2007
; RTR  8/08
;-
pro sky_freq
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 then begin
    print,'Click cursor on feature'
    ccc,xpos,ypos
    idchan,xpos,xchan
    chan=!xx[xchan]
end
;
fsky_cen=!b[0].sky_freq/1.0e+06                     ; sky freq MHz
ch_cen=!b[0].ref_ch
delta=!b[0].delta_x/1.0e+06
dch=chan-ch_cen
df=dch*delta
fsky=fsky_cen+df
print,'Sky Frequency =',fsky,' MHz'
;
return
end
