#include "fintrf.h"
!
#if 0
! Generate with :  mex mx_subgrid_volumes_v05.f90
! Make sure to remove the /fixed compiler option in c:\Users\ormondt\AppData\Roaming\MathWorks\MATLAB\R2020a\mex_FORTRAN_win64.xml
#endif
!     This is a MEX file for MATLAB.
!     Copyright 1984-2004 The MathWorks, Inc. 
!     $Revision: 1.12.2.1 $
      
   subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      !
      !-----------------------------------------------------------------------
      !     (pointer) Replace integer by integer*8 on 64-bit platforms
      !
      !      mwpointer plhs(*), prhs(*)
      !      mwpointer mxCreateDoubleMatrix
      !      mwpointer mxGetPr
      !      mwpointer x2_pr,y2_pr,x1_pr,y1_pr,u_pr,v_pr
      !      mwpointer dt_pr,nt_pr,hdtck_pr,arthck_pr,xp_pr,yp_pr    
      !-----------------------------------------------------------------------
      !
      integer*8 plhs(*), prhs(*)
      !
      integer*8 nlhs, nrhs, ii
      !
      integer*8 mxCreateDoubleMatrix, mxGetPr
      integer*8 mxGetM, mxGetN
      ! 
      integer*8 nmax, mmax, np, nbin
      !
      integer*8 d_pr,area_pr,zmin_pr,zmax_pr,volmax_pr,depth_pr
      !
      double precision, dimension(:,:,:),   allocatable :: d
      double precision, dimension(:,:),     allocatable :: area
      double precision                                  :: dx
      double precision                                  :: dy
      double precision                                  :: mxsteep
      double precision                                  :: nbinr
      !
      double precision, dimension(:,:),     allocatable :: zmin
      double precision, dimension(:,:),     allocatable :: zmax
      double precision, dimension(:,:),     allocatable :: volmax
      double precision, dimension(:,:,:),   allocatable :: depth
      !
      integer*8                                         :: dims_pr
      integer*8                                         :: dx_pr
      integer*8                                         :: dy_pr
      integer*8                                         :: mxsteep_pr
      integer*8                                         :: nbin_pr
      integer*8, dimension(2)                           :: dims2
      integer*8, dimension(3)                           :: dims3
      integer*8, dimension(3)                           :: dims3out
      integer*4                                         :: classid
      !     
!      open(800,file='out01.txt')
      !
      ! Dimensions
      !
      dims_pr = mxGetDimensions(prhs(1))
      call mxCopyPtrToReal8(dims_pr,dims3,3)
      !      
      nmax = dims3(1)
      mmax = dims3(2)
      np   = dims3(3)
      !      
      dims2(1) = nmax
      dims2(2) = mmax
      !      
      !     Numbers of bins 
      !      
      nbin_pr    = mxGetPr(prhs(3))
      dx_pr      = mxGetPr(prhs(4))
      dy_pr      = mxGetPr(prhs(5))
      mxsteep_pr = mxGetPr(prhs(6))
      !      
      call mxCopyPtrToReal8(nbin_pr,nbinr,1)
      call mxCopyPtrToReal8(dx_pr,dx,1)
      call mxCopyPtrToReal8(dy_pr,dy,1)
      call mxCopyPtrToReal8(mxsteep_pr,mxsteep,1)
      !      
      nbin=int(nbinr)
      !           
      dims3out(1)=nmax
      dims3out(2)=mmax
      dims3out(3)=nbin
      !      
      !     Allocate
      !      
      allocate(d(1:nmax,1:mmax,1:np))
      allocate(area(1:nmax,1:mmax))
      allocate(zmin(1:nmax,1:mmax))
      allocate(zmax(1:nmax,1:mmax))
      allocate(depth(1:nmax,1:mmax,1:nbin))
      allocate(volmax(1:nmax,1:mmax))
      !      
      !     Create matrix for the return argument.
      !      
      classid=mxClassIDFromClassName('double')
      plhs(1) = mxCreateNumericArray(2, dims2, classid, 0)
      plhs(2) = mxCreateNumericArray(2, dims2, classid, 0)
      plhs(3) = mxCreateNumericArray(2, dims2, classid, 0)
      plhs(4) = mxCreateNumericArray(3, dims3out, classid, 0)
      !
      d_pr     = mxGetPr(prhs(1))
      area_pr  = mxGetPr(prhs(2))
      !
      zmin_pr   = mxGetPr(plhs(1))
      zmax_pr   = mxGetPr(plhs(2))
      volmax_pr = mxGetPr(plhs(3))
      depth_pr  = mxGetPr(plhs(4))
      !
      !     Load the data into Fortran arrays.
      !
      call mxCopyPtrToReal8(d_pr,d,nmax*mmax*np)
      call mxCopyPtrToReal8(area_pr,area,nmax*mmax)
      !
      !     Call the computational subroutine
      !
      call subgrid_volumes(nmax,mmax,np,nbin,dx,dy,d,zmin,zmax,volmax,depth,area,mxsteep)
      !           
      !     Load the output into a MATLAB array.
      !
      call mxCopyReal8ToPtr(zmin,zmin_pr,nmax*mmax)
      call mxCopyReal8ToPtr(zmax,zmax_pr,nmax*mmax)
      call mxCopyReal8ToPtr(volmax,volmax_pr,nmax*mmax)
      call mxCopyReal8ToPtr(depth,depth_pr,nmax*mmax*nbin)
      !
      deallocate(zmin)
      deallocate(zmax)
      deallocate(volmax)
      deallocate(d)
      deallocate(depth)
      deallocate(area)
      !
!      close(800)
      !      
      return
      !
      end subroutine


   subroutine subgrid_volumes(nmax,mmax,np,nbin,dx,dy,d,zmin,zmax,volmax,depth,area,mxsteep)
      !
      integer nmax
      integer mmax
      integer np
      integer nbin
      double precision dx
      double precision dy
      double precision d(nmax,mmax,np)
      double precision zmin(nmax,mmax)
      double precision zmax(nmax,mmax)
      double precision area(nmax,mmax)
      double precision volmax(nmax,mmax)
      double precision depth(nmax,mmax,nbin)
      double precision dd0(np)
      double precision dd(np)
      double precision vol(np)
      double precision lev(np)
      integer indx(np)
      double precision a
      double precision vvv
      double precision ddd
      double precision mxsteep
      double precision maxdzdv
      double precision volmax1
      double precision dv
      double precision dep(nbin+1)
      double precision dzdv(nbin)
      double precision dz(nbin)
      double precision vvr(nbin+1)
      double precision vvru
      double precision dzdv1
      double precision vv
      double precision dp
      double precision bottom
      !
      integer n
      integer m
      integer ibin
      integer j1
      integer j2
      integer npreal
      !      
      zmin   = 99999.0
      zmax   = 99999.0
      depth  = 0.0
      volmax = 0.0
      bottom = -20.0
      !
!      open(801,file='out02.txt')
      !
      do n=1,nmax
         do m=1,mmax
            !            
            ! Store pixels in vector and count number of 'real' points
            !
            npreal = 0
            !                        
            do ip=1,np
               if (d(n,m,ip)<90000.0) then
                  npreal = npreal + 1
               endif   
               dd0(ip)=d(n,m,ip)
            enddo
            !
            ! Next cell if no real points are found
            !
            if (npreal<2) cycle            
            !
            ! Sort by depth
            !
            call sort(np,dd0,dd,indx)
            !
            ! Determine zmin and zmax for this cell
            !
            zmin(n,m) = dd(1)
            zmax(n,m) = dd(npreal)
            !
            ! Pixel area
            !
            a = area(n,m)/np
            !
            ! Loop through pixels to compute hypsometric curve
            !
            ! Using very large depth gives problems with single precision calculations.
            ! So set the elevation to at least -20.0. In reality, water levels should never drop below this.
            !
            vol = 0.0
            lev = 0.0
            !
            vol(1) = 0.0
            lev(1) = max(zmin(n,m), bottom)
            !
            do j1 = 2, npreal
               !
               lev(j1) = max(dd(j1), bottom)
               vvv = 0.0
               !
               do j2 = 1, j1
                  vvv = vvv + (lev(j1) - max(dd(j2), bottom))*a
               enddo
               !
               vol(j1) = vvv
               vol(j1) = max(vol(j1), vol(j1 - 1) + 1.0e-6)
               !
            enddo
            !
            ! Total wet volume between zmin and zmax
            !            
            volmax(n,m) = vol(npreal)
            !
            ! Volume bin size
            !
            volbin      = volmax(n,m)/nbin
            !
            ! Interpolate hypsometric curve to equidistant volume bins
            !
            do ibin = 1, nbin - 1
               !
               vvv = ibin*volbin
               call interp1(vol,lev,vvv,ddd,np)
               depth(n,m,ibin) = ddd
               !
            enddo
            !
            ! Set depth at top level
            !
            depth(n,m,nbin) = lev(npreal)
            !
         enddo
      enddo
      !      
      ! Now smooth extremely steep slopes dz/dvol
      !
      do n = 1, nmax
         do m = 1, mmax
            !
            volmax1 = volmax(n, m)/area(n, m)
            dv      = volmax1/nbin
            maxdzdv = 0.0
            dep(1) = max(zmin(n,m), bottom)
            !
            ! Determine maximum steepness to see if smoothing is needed
            !
            do ibin = 1, nbin            
               dep(ibin + 1) = depth(n,m,ibin)
               dz(ibin)      = dep(ibin + 1) - dep(ibin)
               dzdv(ibin)    = dz(ibin)/max(dv, 0.001)
               maxdzdv       = max(dzdv(ibin), maxdzdv)  
            enddo
            !
            if (maxdzdv>mxsteep) then
               !            
               ! Need to adjust profile
               !
               do ibin = 1, nbin + 1
                  vvr(ibin) = (ibin-1)*dv
               enddo
               !
               do ibin = 1, nbin
                  ! 
                  ! Set vvru in this bin to be higher than in bin below
                  vvru  =  max(vvr(ibin + 1), vvr(ibin) + 1.0e-9)
                  dzdv1 = dz(ibin)/(vvru - vvr(ibin))
                  !
                  if (dzdv1>mxsteep) then
                     !
                     ! New volume in bin above
                     vvr(ibin + 1) = vvr(ibin) + dz(ibin)/mxsteep
                     !
                  endif
                  !
               enddo
               !    
               ! New volumes (multiply by cell area again)
               !
               do ibin = 1, nbin + 1
                  vvr(ibin)   = vvr(ibin)*area(n, m)
               enddo   
               !
               volmax(n,m) = vvr(nbin + 1)
               dv          = volmax(n,m)/nbin              
               !
               ! Now interpolate again
               !    
               do ibin = 1, nbin
                  vv = ibin*dv                  
                  call interp1(vvr, dep, vv, dp, nbin + 1)
                  depth(n,m,ibin) = dp
               enddo   
               !   
            endif            
         enddo
      enddo            
      !
      ! close(801)
      !      
      return
      !
   end subroutine


   subroutine interp1(x1,y1,x2,y2,n)

      integer*8         j,n
      double precision  x1(n),y1(n)
      double precision  x2,y2,eps

      eps = 1.0e-6
      
      do j = 1, n - 1
         if (x1(j + 1) + eps >= x2) then
            y2 = y1(j) + (y1(j + 1) - y1(j))*(x2 - x1(j))/(x1(j + 1) - x1(j))
            exit
         endif
      enddo

      end

      subroutine SORT (n,ra,wksp,iwksp)

      Integer*8         j,n,iwksp(n)
      double precision          ra(n),wksp(n)

      Call INDEXX (n,ra,iwksp)
      Do 120 j=1,n
             wksp(j) = ra(iwksp(j))
  120 Continue
      End
      

      Subroutine INDEXX (n,arrin,indx)

      Integer*8         i,indxt,ir,l,n,j,indx(n)
      double precision q,arrin(n)

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
