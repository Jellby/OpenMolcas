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
      subroutine sethr_cvb(iarr,n)
      implicit real*8(a-h,o-z)
#include "idbl_cvb.fh"
      dimension iarr(n)

      call seth_cvb(n,1)
      call seth_cvb(iarr,idbl*n)
      return
      end

      subroutine gethr_cvb(iarr,n)
      implicit real*8(a-h,o-z)
#include "idbl_cvb.fh"
      dimension iarr(n)
      call geth_cvb(n,1)
      call geth_cvb(iarr,idbl*n)
      return
      end
