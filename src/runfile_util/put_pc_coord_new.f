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
      Subroutine Put_PC_Coord_New(Coord,nAtoms)
      Implicit Real*8 (a-h,o-z)
#include "real.fh"

      Real*8       Coord(7,nAtoms)
      Character*24 Label

      Label='GeoNewPC'
      Call Put_dArray(Label,Coord,7*nAtoms)

      Return
      End
