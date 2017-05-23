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
* Copyright (C) Thomas Bondo Pedersen                                  *
************************************************************************
      SubRoutine dGeMM_Tri(TransA,TransB,m,n,k,alpha,A,ldA,B,ldB,
     &                     beta,C,ldC)
************************************************************
*
*   <DOC>
*     <Name>dGeMM\_Tri</Name>
*     <Syntax>Call dGeMM\_Tri(TransA,TransB,m,n,k,alpha,A,ldA,B,ldB,
*                             beta,C,ldC)
*     </Syntax>
*     <Arguments>
*       \Argument{TransA}{Transposition of A}{Character*1}{in}
*       \Argument{TransB}{Transposition of B}{Character*1}{in}
*       \Argument{m}{Row dimension of C}{Integer}{in}
*       \Argument{n}{Column dimension of C}{Integer}{in}
*       \Argument{k}{Dimension of summation index}{Integer}{in}
*       \Argument{alpha}{Scale factor}{Real*8}{in}
*       \Argument{A}{Factor matrix A}{Real*8}{in}
*       \Argument{ldA}{Leading dimension of A}{Integer}{in}
*       \Argument{B}{Factor matrix B}{Real*8}{in}
*       \Argument{ldB}{Leading dimension of B}{Integer}{in}
*       \Argument{beta}{Scale factor}{Real*8}{in}
*       \Argument{C}{Result matrix}{Real*8}{inout}
*       \Argument{ldC}{Leading dimension of C}{Integer}{in}
*     </Arguments>
*     <Purpose>
*       Compute matrix product, store result in triangular
*       storage format. May be used exactly as level 3 BLAS library
*       routine DGEMM with C stored triangularly.
*     </Purpose>
*     <Dependencies></Dependencies>
*     <Author>Thomas Bondo Pedersen</Author>
*     <Modified_by></Modified_by>
*     <Side_Effects></Side_Effects>
*     <Description>
*       This subroutine computes the matrix product of matrices A and B
*       in a manner similar to the level 3 BLAS routine DGEMM. Unlike
*       DGEMM, however, the result matrix C is computed in triangular
*       storage (i.e., only upper triangle [identical to lower triangle
*       if C is symmetric] including diagonal elements). The argument
*       list is identical to that of DGEMM. Note, however, that m must
*       be equal to n. Moreover, ldC is not used here (it is included
*       only to have the same interface as DGEMM), but must be at least
*       1.
*     </Description>
*    </DOC>
*
************************************************************
      Implicit None
      Character*1 TransA, TransB
      Integer     m, n, k, ldA, ldB, ldC
      Real*8      alpha, beta
      Real*8      A(ldA,*), B(ldB,*), C(*)

      Character*9  SecNam
      Parameter    (SecNam = 'dGeMM_Tri')
      Character*25 ArgErr
      Parameter    (ArgErr = ' Illegal argument number ')

      Real*8    Zero, One
      Parameter (Zero = 0.0d0, One = 1.0d0)

      Character*2 ArgNum
      Logical     NoAB, NoC
      Integer     iArg, j, kOff, ldARef, ldBRef

C     Test input parameters.
C     ----------------------

      If (TransA.eq.'N' .or. TransA.eq.'n') Then
         ldARef = m
      Else If (TransA.eq.'T' .or. TransA.eq.'t') Then
         ldARef = k
      Else
         ArgNum = ' 1'
         Call SysAbendMsg(SecNam,ArgErr,ArgNum)
         ldARef = 1
      End If
      ldARef = max(ldARef,1)

      If (TransB.eq.'N' .or. TransB.eq.'n') Then
         ldBRef = k
      Else If (TransB.eq.'T' .or. TransB.eq.'t') Then
         ldBRef = n
      Else
         ArgNum = ' 2'
         Call SysAbendMsg(SecNam,ArgErr,ArgNum)
         ldBRef = 1
      End If
      ldBRef = max(ldBRef,1)

      iArg = 0
      If (m .lt. 0) Then
         iArg = 3
      Else If (n .ne. m) Then
         iArg = 4
      Else If (k .lt. 0) Then
         iArg = 5
      Else If (ldA .lt. ldARef) Then
         iArg = 8
      Else If (ldB .lt. ldBRef) Then
         iArg = 10
      Else If (ldC .lt. 1) Then
         iArg = 13
      End If
      If (iArg .ne. 0) Then
         Write(ArgNum,'(I2)') iArg
         Call SysAbendMsg(SecNam,ArgErr,ArgNum)
      End If

C     Scale C and return if possible.
C     -------------------------------

      NoC  = n .eq. 0
      NoAB = alpha.eq.Zero .or. k.eq.0
      If (NoC .or. (NoAB .and. beta.eq.one)) Return
      If (beta .eq. Zero) Then
         Do j = 1,n*(n+1)/2
            C(j) = Zero
         End Do
      Else If (beta .ne. One) Then
         Call dScal_(n*(n+1)/2,beta,C,1)
      End If
      If (NoAB) Return

C     Compute using level 2 BLAS library (matrix-vector products).
C     ------------------------------------------------------------

      kOff = 1
      If (TransB.eq.'N' .or. TransB.eq.'n') Then
         If (TransA.eq.'N' .or. TransA.eq.'n') Then
            Do j = 1,n
               Call dGeMV_('N',j,k,alpha,A,ldA,B(1,j),1,One,C(kOff),1)
               kOff = kOff + j
            End Do
         Else
            Do j = 1,n
               Call dGeMV_('T',k,j,alpha,A,ldA,B(1,j),1,One,C(kOff),1)
               kOff = kOff + j
            End Do
         End If
      Else
         If (TransA.eq.'N' .or. TransA.eq.'n') Then
            Do j = 1,n
              Call dGeMV_('N',j,k,alpha,A,ldA,B(j,1),ldB,One,C(kOff),1)
              kOff = kOff + j
            End Do
         Else
            Do j = 1,n
              Call dGeMV_('T',k,j,alpha,A,ldA,B(j,1),ldB,One,C(kOff),1)
               kOff = kOff + j
            End Do
         End If
      End If

      End
