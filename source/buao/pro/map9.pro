pro map9,nrec,help=help
;+
; NAME:
;       MAP9
;
;   map9    Fetch and overplot the 8 nearest neighbor spectra
;   ----    to input spectrum specified by its NREC position. 
;
;
;-
; MODIFICAION HISTORY
; v7.0 12jul2013 tmb - based on v3.2 original 
;
;-
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'map9' & return & endif

;
;
get,nrec
print,!b[0].l_gal,!b[0].b_gal
yellow=!yellow
cyan=!cyan
magenta=!magenta
;
rec=!b[0].scan_num
map_pos=intarr(9)
map_pos[0]=rec
map_pos[1]=rec-1L
map_pos[2]=rec+1L
map_pos[3]=rec-!n_ver
map_pos[4]=rec+!n_ver
map_pos[5]=rec-!n_ver-1L
map_pos[6]=rec-!n_ver+1L
map_pos[7]=rec+!n_ver-1L
map_pos[8]=rec+!n_ver+1L
;
yellow=!yellow
for i=1,8 do begin
    get,map_pos[i]
    print,!b[0].l_gal,!b[0].b_gal
    reshow,color=magenta
endfor
;
return
end

