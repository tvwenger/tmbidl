pro fixhi,rec1,rec2,help=help
;+
; fixhi,rec1,rec2,help=help
;
;   fixhi.pro  Fixes bad Tsys in o04 D1 data   
;   ---------  Routine works in VELO and CHAN 
;              At present, do NOT remove a baseline in VELO
;              since channels then run backwards.
;              In VELO mode !nregion=0.
;               Syntax: fixhi,rec1,rec2
;                       rec1 = d1 record 12min scan  -- LOW cal <- bad data
;                       rec2 = d2 record 1 min scan with large cal
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
if (n_params() ne 2) or  keyword_set(help) then begin & get_help,'fixhi' & return & endif
; 
flag=!flag
!flag=0           ; gturn off annotation
;
; Will only be used o04; don't sweat formats etc
ans=' '
;
get,rec1
xx
print,'continue? (y for yes)' 
read,ans
if (ans ne 'y') then return
copy,0,1
area,tpk1,area1
get,rec2
xx
print,'continue? (y for yes)'
read,ans
if (ans ne 'y') then return
copy,0,2
area,tpk2,area2
;
tsys1_off=!b[1].tsys_off
tsys2_off=!b[2].tsys_off
tsys1=!b[1].tsys
tsys2=!b[2].tsys
tsys1_on=!b[1].tsys_on
tsys2_on=!b[2].tsys_on
factT=tsys2_off/tsys1_off
factA=area2/area1
!fact=factA
copy,1,0
!b[0].tsys_off=tsys2_off
!b[0].tsys_on=tsys2_on
!b[0].tsys=tsys2
scale
reshow
print,'Tsys1=',tsys1,' Tsys2=',tsys2,' Ratio=',factT
print,'Area1=',area1,' Area2=',area2,' Ratio=',factA
print,'continue? (y for yes)' 
read,ans
if (ans ne 'y') then return
accum
copy,2,0
accum
ave
xx
;
!flag=flag           ;  return to original state
return
end
