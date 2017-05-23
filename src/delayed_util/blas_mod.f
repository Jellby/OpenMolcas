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
      module BLAS_MOD

      contains

#include "dasum.f"
#include "daxpy.f"
#include "dcabs1.f"
#include "dcopy.f"
#include "ddot.f"
#include "dgemm.f"
#include "dgemv.f"
#include "dger.f"
#include "dnrm2.f"
#include "drot.f"
#include "dscal.f"
#include "dspmv.f"
#include "dspr2.f"
#include "dspr.f"
#include "dswap.f"
#include "dsymm.f"
#include "dsymv.f"
#include "dsyr2.f"
#include "dsyr2k.f"
#include "dsyrk.f"
#include "dtpmv.f"
#include "dtpsv.f"
#include "dtrmm.f"
#include "dtrmv.f"
#include "dtrsm.f"
#include "dtrsv.f"
#include "dznrm2.f"
#include "idamax.f"
#include "lsame.f"
#include "scopy.f"
#include "xerbla.f"
#include "zaxpy.f"
#include "zcopy.f"
#include "zdotc.f"
#include "zdscal.f"
#include "zgemm.f"
#include "zgemv.f"
#include "zgerc.f"
#include "zhemv.f"
#include "zher2.f"
#include "zher2k.f"
#include "zhpmv.f"
#include "zhpr2.f"
#include "zscal.f"
#include "zswap.f"
#include "ztrmm.f"
#include "ztrmv.f"

      end module BLAS_MOD
