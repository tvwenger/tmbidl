;+
;   buao_survey.pro   Defines parameters of BUAO HI Survey
;   ---------------   Survey already translated into {gbt_data} format
; 
;-
pro buao_survey
;
on_error,2
;
print
print,'Defined BUAO map global variables'
print
@buao_globals   ;  Define the BUAO survey parameters and set globals
;
!kount=!n_hor*!n_ver
print
print,!datafile + ' Contains ' + fstring(!kount,'(i6)') + ' records '
print
;
!data_points=681L
print,'Each spectrum has '+fstring(!data_points,'(I6)')+' data points'
;
!nchan=!data_points
;
return
end


