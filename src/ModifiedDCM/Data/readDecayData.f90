
  subroutine setdky(printStatus)

! ====================================================================
!
!          THIS SUBROUTINE READS IN THE DECAY TABLE FROM TAPE ITDKY
!          AND SETS UP /DKYTAB/.
!          QUARK-BASED IDENT CODE
!
! ====================================================================

    use, intrinsic:: iso_fortran_env, only: int32, real64, &
        & output_unit, error_unit

    implicit none
    logical, intent(in   ) :: printStatus

    integer(int32) :: i, ifl1, ifl2, ifl3, index, iold, ires, itype, &
         & jspin, k, loop
    real(real64)   :: br
    character(len=8) :: lread(10),lmode(6),lres

    integer(int32), dimension(6) :: imode

! ====================================================================

    character(len=*), parameter :: &
         & iquit = " end", &
         & iblank = "     "
     integer(int32) :: rc

! ====================================================================

    integer(int32) :: nforce, iforce, mforce
    common/force/nforce,iforce(20),mforce(5,20)
    ! LOOK MUST BE DIMENSIONED TO THE MAXIMUM VALUE OF INDEX
    integer(int32) :: look, mode
    real(real64)   :: cbr
    common/dkytab/look(400),cbr(600),mode(5,600)

! ====================================================================

    if(printStatus) write(output_unit,10)
    loop=0
    iold=0
    do i = 1, 400
       look(i) = 0
    enddo
    if(.not. model_decay) return
    rewind decayUnit

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
         & status = "old", action = "read", iostat = rc)
     if (rc /= 0) then
         write(error_unit, "(A)") "Error: Failed to open file " // &
             & effectiveDecayFile
         stop
     end if

    read(decayUnit, *, iostat = rc, end = 300) ires,itype,br,(imode(i),i=1,5)
    if (rc /= 0) then
        write(error_unit, "(A)") "Error: Failed to read file " // &
            & effectiveDecayFile
        stop
    end if

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
    if(printStatus) write(output_unit,20) lres,(lmode(k),k=1,5), &
         & br,ires,(imode(k),k=1,5)
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
400 if(printStatus) then
410    read(decayUnit,1002,end=9998) lread
       if(lread(1) == iquit) go to 9998
       write(output_unit,1003) lread
       go to 410
    end if

    close(decayUnit)
9998 return

9999 write(output_unit,30)
    close(decayUnit)
    return
! ====================================================================
10  format(1h1,30(1h*)/2h *,28x,1h*/ &
         & 2h *,5x,17hcolli decay table,5x,1h*/ &
         & 2h *,28x,1h*/1x,30(1h*)// &
         & 6x,4hpart,18x,10hdecay mode,19x,6hcum br,15x,5hident,17x, &
         & 11hdecay ident/)
20  format(6x,a5,6x,5(a5,2x),3x,f8.5,15x,i5,4x,5(i5,2x))
30  format(//44h ***** error in setdky ... loop.GT.600 *****)
1002   format(10a8)
1003   format(1x,10a8)
! ====================================================================
  end subroutine setdky
