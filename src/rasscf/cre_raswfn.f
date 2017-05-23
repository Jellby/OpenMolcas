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
      subroutine cre_raswfn
*     SVC: Create a wavefunction file. If another .wfn file already
*     exists, it will be overwritten.
      implicit none
#ifdef _HDF5_
#  include "rasdim.fh"
#  include "rasscf.fh"
#  include "WrkSpc.fh"
#  include "general.fh"
#  include "stdalloc.fh"
#  include "raswfn.fh"
#  include "gugx.fh"
#  include "gas.fh"
      Integer         IDXCI(mxAct), IDXSX(mxAct)
      Common /IDSXCI/ IDXCI,        IDXSX

      integer :: dsetid
      character(1), allocatable :: typestring(:)

*     create a new wavefunction file!
      wfn_fileid = mh5_create_file('RASWFN')

*     set module type
      call mh5_init_attr (wfn_fileid,'MOLCAS_MODULE', 'RASSCF')

*     copy basic molecular information to the HDF5 file
      call run2h5_molinfo(wfn_fileid)
      call one2h5_ovlmat(wfn_fileid, nsym, nbas)
      call one2h5_fckint(wfn_fileid, nsym, nbas)
      call one2h5_crtmom(wfn_fileid, nsym, nbas)

*     set wavefunction type
      if (IFCAS.EQ.0) then
        call mh5_init_attr (wfn_fileid,'CI_TYPE', 'CAS')
      else
        call mh5_init_attr (wfn_fileid,'CI_TYPE', 'RAS')
      end if

*     general wavefunction attributes
      call mh5_init_attr (wfn_fileid,'SPINMULT', iSpin)
      call mh5_init_attr (wfn_fileid,'LSYM', lSym)
      call mh5_init_attr (wfn_fileid,'NACTEL', nActEl)
      call mh5_init_attr (wfn_fileid,'NHOLE1', nHole1)
      call mh5_init_attr (wfn_fileid,'NELEC3', nElec3)
      call mh5_init_attr (wfn_fileid,'NCONF',  nConf)
      call mh5_init_attr (wfn_fileid,'NSTATES', nRoots)
      call mh5_init_attr (wfn_fileid,'NROOTS', lRoots)

      call mh5_init_attr (wfn_fileid,'L2ACT', 1, [mxAct], IDXSX)
      call mh5_init_attr (wfn_fileid,'A2LEV', 1, [mxAct], IDXCI)

*     iteration(s)
      wfn_iter = mh5_create_attr_int (wfn_fileid,'RASSCF_ITERATIONS')

*     molecular orbital type index
      call mma_allocate(typestring, ntot)
      call orb2tpstr(NSYM,NBAS,
     $        NFRO,NISH,NRS1,NRS2,NRS3,NSSH,NDEL,
     $        typestring)
      dsetid = mh5_create_dset_str(wfn_fileid,
     $        'MO_TYPEINDICES', 1, [NTOT],1)
      call mh5_init_attr(dsetid, 'description',
     $        'Type index of the molecular orbitals '//
     $        'arranged as blocks of size [NBAS(i)], i=1,#irreps')
      call mh5_put_dset(dsetid, typestring)
      call mma_deallocate(typestring)
      call mh5_close_dset(dsetid)

*     roots
      call mh5_init_attr (wfn_fileid,
     $        'STATE_ROOTID', 1, [nRoots], iRoot)
      call mh5_init_attr (wfn_fileid,
     $        'STATE_WEIGHT', 1, [nRoots], Weight)

*     energy (for each CI root)
      wfn_energy = mh5_create_dset_real (wfn_fileid,
     $        'ROOT_ENERGIES', 1, [lRoots])
      call mh5_init_attr(wfn_energy, 'description',
     $        'Energy for each root in the CI, '//
     $        'arranged as array of [NROOTS]')

*     molecular orbital coefficients
      wfn_mocoef = mh5_create_dset_real(wfn_fileid,
     $        'MO_VECTORS', 1, [NTOT2])
      call mh5_init_attr(wfn_mocoef, 'description',
     $        'Coefficients of the average orbitals, '//
     $        'arranged as blocks of size [NBAS(i)**2], i=1,#irreps')

*     molecular orbital occupation numbers
      wfn_occnum = mh5_create_dset_real(wfn_fileid,
     $        'MO_OCCUPATIONS', 1, [NTOT])
      call mh5_init_attr(wfn_occnum, 'description',
     $        'Occupation numbers of the average orbitals '//
     $        'arranged as blocks of size [NBAS(i)], i=1,#irreps')

*     molecular orbital energies
      wfn_orbene = mh5_create_dset_real(wfn_fileid,
     $        'MO_ENERGIES', 1, [NTOT])
      call mh5_init_attr(wfn_orbene, 'description',
     $        'Orbital energies of the average orbitals '//
     $        'arranged as blocks of size [NBAS(i)], i=1,#irreps')

*     molecular orbital symmetry irreps
      wfn_supsym = mh5_create_dset_int(wfn_fileid,
     $        'SUPSYM_IRREP_INDICES', 1, [NTOT])
      call mh5_init_attr(wfn_supsym, 'description',
     $        'Supersymmetry ID of the average orbitals '//
     $        'arranged as blocks of size [NBAS(i)], i=1,#irreps')
      call mh5_init_attr(wfn_supsym, 'pointgroup', 'D5h')
      call mh5_init_attr(wfn_supsym, '#irreps', 7)
      call mh5_put_dset(wfn_supsym, IXSYM)

*     CI data for each root
      wfn_cicoef = mh5_create_dset_real(wfn_fileid,
     $        'CI_VECTORS', 2, [nConf, lRoots])
      call mh5_init_attr(wfn_cicoef, 'description',
     $        'Coefficients of configuration state functions '//
     $        'in Split-GUGA ordering, size [NCONF] '//
     $        'for each root in NROOTS: [NCONF,NROOTS].')

*     density matrices for each root
      wfn_dens = mh5_create_dset_real (wfn_fileid,
     $        'DENSITY_MATRIX', 3, [NAC, NAC, lRoots])
      call mh5_init_attr(wfn_dens, 'description',
     $        'active 1-body density matrix, size [NAC,NAC] '//
     $        'for each root in NROOTS: [NAC,NAC,NROOTS].')

      wfn_spindens = mh5_create_dset_real (wfn_fileid,
     $        'SPINDENSITY_MATRIX', 3, [NAC, NAC, lRoots])
      call mh5_init_attr(wfn_spindens, 'description',
     $        'active 1-body spin density matrix, size [NAC,NAC] '//
     $        'for each root in NROOTS: [NAC,NAC,NROOTS].')

*     fock matrix
      wfn_fockmat = mh5_create_dset_real (wfn_fileid,
     $        'FOCK_MATRIX', 1, [NTOT2])
      call mh5_init_attr(wfn_fockmat, 'description',
     $        'Fock matrix '//
     $        'arranged as blocks of size [NBAS(i)**2], i=1,#irreps')

#endif
      end
