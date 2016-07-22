;+
;
;   recombAll.pro  Flag C, N and O recombination lines 
;   -------        for dn=0 to nMax, plus show stronger H, He lines
;
;                  Written by G. Langston March 2004
;-
pro recombAll,nMax
;
on_error,!debug ? 0 : 2
if keyword_set(nMax) then nMax = nMax else nMax = 4
if nMax lt 1 then nMax = 1

; show one higher level of hydrogen
for dn = 1,nMax+2 do recombH,dn
for dn = 1,nMax+1 do recombHe,dn
for dn = 1,nMax do recombC,dn
for dn = 1,nMax do recombN,dn
for dn = 1,nMax do recombO,dn
;
return
end
