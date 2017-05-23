************************************************************************
* This file is part of OpenMolcas.                                     *
*                                                                      *
* OpenMolcas is free software; you can redistribute it and/or modify   *
* it under the terms of the GNU Lesser General Public License, v. 2.1. *
* OpenMolcas is distributed in the hope that it will be useful, but it *
* is provided "as is" and without any express or implied warranties.   *
* For more details see the full text of the license in the file        *
* LICENSE or in <http://www.gnu.org/licenses/>.                        *
*                                                                      *
* Copyright (C) 1996-2006, T. Thorsteinsson and D. L. Cooper           *
************************************************************************
      subroutine schmidtn2_cvb(c,sxc,nvec,sao,n,metr)
      implicit real*8 (a-h,o-z)
      dimension c(n,nvec),sxc(n,nvec),sao(*)
      save thresh,one
      data thresh/1d-20/,one/1d0/

      do 100 i=1,nvec
      do 200 j=1,i-1
200   call daxpy_(n,-ddot_(n,c(1,i),1,sxc(1,j),1),c(1,j),1,c(1,i),1)
      if(metr.ne.0)call saoon_cvb(c(1,i),sxc(1,i),1,sao,n,metr)
      cnrm=ddot_(n,c(1,i),1,sxc(1,i),1)
      if(cnrm.lt.thresh)then
        write(6,*)' Warning : near-singularity in orthonormalization.'
        write(6,*)' Vector norm :',cnrm
      endif
      fac=one/sqrt(cnrm)
      call dscal_(n,fac,c(1,i),1)
100   if(metr.ne.0)call dscal_(n,fac,sxc(1,i),1)
      return
      end
