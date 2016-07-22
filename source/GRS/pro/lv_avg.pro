;+
;   lv_avg   Takes input l_gal_min,l_gal_max and makes a file of GRS
;   ------   spectra averaged over the entire GRS b_gal range at
;            that position.
;            Each spectrum has the GRS beam convolved with
;            adjacent data. hardwired for T_main_beam
;             
;   Syntax:  lv_avg,l_gal_min,l_gal_max
;   ===================================                                 
;                   l_gal in degrees
;
; V5.0 July 2007
; written 14 Aug by tmb 
;
;-
pro lv_avg,l_min,l_max
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
if N_params() eq 0 then begin
    print,'lv_avg'
    print,'Plots a (l_gal,v_lsr) contour map at fixed b_gal'
    print,''
    print,'*******************************************************************'
    print,'SYNTAX:   lv_avg,l_gal_min,l_gal_max'
    print
    print,'          input l_gal in degrees'
    print
    print,'*******************************************************************'
    return
endif
;
fname='/drang/data/LVmap.dat'
openw,lun,fname,/get_lun
close,lun
;
nlong=ceil((l_max-l_min)/!grsSpacing)
print,'number of records is ',nlong
;
idx=0
openu,lun,fname,/append
;
for l_gal=l_min,l_max,!grsSpacing do begin  
    l_gal=l_min+float(!grsSpacing*idx)
    b_avg,l_gal
    smo,3
    rec=!b[0]
;
    lgal=rec.l_gal
    bgal=rec.b_gal
;
    print,lgal,bgal
    writeu,lun,rec
;
    idx=idx+1
endfor
;
close,lun
;
return
end
