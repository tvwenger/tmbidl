pro zero,xmin,xmax,help=help,no_ask=no_ask
;+
; NAME:
;       ZERO
;
;            ==============================================
;            Syntax: ZERO,xmin,xmax,help=help,no_ask=no_ask
;            ==============================================
;
;  zero  Set data values to zero between specified x-axis range
;  ----  If no parameters then gets range from cursor
;
;  KEYWORDS:  /help     gives help
;             /no_ask   does not ask before range is zeroed.
;

;-
; V6.1 24may2012 tmb 
;      18july2012 tvw - fix feature where array index was backwards
;
; v7.0 15may2013 tmb added !debug and merged to v7.0 
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
@CT_IN
;
if KeyWord_Set(help) then begin & get_help,'zero' & return & end
;
!last_x=!x.range            ; remember current scaling
cursor = !cursor            ; remember cursor setting
;
if n_params() eq 0 then begin
    !cursor=1
    ccc,xpos,ypos & xmin=xpos
    ccc,xpos,ypos & xmax=xpos
end
;
idchan,xmin,chmin & idchan,xmax,chmax
;
if KeyWord_Set(no_ask) then goto,do_it  ; for batch processing 
;
flag,xmin & flag,xmax
;
print
print,'Zero values in this range?   y = YES anything else means NO'
pause,cans,ians
;
if cans ne 'y' then goto,flush
;
do_it:
; zero the values 
;
;!b[0].data[chmin:chmax]=0.0 ; v6.1
if chmin gt chmax then !b[0].data[chmax:chmin]=0.0 else $
                       !b[0].data[chmin:chmax]=0.0
;
flush:
;
; return cursor to previous state
!cursor = cursor
@CT_OUT
;
return
end

