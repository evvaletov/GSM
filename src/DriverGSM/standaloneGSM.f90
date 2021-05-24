
! ======================================================================
!
! This file contains the driver information to setup the GSM object
! and start a simulation
!
! ======================================================================

module standaloneGSM

  implicit none
  private

  character(LEN=*), public, parameter :: defaultGSMInputName = "gsm1.inp"

  public  :: gsmDriver
  private :: parseCommands
  private :: validateCommands
  private :: printHelp
  private :: readInput

contains

  ! Main routine to access:
  include "gsmDriver.f90"   ! Interfaces to the "readInput" procedure
  include "parseCommands.f90"
  include "validateCommands.f90"
  include "printHelp.f90"
  include "readInput.f90"

end module standaloneGSM
