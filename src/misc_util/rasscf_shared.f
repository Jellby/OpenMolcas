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
c  **************************************
c  ** General-purpose utility routines shared with rasscf
c  **************************************
      subroutine imove_cvb(iv1,iv2,n)
      implicit real*8 (a-h,o-z)
      dimension iv1(n),iv2(n)
      do 100 i=1,n
100   iv2(i)=iv1(i)
      return
      end

      function len_trim_cvb(a)
c  Length of string excluding trailing blanks
      implicit real*8(a-h,o-z)
      character*(*) a

      do 100 i=len(a),1,-1
100   if(a(i:i).ne.' ')goto 200
      i=0
200   len_trim_cvb=i
      return
      end
