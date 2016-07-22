;
;   survey.pro   plot BUAO HI Survey coverage
;
pro survey
;
on_error,2
;
lgal=fltarr(200000)
bgal=fltarr(200000)
;file='/idl/idl/buao/data/buao_survey.gbt'
;openr,lun,file,/get_lun
;
kount=0L
for i=0, (!n_hor*!n_ver-1) do begin
    get,i
    if (!b[0].last_on eq 1L) then begin
       lgal(kount)=!b[0].l_gal
       bgal(kount)=!b[0].b_gal
       kount=kount+1
    end
endfor
print,'kount= ',kount
;
lgal=lgal[0:kount-1]
bgal=bgal[0:kount-1]
erase
syms,1,1,1  ; circle
plot,lgal,bgal,psym=8,$
     title='Boston University Galactic HI Survey Coverage',$
     xtitle='Galactic Longitude (deg)',$
     ytitle='Galactic Latitude (deg)',$
     xrange=[30.0,61.0],$
     yrange=[0.5,-0.5],$
     /xstyle,/ystyle
;
;free_lun
return
end

