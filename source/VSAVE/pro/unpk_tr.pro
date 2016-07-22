;
;   unpk_tr.pro     Transfers values from !tr_rec to system variables
;                   
;
;                  Syntax: unpk_tr
;
pro unpk_tr
;
on_error,!debug ? 0 : 2
compile_opt idl2
print,'unpacking tr:',+strtrim(string(!tr_rec.trans),2)
;  set the variables in tr_rec
!trans=strtrim(string(!tr_rec.trans),2)
!band=strtrim(string(!tr_rec.band),2)
!ngauss=!tr_rec.ngauss
!bgauss=!tr_rec.bgauss
!egauss=!tr_rec.egauss
for i=0,!ngauss-1 do begin
                  !a_gauss[i*3+0]=!b[0].data[round(!tr_rec.cen[i])]
                  !a_gauss[i*3+1]=!tr_rec.cen[i]
                  !a_gauss[i*3+2]=!tr_rec.fwhm[i]
               end
!nfit=!tr_rec.nfit
!nrset=!tr_rec.nrset
!x.range=!tr_rec.xrange
!nregion[0:15]=!tr_rec.sregion
;
return
end
