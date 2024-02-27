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
 
      integer*8 m1, n1, n2, isize1

      integer*8 x2_pr,y2_pr,z2_pr,x1_pr,y1_pr,z1_pr

      double precision, dimension(:),   allocatable :: x1
      double precision, dimension(:),   allocatable :: y1
      double precision, dimension(:),   allocatable :: z1
      double precision, dimension(:),   allocatable :: x2
      double precision, dimension(:),   allocatable :: y2
      double precision, dimension(:),   allocatable :: z2
     
      open(800,file='out01.txt')
     
c     Total number of arrows     
      n2 = mxGetM(prhs(4))

      write(800,*)n2
c     Grid size m1 and n1
      m1 = mxGetM(prhs(1))
      n1 = mxGetN(prhs(1))
      isize1 = m1*n1
      write(800,*)m1,n1,isize1
      
c     Allocate

      allocate(x1(1:isize1))
      allocate(y1(1:isize1))
      allocate(z1(1:isize1))
      write(800,*)'OKa'

      allocate(x2(1:n2))
      allocate(y2(1:n2))
      allocate(z2(1:n2))
      write(800,*)'OKb'

C     Create matrix for the return argument.
      plhs(1) = mxCreateDoubleMatrix(n2,1,0)
      write(800,*)'OKc'

      x1_pr     = mxGetPr(prhs(1))
      y1_pr     = mxGetPr(prhs(2))
      z1_pr     = mxGetPr(prhs(3))
      x2_pr     = mxGetPr(prhs(4))
      y2_pr     = mxGetPr(prhs(5))
      write(800,*)'OKd'

      z2_pr     = mxGetPr(plhs(1))
      write(800,*)'OKe'

C     Load the data into Fortran arrays.
      call mxCopyPtrToReal8(x1_pr,x1,isize1)
      call mxCopyPtrToReal8(y1_pr,y1,isize1)
      call mxCopyPtrToReal8(z1_pr,z1,isize1)
      call mxCopyPtrToReal8(x2_pr,x2,n2)
      call mxCopyPtrToReal8(y2_pr,y2,n2)

      write(800,*)'OK1'
C     Call the computational subroutine

      write(800,*)n2,m1,n1
      call mkcurvec(x2,y2,z2,n2,x1,y1,z1,m1,n1)
      write(800,*)'OK2'
     
      
C     Load the output into a MATLAB array.
      call mxCopyReal8ToPtr(z2,z2_pr,n2)
      write(800,*)'OK3'

c      do ii=1,n2
c      write(800,*)'shite'
c      write(800,*)z2(ii)
c      enddo

      deallocate(x1)
      deallocate(y1)
      deallocate(z1)
      deallocate(x2)
      deallocate(y2)
      deallocate(z2)

      write(800,*)'OK4'
      

      close(800)
      
      return
      end

      subroutine mkcurvec(x2,y2,z2,n2,x1,y1,z1,m1,n1)

      integer n2,m1,n1
      integer NrIn(n2),NrX(n2),NrY(n2),iFlag(n2),Iref(4,n2)
 
*     This routine computes curved arrows by following particles injected in the flow. 
*     It has been adapted to serve both curvilinear and unstructured grids
*
*     In case of curvilinear grid x1 and y1 are m1 by n1; u1 and v1 are given at the same points
*     and will be interpolated by bilinear interpolation to the randomly located positions 
*     x2, y2
*
*     In case of unstructured grid x1 and y1 represent m1 polygons that are all n1==4 long. They 
*     may represent triangles or quadrilaterals; in case of triangles the 4th point equals the first.
*     in the unstructured case no interpolation takes place but the velocities are assumed uniform 
*     over the cell. In this case only u1(:,1) and v1(:,1) are filled; the rest of the arrays is 
*     padded with zeros.
 
      integer code(m1,n1)

      double precision x2(n2)
      double precision y2(n2)
      double precision z2(n2)
 
      double precision xs(n2)
      double precision ys(n2)

      double precision x1(m1,n1)
      double precision y1(m1,n1)
      double precision z1(m1,n1)

      double precision W(4,n2)
     
      open(900,file='out02.txt')
   
      if (n1==4) then
         n1u=1
      else
         n1u=n1
      endif
      
      np=m1*n1
      write(900,*)np,m1,n1,n2
            
      do i=1,m1
         do j=1,n1
            if (x1(i,j)<-999.1 .or. x1(i,j)>-998.8) then
               code(i,j) = 1
            else
               code(i,j) = -1
            endif
         enddo
      enddo

      call MKMAP(code,X1,Y1,M1,N1,X2,Y2,N2,Xs,Ys,NrX,NrY,iFlag, 
     &        NrIn,W,Iref,iprint)
     
      call GRMAP (z1,np,z2,n2,iref,w) 

c      do i=1,n2
c         write(900,*)z2(i)
c      enddo

c      write(900,*)'ok5'

      
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


      Subroutine MKMAP  (code,X1,Y1,M1,N1,X2,Y2,N2,Xs,Ys,NrX,NrY,iFlag,
     .                  NrIn,W,Iref,iprint)
c
      Integer*8         i,i1,i2,iin,ip,ipt,j1,lomaxx,lominx,lomnx,lomny,
     .                nin,M1,N1,M1min,M1max,N1min,N1max,N2,inout,ier,
     .                NrX(N2),NrY(N2),iFlag(N2),NrIn(N2),Iref(4,N2),
     .                code(m1,n1),iprint,iok
      double precision X1(M1,N1),Y1(M1,N1),X2(N2),Y2(N2),Xs(N2),Ys(N2),
     .                Xp(5),Yp(5),Xpmin,Xpmax,Ypmin,Ypmax,W(4,N2),
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

      If (iprint.EQ.1) Write (*,*) 'in mkmap',m1,n1,n2
      lomnx = 1
      lomny = 1
      M1min = 1
      N1min = 1
      if (N1==4) then
*         N1max = 1
         M1max = M1 + 1
         N1max = 2
      else
         M1max = M1
         N1max = N1
      endif
      Do 110 i2=1,N2
             nrx(i2)   = 0
             nry(i2)   = 0
             iflag(i2) = 0
             nrin(i2)  = 0
             xs(i2)    = 0.
             ys(i2)    = 0.
             Do 100 ipt=1,4
                    Iref(ipt,i2) = 0
                    W   (ipt,i2) = 0.
  100        Continue
  110 Continue

*     Sorteer X2 en Y2
*-----------------------------------------------------------------------
      Call SORT   (N2,X2,Xs,NrX)
      Call SORT   (N2,Y2,Ys,NrY)

*     Loop langs iedere cel van rooster 1
*-----------------------------------------------------------------------
      Do 900 j1=N1min,N1max-1
             Do 800 i1=M1min,M1max-1
*        Checken op punten met 'onzin' coordinaten in aanbodrooster 1;
*        dit is afhankelijk van gemaakte afspraken!
*-----------------------------------------------------------------------
                iok = 1

                If (N1.EQ.4) Then
                    !
                    !   unstructured grid
                    !
                    do ip = 1, 4
                       Xp(ip) = X1(i1,ip)
                       Yp(ip) = Y1(i1,ip)
                    enddo

                Else
                    If (code(i1,j1).GE.0.AND.code(i1+1,j1).GE.0.AND.
     .                  code(i1+1,j1+1).GE.0.AND.code(i1,j1+1).GE.0)
     .                                                              Then
*        Definitie cel
*-----------------------------------------------------------------------
                       Xp(1) = X1(i1  ,j1)
                       Xp(2) = X1(i1+1,j1)
                       Xp(3) = X1(i1+1,j1+1)
                       Xp(4) = X1(i1  ,j1+1)
                       Yp(1) = Y1(i1  ,j1)
                       Yp(2) = Y1(i1+1,j1)
                       Yp(3) = Y1(i1+1,j1+1)
                       Yp(4) = Y1(i1  ,j1+1)
                   else
                      iok = 0
                   Endif
                endif

                if (iok==1) then

*        Bepaling minimum en maximum X en Y van de cel
*-----------------------------------------------------------------------
                       Xpmin = 1.e10
                       Xpmax =-1.e10
                       Ypmin = 1.e10
                       Ypmax =-1.e10
                       Do 200 ip=1,4
                              Xpmin = MIN (Xp(ip),Xpmin)
                              Xpmax = MAX (Xp(ip),Xpmax)
                              Ypmin = MIN (Yp(ip),Ypmin)
                              Ypmax = MAX (Yp(ip),Ypmax)
  200                  Continue
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
                                 If (N1.EQ.4) Then
*                                   unstructured grid
                                    w   (1,i2)=1.d0
                                    w (2:4,i2)=0.d0
                                    Iref(:,i2)=i1
                                 Else
                                    Call BILIN5 (Xp,Yp,X2(i2),Y2(i2),
     .                                            w(1,i2),ier)
                                    Iref(1,i2) = i1   +(j1-1)*M1
                                    Iref(2,i2) = i1+1 +(j1-1)*M1
                                    Iref(3,i2) = i1+1 + j1   *M1
                                    Iref(4,i2) = i1   + j1   *M1
                                 Endif
                              Endif
  500                  Continue
                    Endif
  800        Continue
  900 Continue

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

      Subroutine BILIN5 (xa,ya,x0,y0,w,ier)
c
c Author: H. Petit
c
      Integer*8         ier
      double precision x,x1,x2,x3,x4,y,y1,y2,y3,y4,a21,a22,a31,
     .                a32,a41,
     .                a42,det,xt,yt,x3t,y3t,xi,eta,a,b,c,discr,
     .                x0,y0,
     .                xa(4),ya(4),w(4)

c
c     read(12,*)x1,y1,f1
      x1  = xa(1)
      y1  = ya(1)
c     read(12,*)x2,y2,f2
      x2  = xa(2)
      y2  = ya(2)
c     read(12,*)x3,y3,f3
      x3  = xa(3)
      y3  = ya(3)
c     read(12,*)x4,y4,f4
      x4  = xa(4)
      y4  = ya(4)
      x   = x0
      y   = y0
c The bilinear interpolation problem is first transformed
c to the quadrangle with nodes
c (0,0),(1,0),(x3t,y3t),(0,1)
c and required location (xt,yt)
      a21 = x2-x1
      a22 = y2-y1
      a31 = x3-x1
      a32 = y3-y1
      a41 = x4-x1
      a42 = y4-y1
      det = a21*a42-a22*a41
      If (ABS (det).LT.1e-12) Then
         Goto 999
      Endif
      x3t = (a42*a31-a41*a32)/det
      y3t = (-a22*a31+a21*a32)/det
      xt  = (a42*(x-x1)-a41*(y-y1))/det
      yt  = (-a22*(x-x1)+a21*(y-y1))/det
      If ((x3t.LT..0e0).OR.(y3t.LT..0e0)) Then
         Goto 999
      Endif
      If (ABS (x3t-1.0).LT.1.0e-13) Then
         xi = xt
         If (ABS (y3t-1.0).LT.1.0e-13) Then
            eta = yt
         Else
            If (ABS (1.0+(y3t-1.0)*xt).LT.1.0e-12) Then
               Goto 999
            Else
               eta = yt/(1.0+(y3t-1.0)*xt)
            Endif
         Endif
      Else
         If (ABS (y3t-1.0).LT.1.0e-12) Then
            eta = yt
            If (ABS (1.0+(x3t-1.0)*yt).LT.1.e-12) Then
               Goto 999
            Else
               xi = xt/(1.0+(x3t-1.0)*yt)
            Endif
         Else
            a     = y3t-1.
            b     = 1.0+(x3t-1.0)*yt-(y3t-1.0)*xt
            c     = -xt
            discr = b*b-4.0*a*c
            If (discr.LT.1.0e-12) Then
               Goto 999
            Endif
            xi    = (-b+sqrt(discr))/(2.0*a)
            eta   = ((y3t-1.0)*(xi-xt)+(x3t-1.0)*yt)/(x3t-1.0)
         Endif
      Endif
      w(1) = (1.-xi)*(1.-eta)
      w(2) = xi*(1.-eta)
      w(3) = xi*eta
      w(4) = eta*(1.-xi)
      Return
999   Continue

      ier = 1
      End

c      subroutine GRMAP (f1,n1,f2,n2,iref,w,np,iprint)
cc-----------------------------------------------------------------------
c      Integer         n1,n2,np,i,i1,i2,ifac,iref(np,n2),ip,iprint
c      double precision f1(n1),f2(n2),w(np,n2)
cc-----------------------------------------------------------------------
cc     compute interpolated values for all points on grid 2
cc-----------------------------------------------------------------------
cC      If (iprint.EQ.1) Write (*,*) 'in grmap n1 n2',n1,n2
c      Do 110 i2=1,N2
cc-----------------------------------------------------------------------
cc        special treatment of points on grid 2 that are outside
cc        grid 1; in that case iref(1,i2)=0 AND w(ip,i2)=0 for all ip
cc-----------------------------------------------------------------------
cc        Iref(1,i2)   i1    ifac   F2(i2)*ifac     Result
cc-----------------------------------------------------------------------
cc             0        1      1      F2(i2)        Old value is kept
cc           j,j>0      j      0       0.           F2 is initialized
cc-----------------------------------------------------------------------
c         i      = iref(1,i2)
c         i1     = MAX (i,1)
c         ifac   = 1-i/i1
c         f2(i2) = f2(i2)*ifac
cc
cc        Function values at grid 2 are expressed as weighted average
cc        of function values in Np surrounding points of grid 1
cc-----------------------------------------------------------------------
cC         If (iprint.EQ.1.AND.i2.LE.n2)
cC     .      Write (*,'(1X,A,I6,4(1X,E10.4))') 
cC     .               ' i2 w ',i2,(w(ip,i2),ip=1,np)
c         Do 100 ip=1,Np
c                i      = iref(ip,i2)
c                i1     = MAX (i,1)
cC                If (iprint.EQ.1.AND.I2.le.n2)
cC     .             Write (*,*) ' i1,f1(i1) ',i1,f1(i1)
c                f2(I2) = f2(i2)+w(ip,i2)*f1(I1)
c  100    Continue
c  110 Continue
c      End


!-----------------------------------------------------------------------

      subroutine GRMAP (f1,n1,f2,n2,iref,w)

      integer*8         n1,n2,np,i,i1,i2,ifac,iref(4,n2),ip,iok
      double precision f1(n1),f2(n2),w(4,n2)

!     compute interpolated values for all points on grid 2

      np=4

      do i2=1,n2

!        special treatment of points on grid 2 that are outside
!        grid 1; in that case iref(1,i2)=0 AND w(ip,i2)=0 for all ip
!-----------------------------------------------------------------------
!        Iref(1,i2)   i1    ifac   F2(i2)*ifac     Result
!-----------------------------------------------------------------------
!             0        1      1      F2(i2)        Old value is kept
!           j,j>0      j      0       0.           F2 is initialized

         i      = iref(1,i2)
         i1     = MAX (i,1)
         ifac   = 1-i/i1
!         f2(i2) = f2(i2)*ifac
         f2(i2) = 0.0
         

!        Function values at grid 2 are expressed as weighted average
!        of function values in Np surrounding points of grid 1

         iok = 0
         do ip=1,np
         
            i      = iref(ip,i2)
            i1     = MAX (i,1)
      if ((f1(i1)>-998.999.OR.f1(i1)<-999.001).and.(iref(ip,i2)>0)) then
               f2(i2) = f2(i2)+w(ip,i2)*f1(i1)
               iok = 1
            endif
         enddo
         
         if (iok==0) then
            f2(i2) = -999.0
         endif   

      enddo
      
      

      end


