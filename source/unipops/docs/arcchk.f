      program arcchk
      character*16 h0(394)
      real*4  d0(256)
      open(unit=11,file='../epav/nsaves.arc',status='old')
 300  format(a16)
 301  format(1pe13.6)
 302  format(i5,5a16)
      open(unit=12,file='../epav/arclog.chk')
      do i=1,  6000
         read(11,300,end=99) (h0(j),j=1, 394)
         write(12,302) i,h0(7),h0(13),h0(230),h0(231),h0(235)
         write(6,302) i,h0(7),h0(13),h0(230),h0(231),h0(235)
         read(11,301,end=98) (d0(j),j=1,256) 
         enddo
 98   write(6,*) 'EOF data'
      stop
 99   write(6,*) 'EOF Header'
      stop
      end
