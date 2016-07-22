pro add_pol,ns1
for irx=1,8 do begin
    getns,ns1
    accum
    getns,ns1+1
    accum
    ave
    !b[0].pol_id = byte('R+L')
    xxf
    lastns=ns1+2
    print,'Save in NSAVE= '+fstring(lastns,'(i4)')+' ? (y or n)'  
    ans=get_kbrd(1)
    if ans eq 'y' then begin
        putavns,lastns
    end
    ns1=ns1+3
end
return
end
