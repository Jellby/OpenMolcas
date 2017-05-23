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
* Copyright (C) Yannick Carissan                                       *
************************************************************************
      subroutine quaterFinish()
************************************************************
*
*   <DOC>
*     <Name>quaterFinish</Name>
*     <Syntax>quaterFinish()</Syntax>
*     <Arguments>
*     </Arguments>
*     <Purpose>Clean the quater environment</Purpose>
*     <Dependencies>memory util</Dependencies>
*     <Author>Y. Carissan</Author>
*     <Modified_by></Modified_by>
*     <Side_Effects>none</Side_Effects>
*     <Description>
*        Release the memory used by the quater program
*     </Description>
*    </DOC>
*
************************************************************

      implicit none
#include "WrkSpc.fh"
#include "geoms.fh"
      character*6 cName
      integer ig

      do ig=1,ngeoms+2
        if (ig.lt.100) Write(cName,'(a4,i2)') "GEOM",ig
        if (ig.lt.10) Write(cName,'(a5,i1)') "GEOM0",ig
          Call Getmem(cName,"Free",'Real',ipgeo(ig),0)
      end do
      Return
      End
