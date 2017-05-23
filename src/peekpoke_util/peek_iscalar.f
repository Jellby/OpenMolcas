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
* Copyright (C) 2008, Per-Olof Widmark                                 *
************************************************************************
************************************************************************
*                                                                      *
* This routine get scalar integer data from the peek/poke buffer.      *
*                                                                      *
*----------------------------------------------------------------------*
*                                                                      *
* Author:  Per-Olof Widmark                                            *
*          Lund University                                             *
*          Sweden                                                      *
* Written: May 2008                                                    *
*                                                                      *
************************************************************************
*
* <DOC>
*   <Name>Peek\_iScalar</Name>
*   <Syntax>Call Peek\_iScalar(Label,Data)</Syntax>
*   <Arguments>
*     \Argument{Label}{Name of field}{Character*(*)}{in}
*     \Argument{Data}{Data to put on runfile}{Real*8}{in}
*   </Arguments>
*   <Purpose>To put scalar data in peek/poke buffer.</Purpose>
*   <Dependencies></Dependencies>
*   <Author>Per-Olof Widmark</Author>
*   <Modified_by></Modified_by>
*   <Side_Effects></Side_Effects>
*   <Description>
*     This routine is used to put scalar data of type Real*8
*     in the peek/poke buffer. The data items are identified
*     by a text label.
*   </Description>
* </DOC>
*
************************************************************************
      Subroutine Peek_iScalar(Label,Data)
      Implicit None
#include "pp_is_info.fh"
*----------------------------------------------------------------------*
* Arguments                                                            *
*----------------------------------------------------------------------*
      Character*(*) Label
      Integer       Data
*----------------------------------------------------------------------*
* Define local variables                                               *
*----------------------------------------------------------------------*
      Logical Found
      Integer indx
      Integer i
*----------------------------------------------------------------------*
* Initialize local variables                                           *
*----------------------------------------------------------------------*
      Found=.false.
*     Write(6,'(2a)') 'peek_iscalar: Label is ',Label
*     Write(6,'(a,i8)') 'peek_iscalar: is_no is ',is_no
*----------------------------------------------------------------------*
* Locate item                                                          *
*----------------------------------------------------------------------*
      indx=-1
      Do i=1,is_no
         If(is_label(i).eq.Label) indx=i
      End Do
*     Write(6,'(a,i8)') 'peek_iscalar: indx is ',indx
*----------------------------------------------------------------------*
* Get data from buffer.                                                *
*----------------------------------------------------------------------*
      If(indx.eq.-1) Then
         If(is_no.ge.nTabIS) Then
            Call SysAbendMsg('Peek_iScalar',
     &         'Too many fields',
     &         'Increase nTabIS and recompile')
         End If
         is_no=is_no+1
         indx=is_no
         Call Qpg_iScalar(Label,Found)
         If(Found) Then
            Call Get_iScalar(Label,Data)
         Else
            Call SysAbendMsg('Peek_iScalar',
     &         'Field not found',
     &         Label)
         End If
         is_label(indx)=Label
         is_value(indx)=Data
      Else
         Data=is_value(indx)
      End If
*     Write(6,'(a,i8)') 'peek_iscalar: Data is ',Data
*----------------------------------------------------------------------*
* Done                                                                 *
*----------------------------------------------------------------------*
      Return
      End
