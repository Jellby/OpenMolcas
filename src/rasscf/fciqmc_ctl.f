************************************************************************
* This file is part of OpenMolcas.                                     *
*                                                                      *
* OpenMolcas is free software; you can redistribute it and/or modify   *
* it under the terms of the GNU Lesser General Public License, v. 2.1. *
* OpenMolcas is distributed in the hope that it will be useful, but it *
* is provided "as is" and without any express or implied warranties.   *
* For more details see the full text of the license in the file        *
* LICENSE or in <http://www.gnu.org/licenses/>.                        *
************************************************************************
#ifdef _NECI_
      Subroutine FCIQMC_Ctl(CMO,DIAF,DMAT,DSPN,PSMAT,PAMAT,F_IN,D1I,D1A,
     &                      TUVX,IFINAL)
* ***********************************************************
*
*      <Arguments>
*        \Argument{CMO}{MO coefficients}{Real*8 array (NTOT2)}.......................{in}
*        \Argument{DIAF}{DIAGONAL of Fock matrix useful for NECI}{Real*8 array (NTOT)}{in}
*        \Argument{DMAT}{Average 1-dens matrix}{Real*8 array (NACPAR)}...............{out}
*        \Argument{DSPN}{Average spin 1-dens matrix}{Real*8 array (NACPAR)}..........{out}
*        \Argument{PSMAT}{Average symm. 2-dens matrix}{Real*8 array (NACPR2)}........{out}
*        \Argument{PAMAT}{Average antisymm. 2-dens matrix}{Real*8 array (NACPR2)}....{out}
*        \Argument{F_IN}{Fock matrix from inactive density}{Real*8 array (NTOT1)}....{in/out}
*        \Argument{D1I}{Inactive 1-dens matrix}{Real*8 array (NTOT2)}................{inout}
*        \Argument{D1A}{Active 1-dens matrix}{Real*8 array (NTOT2)}..................{inout}
*        \Argument{TUVX}{Active 2-el integrals}{Real*8 array (NACPR2)}...............{in}
*        \Argument{IFINAL}{Calculation status switch}{Integer: 0,1 or 2}.............{in}
*      </Arguments>
*
*      <Purpose> FCIQMC Control </Purpose>
*      <Description>
*
*        Depends on IFINAL, which is set in RASSCF. If IFINAL=0, repeated
*        calculations with orbital optimation before each call. If IFINAL=1,
*        there has been no orbital optimization, or the calculation is
*        converged. IFINAL=2 means this is a final CI calculation, using the
*        final orbitals. For meaning of global variables NTOT1, NTOT2, NACPAR
*        and NACPR2, see src/Include/general.inc and src/Include/rasscf.inc.
*
*        This routine will replace CICTL in FCIQMC regime.
*        Density matrices are generated via double-run procedure in NECI.
*        They are then dumped on arrays DMAT, DSPN, PSMAT, PAMAT to replace
*        what normally would be done in DavCtl if NECI is not used.
*
*        F_In is still generated by SGFCIN... in input contains only two-electron terms as computed in TRA_CTL2. In output it contains also the one-electron contribution
*
*      </Description>
*
      Implicit Real* 8 (A-H,O-Z)
      Real*8 CMO(*),DMAT(*),DSPN(*),PSMAT(*),PAMAT(*),F_In(*),D1I(*),
     &       DIAF(*),D1A(*),TUVX(*)
      Logical Exist,Do_ESPF, WaitForNECI
      Real*8 NECIen
      character answer*1
      Integer LuNewC, ios

#include "rasdim.fh"
#include "rasscf.fh"
#include "general.fh"
#include "gas.fh"
#include "output_ras.fh"
#include "csfbas.fh"
#include "gugx.fh"
#include "WrkSpc.fh"
#include "SysDef.fh"
#include "rctfld.fh"
#include "timers.fh"
#include "wadr.fh"
#include "rasscf_lucia.fh"
#include "pamint.fh"
#include "input_ras.fh"
#include "fciqmc.fh"
#include "para_info.fh"
#ifdef _MOLCAS_MPP_
      Include 'mpif.h'
#include "global.fh"
#include "mafdecls.fh"
      INTEGER*4 ierror
#endif
      Common /IDSXCI/ IDXCI(mxAct),IDXSX(mxAct)

c      Call qEnter('FCIQMC_CTL')

C Local print level (if any)
       IPRLEV=IPRLOC(1)
      IF(IPRLEV.ge.DEBUG) THEN
        Write(LF,*)
        Write(LF,*) ' ===================='
        WRITE(LF,*) ' Entering FCIQMC_Ctl'
        Write(LF,*) ' ===================='
        Write(LF,*)
        Write(LF,*) ' iteration count =',ITER
        Write(LF,*) ' IFCAS value     =',IFCAS
        Write(LF,*) ' lroots,nroots   =',lroots,nroots
        Write(LF,*)
      END IF
* set up flag 'IFCAS' for GAS option, which is set up in gugatcl originally.
* IFCAS = 0: This is a CAS calculation
* IFCAS = 1: This is a RAS calculation
* IFCAS = 2: This is a GAS calculation
      IF(IPRLEV.ge.DEBUG) THEN
        Write(LF,*)
        Write(LF,*) ' CMO in FCIQMC_CTL'
        Write(LF,*) ' ---------------------'
        Write(LF,*)
        ioff=1
        Do iSym = 1,nSym
          iBas = nBas(iSym)
          if(iBas.ne.0) then
            write(6,*) 'Sym =', iSym
            do i= 1,iBas
              write(6,*) (CMO(ioff+iBas*(i-1)+j),j=0,iBas-1)
            end do
            iOff = iOff + (iBas*iBas)
          end if
        End Do
      END IF

* SOME DIRTY SETUPS
*
      S=0.5D0*DBLE(ISPIN-1)
*
**************************************************************************************
**************** FCIQMC not interfaced to State Average CAS         ******************
**************************************************************************************
      IF(lroots.gt.1) then
       write(6,*)' FCIQMC does not support State Average yet!'
       write(6,*)' See you later ;)'
       Call QTrace()
       Call Abend()
      end if
**************************************************************************************
**************** FCIQMC not interfaced to RAS or GAS for now        ******************
**************************************************************************************
c      IF(IFCAS.ge.1) then
c       write(6,*)' FCIQMC does not support RAS or GAS wf yet!'
c       write(6,*)' See you later ;)'
c       Call QTrace()
c       Call Abend()
c      end if
**************************************************************************************
****************             Reaction Field calculation             ******************
**************************************************************************************
      Call DecideOnESPF(Do_ESPF)
      If ( lRf .or. KSDFT.ne.'SCF' .or. Do_ESPF) THEN
       write(6,*)' FCIQMC does not support Reaction Field yet!'
       write(6,*)' See you later ;)'
       Call QTrace()
       Call Abend()
      ELSE
**************************************************************************************
****************                     Normal Case                    ******************
**************************************************************************************
* LW1 : Inactive Fock MATRIX IN MO-BASIS computed via SGFCIN containing both one and two-electron contribution.
* F_In: Inactive Fock MATRIX IN AO-BASIS containing both one and two-electron contribution (latest computed in TRA_CTL2)
c       write(6,*)'ntot1,ntot2,nacpar,nacpr2',ntot1,ntot2,nacpar,nacpr2
        CALL GETMEM('CICTL1','ALLO','REAL',LW1,NACPAR)
        CALL GETMEM('TmpD1S','Allo','REAL',ipTmpD1S,NTOT2 )
        CALL GETMEM('TmpDS' ,'Allo','REAL',ipTmpDS ,NACPAR)
        Call DCopy_(NACPAR,DSPN,1,Work(ipTmpDS),1)
        IF ( NASH(1).NE.NAC ) CALL DBLOCK(Work(ipTmpDS))
        Call Get_D1A_RASSCF(CMO,Work(ipTmpDS),Work(ipTmpD1S))
        CALL GETMEM('TmpDS' ,'Free','REAL',ipTmpDS ,NACPAR)
        CALL SGFCIN(CMO,WORK(LW1),F_In,D1I,D1A,Work(ipTmpD1S))
        CALL GETMEM('TmpD1S','Free','REAL',ipTmpD1S,NTOT2 )
      END IF
**************************************************************************************
*****************              Produce a working FCIDUMP file       ******************
**************************************************************************************
         call make_dump(TUVX,nacpr2,LW1,nacpar,EMY,CMO,DIAF,LuINTA,ITER)
**************************************************************************************
*****************              Produce an INPUT file for NECI       ******************
**************************************************************************************
          call make_inp(ITER,rotmax)
**************************************************************************************
*****************      Run NECI                                     ******************
**************************************************************************************
* In case we wish to dump the FCIDUMP file only we do not need to wait for NECI run.
          if(iDumpOnly) goto 999
          Call Timing(Rado_1,Swatch,Swatch,Swatch)
#ifdef _MOLCAS_MPP_
          IF (Is_Real_Par()) THEN
           call MPI_Barrier(MPI_COMM_WORLD,ierror)
          END IF
#endif

          If(iDoExtNECI) then
            write(6,*)'(1) Run NECI externally using the new FCIDUMP'
            write(6,*)'(2) cp TwoRDM_aaaa.1 into $Project.TwoRDM_aaaa'
            write(6,*)'(3) cp TwoRDM_abab.1 into $Project.TwoRDM_abab'
            write(6,*)'(4) cp TwoRDM_abba.1 into $Project.TwoRDM_abba'
            write(6,*)'(5) cp OneRDM ../$Project.OneRDM'
            write(6,*)'   where $Project is the root of your input file'
            write(6,*)'(6) Type: echo ''your_RDM_Energy'' > NEWCYCLE'
            call xflush(6)
            waitForNECI = .false.
            do while(.not.waitForNECI)
              Call f_Inquire('NEWCYCLE',waitForNECI)
            end do
            write(6, *) 'NEWCYCLE file found. Proceding with SuperCI'
            LuNewC = 12
            call molcas_open(LuNewC,'NEWCYCLE')
c            open(LuNewC, file='NEWCYCLE', status='old',iostat=ios)
c            if (ios.ne.0) then
c              write (6, *) 'Problem opening NEWCYCLE file.'
c              write (6, *) 'Did you forget to create it?'
c              Call QTrace()
c              Call Abend()
c            endif
            read(LuNewC,*) NECIen
            write(6,*) 'I read the following energy:'
            write(6,*) NECIen
            close (LuNewC, status='delete')

c            answer = 'u'
c            do while(answer.eq.'u')
c              write(6,*) 'To continue with SX enter ''y'''
c              write(6,*) 'Otherwise type '' n'' to quit!'
c              read(6,*) answer
c              if (answer.eq.'n') stop 'Job aborted!'
c            end do
          else
#ifndef _EXTNECI_
            write(6,*) 'NECI called automatically within Molcas!'
            call necimain(NECIen)
#endif
          end if
* NECIen so far is only the energy for the GS. Next step it will be an array containing energies
* for all the optimized states.

          Do jRoot = 1,lRoots
            ENER(jRoot,ITER) = NECIen
          End Do
c         write(6,*) 'Iter, ENER in fciqmc_ctl:'
c         write(6,*) Iter, ENER(1,ITER)
**************************************************************************************
*****************        Generate density matrices for Molcas       ******************
**************************************************************************************
* Neci density matrices are stored in Files OneRDM (spin-orbital basis) and
* TwoRDM_**** (in spacial orbital basis). I will be reading them from those
* formatted files for the time being. Next it will be nice if NECI prints them
* out already in Molcas format.
          Zero = 0.0d0
          Call dCopy_(NACPAR,Zero,0,DMAT,1)
          Call dCopy_(NACPAR,Zero,0,DSPN,1)
          Call dCopy_(NACPR2,Zero,0,PSMAT,1)
          Call dCopy_(NACPR2,Zero,0,PAMAT,1)

          CALL GETMEM('Dtmp ','ALLO','REAL',LW6,NACPAR)
          CALL GETMEM('DStmp','ALLO','REAL',LW7,NACPAR)
          CALL GETMEM('Ptmp ','ALLO','REAL',LW8,NACPR2)
          CALL GETMEM('PAtmp','ALLO','REAL',LW9,NACPR2)
* LW6: ONE-BODY DENSITY
* LW7: ONE-BODY SPIN DENSITY
* LW8: SYMMETRIC TWO-BODY DENSITY
* LW9: ANTISYMMETRIC TWO-BODY DENSITY
          Call dCopy_(NACPAR,Zero,0,Work(LW6),1)
          Call dCopy_(NACPAR,Zero,0,Work(LW7),1)
          Call dCopy_(NACPR2,Zero,0,Work(LW8),1)
          Call dCopy_(NACPR2,Zero,0,Work(LW9),1)
#ifdef _MOLCAS_MPP_
          IF (Is_Real_Par()) THEN
            call MPI_Barrier(MPI_COMM_WORLD,ierror)
          END IF
#endif
          call neci2molcas_dens(Work(LW6),Work(LW7),
     &                          Work(LW8),Work(LW9),NACPAR,nactel)
#ifdef _MOLCAS_MPP_
          IF (Is_Real_Par()) THEN
            call MPI_Barrier(MPI_COMM_WORLD,ierror)
          END IF
#endif
c          write(6,*) 'In fciqmc_ctl after neci2molcas'
c          write(6,*) 'DMAT after neci2molcas'
c          write(6,*) (Work(LW6+i),i=0,nacpar-1)
c          write(6,*) 'PSMAT after neci2molcas'
c          write(6,*) (Work(LW8+i),i=0,nacpr2-1)
c          write(6,*) 'PAMAT after neci2molcas'
c          write(6,*) (Work(LW9+i),i=0,nacpr2-1)

      iDisk = IADR15(4)
      jDisk = IADR15(3)
* COMPUTE AVERAGE DENSITY MATRICES
      Do jRoot = 1,lRoots
         Scal = 0.0d0
         Do kRoot = 1,nRoots
           If ( iRoot(kRoot).eq.jRoot ) then
             Scal = Weight(kRoot)
           End If
         End Do
         Call daXpY_(NACPAR,Scal,Work(LW6),1,DMAT,1)
         Call daXpY_(NACPAR,Scal,Work(LW7),1,DSPN,1)
         Call daXpY_(NACPR2,Scal,Work(LW8),1,PSMAT,1)
         Call daXpY_(NACPR2,Scal,Work(LW9),1,PAMAT,1)
* Are next two lines needed?
         Call Put_D1MO(Work(LW6),NACPAR) ! Put it on the RUNFILE
         Call Put_P2MO(Work(LW8),NACPR2) ! Put it on the RUNFILE
* save density matrices on disk
         Call DDafile(JOBIPH,1,Work(LW6),NACPAR,jDisk)
         Call DDafile(JOBIPH,1,Work(LW7),NACPAR,jDisk)
         Call DDafile(JOBIPH,1,Work(LW8),NACPR2,jDisk)
         Call DDafile(JOBIPH,1,Work(LW9),NACPR2,jDisk)
      End Do

      CALL GETMEM('PAtmp','FREE','REAL',LW9,NACPR2)
      CALL GETMEM('Ptmp ','FREE','REAL',LW8,NACPR2)
      CALL GETMEM('DStmp','FREE','REAL',LW7,NACPAR)
      CALL GETMEM('Dtmp ','FREE','REAL',LW6,NACPAR)
c      call MPI_Barrier(MPI_COMM_WORLD,ierror)
c      call MPI_BCast(DMAT,NACPAR,MPI_DBL,0,MPI_COMM_WORLD,ierror)
c      call MPI_BCast(DSPN,NACPAR,MPI_DBL,0,MPI_COMM_WORLD,ierror)
c      call MPI_BCast(PSMAT,NACPR2,MPI_DBL,0,MPI_COMM_WORLD,ierror)
c      call MPI_BCast(PAMAT,NACPR2,MPI_DBL,0,MPI_COMM_WORLD,ierror)
c      call MPI_Barrier(MPI_COMM_WORLD,ierror)
*
* C
* PREPARE DENSITY MATRICES AS USED BY THE SUPER CI SECTION
* C
*
* print matrices
      IF ( IPRLEV.GE.DEBUG  ) THEN
        CALL TRIPRT('Averaged one-body density matrix, DMAT',
     &              ' ',DMAT,NAC)
        CALL TRIPRT('Averaged one-body spin density matrix, DS',
     &              ' ',DSPN,NAC)
        CALL TRIPRT('Averaged two-body density matrix, P',
     &              ' ',PSMAT,NACPAR)
        CALL TRIPRT('Averaged antisymmetric two-body density matrix,PA',
     &              ' ',PAMAT,NACPAR)
      END IF
c
      IF ( NASH(1).NE.NAC ) CALL DBLOCK(DMAT)
      Call Timing(Rado_2,Swatch,Swatch,Swatch)
      Rado_2 = Rado_2 - Rado_1
      Rado_3 = Rado_3 + Rado_2
**************************************************************
**************************************************************

      CALL GETMEM('CICTL','FREE','REAL',LW1,NACPAR)
*
c      Call qExit('FCIQMC_CTL')

999   continue
      Return

      End
#elif defined (NAGFOR)
c Some compilers do not like empty files
      Subroutine empty_FCIQMC_Ctl()
      End
#endif
