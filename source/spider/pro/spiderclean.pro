pro spiderclean,help=help,no_baseline=no_baseline,cuttoff=cutoff
;+
; NAME:
;       spiderclean
;
;            ========================================================
;            Syntax: spiderclean,help=help,/no_baseline,cutoff=cutoff
;            ========================================================
;
;   spiderclean  procedure to 
;   -----------  fit nregions, baseline, and gaussian to spider scan
;                data
;
;                ** requires stack to be filled with (L+R) *_AVG data
;                puts new ns starting at !lastns
;
;   KEYWORDS:
;              HELP - get syntax help
;              NO_BASELINE - don't fit baseline
;              CUTOFF - cutoff range (default [0,15,575,588])
;
; MODIFICATION HISTORY:
;
; V1.0 TVW 18june2012
;          02july2012 - shows image and contours
;      dsb 15oct2012  - remove datapath from cmapvgps (i.e., use default)
;                       modify to use dsb version of bb
;      dsb 19nov2012  - change edge cuttoff range
;      dsb 20nov2012  - add keyword for cutoff range
;                       add setx before baseline fit
;                       allow user to redo gg
;-
on_error,2        ; on error return to top level
compile_opt idl2  ; compile with long integers 
;
if keyword_set(help) then begin
   get_help,'spiderclean'
   return
endif
if (n_elements(cutoff) eq 0) then cutoff=[0,15,575,588]
;
acount=!acount
stack=!astack
;
;
for i=0,acount-1 do begin
   getns,stack[i]
   ;
   cmapvgps,!b[0].l_gal,!b[0].b_gal,size=80.,/peak,/spider,length=80.
   ;
   type=string(!b[0].scan_type)
   ;
   cans='n'
   while cans eq 'n' do begin
      getns,stack[i]
      chan
      ; cut off edges
      zero,cutoff[0],cutoff[1],/no_ask
      zero,cutoff[2],cutoff[3],/no_ask
      case type of
         "RA_AVG" : raxx
         "CC_AVG" : raxx
         "DEC_AVG" : decx
         "CW_AVG" : decx
     endcase
      print, 'Set the x-axis with the cursor'
      freexy & xx & setx
      xx
      ; 
      ymax=max(!b[0].data[0:588])
      ;print,"max in data is ",ymax
      ymax+=0.1*ymax
      ;print,"Ymax is ",ymax
      ymin=min(!b[0].data[0:588])
      ymin-=0.1*ymax
      ;print,"Ymin is ",ymin
      sety,ymin,ymax
      ;setx,16,max(!xx)-16
      nroff
      xx
      if ~keyword_set(no_baseline) then begin
         ;read,num,prompt="How many regions?"
         ;nrset,num
         read,num,prompt="How many baseline parameters?"
         bb,num
         nron
         chan
         ; cut off edges
         zero,cutoff[0],cutoff[1],/no_ask
         zero,cutoff[2],cutoff[3],/no_ask
         case type of
            "RA_AVG" : raxx
            "CC_AVG" : raxx
            "DEC_AVG" : decx
            "CW_AVG" : decx
         endcase
         freexy
         xx
         print,'Ok? (y/n/q)'
         pause,cans,ians
         !b[0].scan_type=bytarr(32)
         !b[0].scan_type=byte(strmid(type,0,3)+" B G")
         if cans eq 'q' then return
      endif else begin 
         cans='y'
         !b[0].scan_type=bytarr(32)
         !b[0].scan_type=byte(strmid(type,0,3)+" G")
         nrset,1,[0,0]
      endelse
   endwhile
   ;
   nron
   gans='n'
   while gans eq 'n' do begin
       xx
       gg,1
       print,'Ok? (y/n/q)'
       xx & g & read,gans
       if gans eq 'q' then return
   endwhile
   ;   
   nsoff
   
   history
   putns,!lastns+1
   nson
   ;
   ++!lastns
endfor
;
return
end
