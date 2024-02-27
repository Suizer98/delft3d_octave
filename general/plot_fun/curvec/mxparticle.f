#include "fintrf.h"
C
#if 0
C     generate with :  mex mxparticle.f
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
 
      integer*8 nlhs, nrhs

      integer*8 mxCreateDoubleMatrix, mxGetPr
      integer*8 mxGetM, mxGetN
 
      integer*8 mmax, nmax, np, npg, iopt, ip

      integer*8 xp0_pr,yp0_pr,xp1_pr,yp1_pr
      integer*8 xg_pr,yg_pr,u_pr,v_pr
      integer*8 dt_pr,rndfac_pr
      integer*8 iopt_pr
      
      double precision, dimension(:),   allocatable :: xg
      double precision, dimension(:),   allocatable :: yg
      double precision, dimension(:),   allocatable :: u
      double precision, dimension(:),   allocatable :: v
      double precision, dimension(:),   allocatable :: xp0
      double precision, dimension(:),   allocatable :: yp0
      double precision, dimension(:),   allocatable :: xp1
      double precision, dimension(:),   allocatable :: yp1

      double precision dt,rndfac
      double precision iopt1
      
c     Total number of points     
      np = mxGetM(prhs(1))

c     Grid size mmax and nmax
      mmax = mxGetM(prhs(3))
      nmax = mxGetN(prhs(3))
      npg  = mmax*nmax

c     Allocate

      allocate(xg(1:npg))
      allocate(yg(1:npg))
      allocate(u(1:npg))
      allocate(v(1:npg))

      allocate(xp0(1:np))
      allocate(yp0(1:np))
      allocate(xp1(1:np))
      allocate(yp1(1:np))

c     Create matrix for the return argument.
      plhs(1) = mxCreateDoubleMatrix(np,1,0)
      plhs(2) = mxCreateDoubleMatrix(np,1,0)

      xp0_pr    = mxGetPr(prhs(1))
      yp0_pr    = mxGetPr(prhs(2))
      xg_pr     = mxGetPr(prhs(3))
      yg_pr     = mxGetPr(prhs(4))
      u_pr      = mxGetPr(prhs(5))
      v_pr      = mxGetPr(prhs(6))
      dt_pr     = mxGetPr(prhs(7))
      rndfac_pr = mxGetPr(prhs(8))
      iopt_pr   = mxGetPr(prhs(9))

      xp1_pr    = mxGetPr(plhs(1))
      yp1_pr    = mxGetPr(plhs(2))

c     Load the data into Fortran arrays.

      call mxCopyPtrToReal8(xp0_pr,xp0,np)
      call mxCopyPtrToReal8(yp0_pr,yp0,np)
      call mxCopyPtrToReal8(xg_pr,xg,npg)
      call mxCopyPtrToReal8(yg_pr,yg,npg)
      call mxCopyPtrToReal8(u_pr,u,npg)
      call mxCopyPtrToReal8(v_pr,v,npg)
      call mxCopyPtrToReal8(dt_pr,dt,1)
      call mxCopyPtrToReal8(rndfac_pr,rndfac,1)
      call mxCopyPtrToReal8(iopt_pr,iopt1,1)

      iopt=int(iopt1)

C     Call the computational subroutine
       call mkpart(xp0,yp0,xp1,yp1,np,xg,yg,u,v,
     &              mmax,nmax,dt,rndfac,iopt)     

C     Load the output into a MATLAB array.

      call mxCopyReal8ToPtr(xp1,xp1_pr,np)
      call mxCopyReal8ToPtr(yp1,yp1_pr,np)

      deallocate(xg)
      deallocate(yg)
      deallocate(u)
      deallocate(v)
      deallocate(xp0)
      deallocate(yp0)
      deallocate(xp1)
      deallocate(yp1)

      return
      end

      subroutine mkpart(x0,y0,x1,y1,np,xg,yg,u,v,
     &                  mmax,nmax,dt,rndfac,iopt)

      integer np,mmax,nmax,iopt,npg,i,iprint
      integer nrin(np),nrx(np),nry(np),iflag(np),iref(4,np)
      
      integer code(mmax,nmax)

      double precision x0(np)
      double precision y0(np)
      double precision x1a(np)
      double precision y1a(np)
      double precision x1(np)
      double precision y1(np)
      double precision up(np)
      double precision vp(np)
      double precision xs(np)
      double precision ys(np)
 
      double precision xg(mmax,nmax)
      double precision yg(mmax,nmax)
      double precision u(mmax,nmax)
      double precision v(mmax,nmax)

      double precision w(4,np)

      double precision dt,geofac,pi,latfac,gfac
      double precision umag,rndnr,rndfac
      
      pi = 3.1416
      geofac = 111111.0
      iprint=0

      npg=mmax*nmax
      
      if (iopt==1) then
c        Geographic coordinates
         do i=1,mmax
            do j=1,nmax
               u(i,j) = u(i,j)/(cos(pi*yg(i,j)/180.0)*geofac)
               v(i,j) = v(i,j)/geofac
            enddo
         enddo
      endif
      
      do i=1,mmax
         do j=1,nmax
            if (xg(i,j)<-999.1 .or. xg(i,j)>-998.8) then
               code(i,j) = 1
            else
               code(i,j) = -1
            endif
         enddo
      enddo

c     Compute next point

      call mkmap(code,xg,yg,mmax,nmax,x0,y0,np,xs,ys,nrx,nry,iflag, 
     &               nrin,w,iref,iprint)

      call grmap(u,npg,up,np,iref,w) 
      call grmap(v,npg,vp,np,iref,w) 

      do i=1,np
        rndnr=rnorm()
        x1a(i)=x0(i)+0.5*up(i)*dt
        rndnr=rnorm()
        y1a(i)=y0(i)+0.5*vp(i)*dt
      enddo

      call mkmap(code,xg,yg,mmax,nmax,x1a,y1a,np,xs,ys,nrx,nry,iflag, 
     &               nrin,w,iref,iprint) 

      call grmap(u,np,up,np,iref,w) 
      call grmap(v,np,vp,np,iref,w) 

      do i=1,np
        rndnr=rnorm()
        x1(i)=x0(i)+(up(i)+rndfac*rndnr)*dt
        rndnr=rnorm()
        y1(i)=y0(i)+(vp(i)+rndfac*rndnr)*dt
      enddo

!     Check to see that velocity at this location is not 0.0

      call mkmap(code,xg,yg,mmax,nmax,x1,y1,np,xs,ys,nrx,nry,iflag, 
     &               nrin,w,iref,iprint) 
      call grmap(u,np,up,np,iref,w) 
      call grmap(v,np,vp,np,iref,w) 

      do i=1,np
         umag=sqrt(up(i)*up(i)+vp(i)*vp(i))         
         if (umag<0.001) then
            x1(i)=x0(i)
            y1(i)=y0(i)
         endif
      enddo

      return

      end

      
      Subroutine  HUNT (xx,n,x,jlo)
c
      Integer         n,jlo,jhi,inc,jm
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
      Integer         i,indxt,ir,l,n,j,indx(n)
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
      Integer         n,inout,nonder,i
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
      Integer         i,i1,i2,iin,ip,ipt,j1,lomaxx,lominx,lomnx,lomny,
     .                nin,M1,N1,M1min,M1max,N1min,N1max,N2,inout,ier,
     .                NrX(N2),NrY(N2),iFlag(N2),NrIn(N2),Iref(4,N2),
     .                code(m1,n1),iprint
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
      M1max = M1
      N1min = 1
      N1max = N1
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
                    If (code(i1,j1).GE.0.AND.code(i1+1,j1).GE.0.AND.
     .                  code(i1+1,j1+1).GE.0.AND.code(i1,j1+1).GE.0)
     .                                                              Then
*        Definitie cel
*-----------------------------------------------------------------------
                       Xp(1) = X1(i1,j1)
                       Xp(2) = X1(i1+1,j1)
                       Xp(3) = X1(i1+1,j1+1)
                       Xp(4) = X1(i1,j1+1)
                       Yp(1) = Y1(i1,j1)
                       Yp(2) = Y1(i1+1,j1)
                       Yp(3) = Y1(i1+1,j1+1)
                       Yp(4) = Y1(i1,j1+1)
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
                       Xpmean = .5*(Xpmin+Xpmax)
                       Ypmean = .5*(Ypmin+Ypmax)
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
                                 
                                 Call BILIN5 (Xp,Yp,X2(i2),Y2(i2),
     .                                       w(1,i2),ier)
                                 Iref(1,i2) = i1   +(j1-1)*M1
                                 Iref(2,i2) = i1+1 +(j1-1)*M1
                                 Iref(3,i2) = i1+1 + j1   *M1
                                 Iref(4,i2) = i1   + j1   *M1
                              Endif
  500                  Continue
                    Endif
  800        Continue
  900 Continue

      End


      Subroutine SORT (n,ra,wksp,iwksp)
c
      Integer         j,n,iwksp(n)
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
      Integer         ier
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

      integer         n1,n2,np,i,i1,i2,ifac,iref(4,n2),ip
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

         do ip=1,np
            i      = iref(ip,i2)
            i1     = MAX (i,1)
            if (f1(i1)>-998.999 .OR. f1(i1)<-999.001) then
               f2(i2) = f2(i2)+w(ip,i2)*f1(i1)
            end if
         enddo

      enddo

      end

      FUNCTION rnorm() RESULT( fn_val ) 
!   Generate a random normal deviate using the polar method.
!   Reference: Marsaglia,G. & Bray,T.A. 'A convenient method for generating
!              normal variables', Siam Rev., vol.6, 260-264, 1964.

      IMPLICIT NONE
      REAL  :: fn_val

! Local variables

      REAL            :: u, sum
      REAL, SAVE      :: v, sln
      LOGICAL, SAVE   :: second = .FALSE.
      REAL, PARAMETER :: one = 1.0, vsmall = TINY( one )

      IF (second) THEN
! If second, use the second random number generated on last call

        second = .false.
        fn_val = v*sln

      ELSE
! First call; generate a pair of random normals

        second = .true.
        DO
          CALL RANDOM_NUMBER( u )
          CALL RANDOM_NUMBER( v )
          u = SCALE( u, 1 ) - one
          v = SCALE( v, 1 ) - one
          sum = u*u + v*v + vsmall         ! vsmall added to prevent LOG(zero) / zero
          IF(sum < one) EXIT
        END DO
        sln = SQRT(- SCALE( LOG(sum), 1 ) / sum)
        fn_val = u*sln
      END IF

      RETURN
      END FUNCTION rnorm

