program decayInitialization
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use modifiedDCMData, only: initializeModifiedDCMData
  implicit none

  character(len=1024) :: dataDir
  character(len=16) :: line
  integer :: unit
  integer(int32) :: look(400), mode(5,600), expectedLook(400)
  real(real64) :: cbr(600), expectedFirstBranch
  common /dkytab/ look, cbr, mode

  call get_command_argument(1, dataDir)
  if (len_trim(dataDir) == 0) stop 1
  call initialize()
  if (all(look == 0)) stop 2
  expectedLook = look
  expectedFirstBranch = cbr(1)
  print *, 'initial load passed'

  call initialize()
  call checkTable()
  print *, 'repeated load passed'

  open(newunit=unit, file=trim(dataDir)//'/atab.dat', status='old', action='read')
  read(unit,*)
  call initialize()
  call checkTable()
  print *, 'pre-opened file passed'

  ! The runtime can reuse the closed decay unit for an unrelated file.
  open(newunit=unit, status='scratch', action='readwrite')
  write(unit,'(a)') 'first'
  write(unit,'(a)') 'second'
  rewind unit
  read(unit,'(a)') line
  call initialize()
  call checkTable()
  read(unit,'(a)') line
  if (trim(line) /= 'second') stop 3
  close(unit)
  print *, 'unrelated file position preserved'

contains

  subroutine initialize()
    call initializeModifiedDCMData( &
         clientPhotoFile=trim(dataDir)//'/channel1.tab', &
         clientDecayFile=trim(dataDir)//'/atab.dat')
  end subroutine initialize

  subroutine checkTable()
    if (any(look /= expectedLook)) stop 4
    if (cbr(1) /= expectedFirstBranch) stop 5
  end subroutine checkTable
end program decayInitialization
