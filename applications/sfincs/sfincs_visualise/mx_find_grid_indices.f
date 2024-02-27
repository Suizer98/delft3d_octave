#include "fintrf.h"
C
#if 0
C     generate with :  mex mxinterp2d.f
C     
C     crvec.f
C     .F file needs to be preprocessed to generate .for equivalent
C     
#endif
C     
C     curvec.f
C
C     multiple the first input by the second input
      
C     This is a MEX file for MATLAB.
C     Copyright 1984-2004 The MathWorks, Inc. 
C     $Revision: 1.12.2.1 $
      
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on 64-bit platforms
C

C      mwpointer plhs(*), prhs(*)
C      mwpointer mxCreateDoubleMatrix
C      mwpointer mxGetPr
C      mwpointer x2_pr,y2_pr,x1_pr,y1_pr,u_pr,v_pr
C      mwpointer dt_pr,nt_pr,hdtck_pr,arthck_pr,xp_pr,yp_pr

C-----------------------------------------------------------------------
C
      integer*8 plhs(*), prhs(*)
 
      integer*8 nlhs, nrhs, ii

      integer*8 mxCreateDoubleMatrix, mxGetPr
      integer*8 mxGetM, mxGetN
 
      integer*8 n1, m1, n2, m2

      integer*8 :: x1_pr
      integer*8 :: y1_pr
      integer*8 :: indices_pr
      integer*8 :: x2_pr
      integer*8 :: y2_pr
      integer*8, dimension(2) :: dims2out
      integer*8 :: classid

      double precision, dimension(:),     allocatable :: x1
      double precision, dimension(:),     allocatable :: y1

      double precision, dimension(:,:),   allocatable :: x2
      double precision, dimension(:,:),   allocatable :: y2

      integer*8, dimension(:,:),          allocatable :: indices
     
c      open(800,file='out01.txt')
     
c     Number of points in regular grid     
      m1 = mxGetN(prhs(1))
      n1 = mxGetN(prhs(2))

c     Number of points in irregular grid     
      m2 = mxGetN(prhs(3))
      n2 = mxGetM(prhs(3))
      
c     Allocate

      allocate(x1(1:m1))
      allocate(y1(1:n1))
      allocate(indices(1:n1,1:m1))

      allocate(x2(1:n2,1:m2))
      allocate(y2(1:n2,1:m2))
      
      dims2out(1) = n1      
      dims2out(2) = m1      

C     Create matrix for the return argument.
      classid=mxClassIDFromClassName('int64')
      plhs(1) = mxCreateNumericArray(2, dims2out, classid, 0)

      x1_pr      = mxGetPr(prhs(1))
      y1_pr      = mxGetPr(prhs(2))
      x2_pr      = mxGetPr(prhs(3))
      y2_pr      = mxGetPr(prhs(4))
      indices_pr = mxGetPr(plhs(1))

C     Load the data into Fortran arrays.
      call mxCopyPtrToReal8(x1_pr,x1,m1)
      call mxCopyPtrToReal8(y1_pr,y1,n1)
      call mxCopyPtrToReal8(x2_pr,x2,n2*m2)
      call mxCopyPtrToReal8(y2_pr,y2,n2*m2)

C     Call the computational subroutine

      call get_indices(x1,y1,n1,m1,x2,y2,n2,m2,indices)     
      
C     Load the output into a MATLAB array.
      call mxCopyInteger8ToPtr(indices,indices_pr,n1*m1)

      deallocate(x1)
      deallocate(y1)
      deallocate(indices)
      deallocate(x2)
      deallocate(y2)

c      close(800)
      
      return
      end


      subroutine get_indices(x1,y1,n1,m1,x2,y2,n2,m2,indices)

      integer   n1,m1,n2,m2,n,m
      double    precision x1(m1)
      double    precision y1(n1)
      integer*8 indices(n1,m1)
      double    precision x2(n2,m2)
      double    precision y2(n2,m2)
      integer   i,j
      double    precision xx(m1*n1)
      double    precision yy(m1*n1)
      integer*8 iref(n1*m1) 
      integer*8 code(n2,m2)
     
c      open(900,file='out02.txt')
      
      j = 0
      do n = 1, n1
         do m = 1, m1
            j = j + 1
            xx(j) = x1(m)
            yy(j) = y1(n)
         enddo
      enddo
            
      do i=1,n2
         do j=1,m2
            if (x2(i,j)<-999.1 .or. x2(i,j)>-998.8) then
               code(i,j) = 1
            else
               code(i,j) = -1
            endif
         enddo
      enddo      

      call mkmap(code,x2,y2,n2,m2,xx,yy,n1*m1,iref)

      j = 0
      do n = 1, n1
         do m = 1, m1
            j = j + 1
            indices(n,m) = iref(j)
         enddo
      enddo
      
      close(900)

      return

      end

      
      Subroutine  HUNT (xx,n,x,jlo)
c
      Integer*8         n,jlo,jhi,inc,jm
      double precision xx(n),x
      Logical         ascnd
c
      ascnd = xx(n).GE.xx(1)
      If (jlo.LE.0.OR.jlo.GT.n) Then
         jlo = 0
         jhi = n+1
         Goto 3
      Endif
      inc = 1
      If (x.GE.xx(jlo).EQV.ascnd) Then
    1    jhi = jlo+inc
         If (jhi.GT.n) Then
            jhi = n+1
         Elseif (x.GE.xx(jhi).EQV.ascnd) Then
            jlo = jhi
            inc = inc+inc
            Goto 1
         Endif
      Else
         jhi = jlo
    2    jlo = jhi-inc
         If (jlo.LT.1) Then
            jlo = 0
         Elseif (x.LT.xx(jlo).EQV.ascnd) Then
            jhi = jlo
            inc = inc+inc
            Goto 2
         Endif
      Endif
    3 If (jhi-jlo.EQ.1) Return
         jm  = (jhi+jlo)/2
         If (x.GT.xx(jm).EQV.ascnd) Then
            jlo = jm
         Else
            jhi = jm
         Endif
      Goto 3
      End

      Subroutine INDEXX (n,arrin,indx)
c
      Integer*8         i,indxt,ir,l,n,j,indx(n)
      double precision q,arrin(n)
c
      Do 11 j=1,n
            indx(j)=j
   11 Continue
      l  = n/2+1
      ir = n
   10 Continue
        If (l.GT.1) Then
           l       = l-1
           indxt   = indx(l)
           q       = arrin(indxt)
        Else
           indxt   = indx(ir)
           q       = arrin(indxt)
           indx(ir)= indx(1)
           ir      = ir-1
           If (ir.EQ.1) Then
              indx(1) = indxt
              Return
           Endif
        Endif
        i = l
        j = l+l
   20   Continue
        If (j.LE.ir) Then
           If (j.LT.ir) Then
              If (arrin(indx(j)).LT.arrin(indx(j+1))) j = j+1
           Endif
           If (q.LT.arrin(indx(j))) Then
              indx(i) = indx(j)
              i       = j
              j       = j+j
           Else
              j       = ir+1
           Endif
           Goto 20
        Endif
        indx(i) = indxt
      Goto 10
      End

      Subroutine IPON (x,y,n,xp,yp,inout)
c
***********************************************************************
*     WATERLOOPKUNDIG LABORATORIUM                                    *
*     AUTEUR : J.A.ROELVINK                                           *
*     DATUM  : 22-12-1988                                             *
*     BEPAALT OF PUNT (xp,yp) IN POLYGOON (x,y) VAN n PUNTEN LIGT     *
*     PUNT n+1 WORDT GELIJK GEMAAKT AAN PUNT 1                        *
*     (ARRAY MOET IN HOOFPROGRAMMA n+1 LANG ZIJN)                     *
*     inpout = -1 :  BUITEN POLYGOON                                  *
*     inpout =  0 : OP RAND POLYGOON                                  *
*     inpout =  1 :  BINNEN POLYGOON                                  *
*     GEBRUIKTE METHODE:    - TREK EEN VERTICALE LIJN DOOR (xp,yp)    *
*                           - BEPAAL AANTAL SNIJPUNTEN MET POLYGOON   *
*                             ONDER yp : nonder                       *
*                           - ALS nonder EVEN IS, DAN LIGT HET PUNT   *
*                             BUITEN DE POLYGOON, ANDERS ERBINNEN     *
*                           - DE RAND WORDT APART AFGEVANGEN          *
***********************************************************************
      Integer*8         n,inout,nonder,i
      double precision xp,yp,ysn,x(*),y(*)
c
      x(n+1) = x(1)
      y(n+1) = y(1)
      Do 5 i=1,n+1
           x(i) = x(i)-xp
           y(i) = y(i)-yp
    5 Continue
      nonder = 0
      Do 10 i=1,n
         If ((x(i  ).LT.0..AND.x(i+1).GE.0.).OR.
     .       (x(i+1).LT.0..AND.x(i  ).GE.0.)) Then
            If (y(i).LT.0..AND.y(i+1).LT.0.) Then
               nonder = nonder+1
            Elseif ((y(i  ).LE.0..AND.y(i+1).GE.0.).OR.
     .              (y(i+1).LE.0..AND.y(i  ).GE.0.)) Then
               ysn    = (y(i)*x(i+1)-x(i)*y(i+1))/(x(i+1)-x(i))
               If (ysn.LT.0.) Then
                  nonder = nonder+1
               Elseif (ysn.LE.0.) Then
*                 rand
                  inout = 0
                  Goto 100
               Endif
            Endif
         Elseif (ABS (x(i)).LT.1.0E-12.AND.ABS (x(i+1)).LT.1.0E-12) Then
            If ((y(i  ).LE.0..AND.y(i+1).GE.0.).OR.
     .          (y(i+1).LE.0..AND.y(i  ).GE.0.)) Then
*              rand
               inout = 0
               Goto 100
            Endif
         Endif
   10 Continue
      If (MOD (nonder,2).EQ.0) Then
*        buiten
         inout =-1
      Else
*        binnen
         inout = 1
      Endif
  100 Continue
      Do 110 i=1,n
             x(i) = x(i)+xp
             y(i) = y(i)+yp
  110 Continue
      End


      Subroutine MKMAP  (code,X1,Y1,N1,M1,X2,Y2,N2,Iref)
c
      Integer*8       i,i1,i2,iin,ip,ipt,j1,lomaxx,lominx,lomnx,lomny,
     .                nin,M1,N1,M1min,M1max,N1min,N1max,N2,inout,ier,
     .                NrX(N2),NrY(N2),iFlag(N2),NrIn(N2),
     .                code(n1,m1),iprint,iok
      integer*8       Iref(N2)
      double precision X1(N1,M1),Y1(N1,M1),X2(N2),Y2(N2),Xs(N2),Ys(N2),
     .                Xp(5),Yp(5),Xpmin,Xpmax,Ypmin,Ypmax,
     .                xpmean,ypmean
*-----------------------------------------------------------------------
*     SUBROUTINE MKMAP
*     Interpolatie van kromlijnig, aftelbaar rooster naar random
*     punten, met opslag van gewichtspunten. Afgeleid van routine
*     MATRANT
*
*     J.A. Roelvink
*     Waterloopkundig Laboratorium
*     14-5-1991 (MATRANT)
*     24-2-1992 (MKMAP
*
*     Gegeven: aftelbaar rooster M1*N1
*     met coordinaten X1 (1:M1,1:N1)
*                  en Y1 (1:M1,1:N1)
*
*     Tevens gegeven: random punten X2(1:N2)
*                                en Y2(1:N2)
*
*     Gevraagd: gewichtsfactoren en pointers t.b.v. bilineaire inter-
*     polatie
*     Gewichtsfactoren en de plaatsen van de vraagpunten in het
*     aanbodrooster worden opgeslagen in resp.
*     W(1:4,1:N2) en Iref(1:4,1:N2)
*-----------------------------------------------------------------------
*     Initialiseer tabellen
*-----------------------------------------------------------------------

c      open(888,file='mkmap.txt')
      
      iprint = 0

      lomnx = 1
      lomny = 1
      M1min = 1
      N1min = 1
      M1max = M1
      N1max = N1
      do i2 = 1, N2
             nrx(i2)   = 0
             nry(i2)   = 0
             iflag(i2) = 0
             nrin(i2)  = 0
             xs(i2)    = 0.
             ys(i2)    = 0.
             Iref(i2) = 0
      enddo       

*     Sorteer X2 en Y2
*-----------------------------------------------------------------------
      Call SORT   (N2,X2,Xs,NrX)
      Call SORT   (N2,Y2,Ys,NrY)

*     Loop langs iedere cel van rooster 1
*-----------------------------------------------------------------------
      Do 900 i1=N1min,N1max-1
             Do 800 j1=M1min,M1max-1

*        Checken op punten met 'onzin' coordinaten in aanbodrooster 1;
*        dit is afhankelijk van gemaakte afspraken!
*-----------------------------------------------------------------------
                iok = 1
                    if (code(i1,j1).GE.0.AND.code(i1+1,j1).GE.0.AND.
     .                  code(i1+1,j1+1).GE.0.AND.code(i1,j1+1).GE.0)
     .                                                              Then
*        Definitie cel
*-----------------------------------------------------------------------
                       Xp(1) = X1(i1  ,j1)
                       Xp(2) = X1(i1  ,j1+1)
                       Xp(3) = X1(i1+1,j1+1)
                       Xp(4) = X1(i1+1,j1)
                       Yp(1) = Y1(i1  ,j1)
                       Yp(2) = Y1(i1,j1+1)
                       Yp(3) = Y1(i1+1,j1+1)
                       Yp(4) = Y1(i1+1,j1)
                   else
                      iok = 0
                   endif

                if (iok==1) then

*        Bepaling minimum en maximum X en Y van de cel
*-----------------------------------------------------------------------
                       Xpmin = 1.e10
                       Xpmax =-1.e10
                       Ypmin = 1.e10
                       Ypmax =-1.e10
                       do ip = 1, 4
                          Xpmin = MIN (Xp(ip),Xpmin)
                          Xpmax = MAX (Xp(ip),Xpmax)
                          Ypmin = MIN (Yp(ip),Ypmin)
                          Ypmax = MAX (Yp(ip),Ypmax)
                       enddo   
                       Xpmean = 0.5*(Xpmin+Xpmax)
                       Ypmean = 0.5*(Ypmin+Ypmax)

*        Eerste selectie van punten verzameling 2 die binnen de cel
*        kunnen liggen
*-----------------------------------------------------------------------
*        Zoek centrum van de cel op in tabellen Xs en Ys
*-----------------------------------------------------------------------
                       Call HUNT   (Xs,N2,Xpmean,lomnX)
                       Call HUNT   (Ys,N2,Ypmean,lomnY)
*        Zet voor punten met x-waarden tussen Xpmin en Xpmax iFlag(i)=1
*-----------------------------------------------------------------------
                       lominX=lomnX
                       lomaxX=lomnX
                       Do 300 i=lomnX,1,-1
                              If (Xs(i).GE.Xpmin) Then
                                 lominX        = i
                                 iFlag(NrX(i)) = 1
                              Else
                                 Goto 310
                              Endif
  300                  Continue
  310                  Continue
                       Do 320 i=lomnX+1,N2
                              If (Xs(i).LE.Xpmax) Then
                                 lomaxX        = i
                                 iFlag(NrX(i)) = 1
                              Else
                                 Goto 330
                              Endif
  320                  Continue
  330                  Continue
*        Sla de nummers van punten met y-waarden tussen Ypmin en
*        Ypmax, die bovendien tussen Xpmin en Xpmax liggen, op in NrIn
*-----------------------------------------------------------------------
                       iIn = 1
                       Do 340 i=lomnY,1,-1
                              If (Ys(i).GE.Ypmin) Then
                                 NrIn(iIn) = NrY(i)*iFlag(NrY(i))
                                 iIn       =iIn + iFlag(NrY(i))
                              Else
                                 Goto 350
                              Endif
  340                  Continue
  350                  Continue
                       Do 360 i=lomnY+1,N2
                              If (Ys(i).LE.Ypmax) Then
                                 NrIn(iIn) = NrY(i)*iFlag(NrY(i))
                                 iIn       = iIn + iFlag(NrY(i))
                              Else
                                 Goto 370
                              Endif
  360                  Continue
  370                  Continue
                       NIn = iIn-1
*        Zet iFlag weer terug op 0
*-----------------------------------------------------------------------
                       Do 400 i=lominX,lomaxX
                              If (i.NE.0) iFlag(NrX(i)) = 0
  400                  Continue
*        Check of geselecteerde punten van rooster 2 binnen cel liggen
*        m.b.v. subroutine IPON; zo ja, bepaal gewichten W van de
*        omliggende waarde van rooster 1 m.b.v. subroutine INTRP4, en
*        sla deze op in Wtab; de verwijzing naar rooster 1 wordt
*        opgeslagen in arrays Iref en Jref.
*-----------------------------------------------------------------------
                       Do 500 iIn=1,NIn
                              i2    = NrIn(iIn)
                              inout =-1
                              Call IPON   (Xp,Yp,4,X2(i2),Y2(i2),inout)
                              If (inout.GE.0) Then
                                    Iref(i2) = i1   +(j1-1)*(N1-1)
                              Endif
  500                  Continue
                    Endif
  800        Continue
  900 Continue

c      close(888)

      End


      Subroutine SORT (n,ra,wksp,iwksp)
c
      Integer*8         j,n,iwksp(n)
      double precision          ra(n),wksp(n)
c
      Call INDEXX (n,ra,iwksp)
      Do 120 j=1,n
             wksp(j) = ra(iwksp(j))
  120 Continue
      End



