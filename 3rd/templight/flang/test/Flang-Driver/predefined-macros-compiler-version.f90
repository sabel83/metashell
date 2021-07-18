! Check that the driver correctly defines macros with the compiler version

! REQUIRES: new-flang-driver

!--------------------------
! FLANG DRIVER (flang-new)
!--------------------------
! RUN: %flang-new -E %s  2>&1 | FileCheck %s --ignore-case

!-----------------------------------------
! FRONTEND FLANG DRIVER (flang-new -fc1)
!-----------------------------------------
! RUN: %flang-new -fc1 -E %s  2>&1 | FileCheck %s --ignore-case

!-----------------
! EXPECTED OUTPUT
!-----------------
! CHECK: flang = 1
! CHECK: flang_major = {{[1-9][0-9]*$}}
! CHECK: flang_minor = {{[0-9]+$}}
! CHECK: flang_patchlevel = {{[0-9]+$}}

integer, parameter :: flang = __flang__
integer, parameter :: flang_major = __flang_major__
integer, parameter :: flang_minor = __flang_minor__
integer, parameter :: flang_patchlevel = __flang_patchlevel__
