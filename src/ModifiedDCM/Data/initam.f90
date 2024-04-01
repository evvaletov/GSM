
  subroutine initam( )

! ====================================================================
!
! Initializes several common blocks and calls to setup constants/decay table
!
! ====================================================================

    use, intrinsic:: iso_fortran_env, only: int32, real64

    implicit none
    logical :: lprnt

! ====================================================================

    logical ::    nodcay,noeta,nopi0,nonunu,noevol,nohadr,noka0
    common/nodcay/nodcay,noeta,nopi0,nonunu,noevol,nohadr,noka0
    integer(int32) :: itdky, itevt, itcom, itlis
    common/itapes/itdky,itevt,itcom,itlis
    logical iprint
    common/prints/iprint
    logical notre
    common/notre/ notre
    real(real64) :: enbou
    common/comenb/ enbou
    integer(int32) :: icms
    common/comfr/  icms
    logical yesela
    common/yesela/ yesela
    logical keyhh
    common/keyhh/ keyhh
    logical keypla
    common/keypla/ keypla
    logical qsee,qvsee
    common/comqse/ qsee,qvsee
    integer(int32) :: inside
    common/cinsid/ inside
    integer(int32) :: ivalon
    common/cvalon/ ivalon
    logical wtime
    common/comwti/ wtime
    integer(int32) :: iorhei
    common/iorhei/ iorhei
    integer(int32) :: isob3
    common/isob3/ isob3

! ====================================================================

    itcom=15
    itlis=16
    itevt=17
    itdky=18
    nodcay=.false.
    notre=.false.
    lprnt=.false.
!    LPRNT=.TRUE.
    iprint=.false.
    yesela=.false.
    keyhh=.false.
    keypla=.false.
    qsee=.false.
    qvsee=.false.
!    WTIME=.TRUE.
    wtime=.false.
    enbou= 4.4
    inside=0
    ivalon=0
    iorhei=1
    isob3=1

    ! IF LAB. FRAME
    ICMS=0
    ! IF  C.M. FRAME
    icms=1

    call setcon
    call setdky(lprnt)
    return
! ====================================================================
  end subroutine initam


  subroutine setcon

! ====================================================================
!
! THIS SUBROUTINE SETS THE CONSTANTS IN /CONST/.
!
! ====================================================================

    use, intrinsic:: iso_fortran_env, only: int32, real64

    implicit none

! ====================================================================

!    COMMON/ITAPES/ITDKY,ITEVT,ITCOM,ITLIS
    real(real64) :: pi, sqrt2, alf, gf, units
    common/const/pi,sqrt2,alf,gf,units

! ====================================================================

    pi    = 4.*atan(1.0d0)
    sqrt2 = sqrt(2.0d0)
    alf   = 1./137.036
    gf    = 1.16570d-5
    units = 1./2.56815

    return
! ====================================================================
  end subroutine setcon


  subroutine setdky(lprint)

! ====================================================================
!
!          THIS SUBROUTINE READS IN THE DECAY TABLE FROM TAPE ITDKY
!          AND SETS UP /DKYTAB/.
!          QUARK-BASED IDENT CODE
!
! ====================================================================

    use, intrinsic:: iso_fortran_env, only: int32, real64

    implicit none
    logical, intent(in   ) :: lprint

    integer(int32) :: i, ifl1, ifl2, ifl3, index, iold, ires, itype, &
         & jspin, k, loop
    real(real64)   :: br
    character(len=8) :: lread(10),lmode(6),lres

    integer(int32), dimension(6) :: imode

! ====================================================================

    character(len=*), parameter :: &
         & iquit = " end", &
         & iblank = "     "

! ====================================================================

    integer(int32) :: itdky, itevt, itcom, itlis
    common/itapes/itdky,itevt,itcom,itlis
    integer(int32) :: nforce, iforce, mforce
    common/force/nforce,iforce(20),mforce(5,20)
    ! LOOK MUST BE DIMENSIONED TO THE MAXIMUM VALUE OF INDEX
    integer(int32) :: look, mode
    real(real64)   :: cbr
    common/dkytab/look(400),cbr(600),mode(5,600)
    logical ::    nodcay,noeta,nopi0,nonunu,noevol,nohadr,noka0
    common/nodcay/nodcay,noeta,nopi0,nonunu,noevol,nohadr,noka0

! ====================================================================

    if(lprint) write(itlis,10)
10  format(1h1,30(1h*)/2h *,28x,1h*/ &
         & 2h *,5x,17hcolli decay table,5x,1h*/ &
         & 2h *,28x,1h*/1x,30(1h*)// &
         & 6x,4hpart,18x,10hdecay mode,19x,6hcum br,15x,5hident,17x, &
         & 11hdecay ident/)
    loop=0
    iold=0
    do i = 1, 400
       look(i) = 0
    enddo
    if(nodcay) return
    if (decayUnit /= -1) then
        rewind decayUnit
    endif

200 loop=loop+1
    if(loop > 600) go to 9999
! 220 continue
    do i = 1,5
       imode(i)=0
       lmode(i)=iblank
    enddo

! Reading file ITDKY
    ! (check if file associated with an open unit)
    ! (NOTE: decayUnit == -1 if file NOT opened)
    inquire(file = effectiveDecayFile, &
         & number = decayUnit)

    ! Open file (not connected to any other unit)
    if (decayUnit == -1_int32) &
         & open(newunit = decayUnit, &
         & file = effectiveDecayFile, &
         & status = "old", action = "read")
    read(decayUnit,*,end=300) ires,itype,br,(imode(i),i=1,5)
    if(ires == 0) go to 300
!     IF(NOPI0.AND.IRES.EQ.110) GO TO 220
!     IF(NOETA.AND.IRES.EQ.220) GO TO 220
    if(ires == iold) go to 230
    call flavor(ires,ifl1,ifl2,ifl3,jspin,index)
    look(index)=loop
230 iold=ires
    cbr(loop)=br
    do i=1,5
       mode(i,loop)=imode(i)
       if(imode(i).ne.0) call label(lmode(i),imode(i))
    enddo
    call label(lres,ires)
    if(lprint) write(itlis,20) lres,(lmode(k),k=1,5), &
         & br,ires,(imode(k),k=1,5)
20  format(6x,a5,6x,5(a5,2x),3x,f8.5,15x,i5,4x,5(i5,2x))
    go to 200
!          SET FORCED DECAY MODES
300 if(nforce == 0) go to 400
    do i=1,nforce
       loop=loop+1
       if(loop > 600) go to 9999
       call flavor(iforce(i),ifl1,ifl2,ifl3,jspin,index)
       look(index)=loop
       do k = 1,5
          mode(k,loop)=mforce(k,i)
       enddo
       cbr(loop)=1.
    enddo

!  READ AND PRINT NOTES FROM DECAYTABLE FILE
400 if(lprint) then
410    read(decayUnit,1002,end=9998) lread
1002   format(10a8)
       if(lread(1) == iquit) go to 9998
       write(itlis,1003) lread
1003   format(1x,10a8)
       go to 410
    end if

    close(decayUnit)
9998 return

9999 write(itlis,30)
30  format(//44h ***** error in setdky ... loop.GT.600 *****)
    close(decayUnit)
    return
! ====================================================================
  end subroutine setdky
