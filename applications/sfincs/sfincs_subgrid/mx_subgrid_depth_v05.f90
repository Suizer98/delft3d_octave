#include "fintrf.h"
#if 0
! Generate with :  mex mx_subgrid_depth_v05.f90
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
      integer*8 d_pr,zmin_pr,zmax_pr,hrep_pr,manning_avg_pr,dhdz_pr
      !
      double precision, dimension(:,:,:), allocatable :: d
      double precision, dimension(:,:,:), allocatable :: manning
      double precision                                :: nbinr
      !
      double precision, dimension(:,:,:),   allocatable :: hrep
      double precision, dimension(:,:,:),   allocatable :: manning_avg
      double precision, dimension(:,:),     allocatable :: dhdz
      double precision, dimension(:,:),     allocatable :: zmin
      double precision, dimension(:,:),     allocatable :: zmax
      !
      integer*8                        :: dims_pr
      integer*8                        :: nbin_pr
      integer*8                        :: manning_pr
      integer*8, dimension(2)          :: dims2
      integer*8, dimension(3)          :: dims3
      integer*8, dimension(3)          :: dims3out
      integer*4                        :: classid
      !     
      ! open(800,file='out01.txt')
      !
      !     Dimensions
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
      ! Numbers of bins 
      !
      nbin_pr    = mxGetPr(prhs(3))
      !      
      call mxCopyPtrToReal8(nbin_pr,nbinr,1)
      !      
      nbin=int(nbinr)
      !           
      dims3out(1)=nmax
      dims3out(2)=mmax
      dims3out(3)=nbin
      !      
      ! Allocate
      !      
      allocate(d(1:nmax,1:mmax,1:np))
      allocate(manning(1:nmax,1:mmax,1:np))
      allocate(hrep(1:nmax,1:mmax,1:nbin))      
      allocate(dhdz(1:nmax,1:mmax))      
      allocate(manning_avg(1:nmax,1:mmax,1:nbin))      
      allocate(zmin(1:nmax,1:mmax))      
      allocate(zmax(1:nmax,1:mmax))      
      !      
      ! Create matrix for the return argument.
      !      
      classid=mxClassIDFromClassName('double')
      plhs(1) = mxCreateNumericArray(3, dims3out, classid, 0)
      plhs(2) = mxCreateNumericArray(2, dims2, classid, 0)
      plhs(3) = mxCreateNumericArray(3, dims3out, classid, 0)
      plhs(4) = mxCreateNumericArray(2, dims2, classid, 0)
      plhs(5) = mxCreateNumericArray(2, dims2, classid, 0)
      !      
      d_pr       = mxGetPr(prhs(1))
      manning_pr = mxGetPr(prhs(2))
      !      
      hrep_pr = mxGetPr(plhs(1))
      dhdz_pr = mxGetPr(plhs(2))
      manning_avg_pr = mxGetPr(plhs(3))
      zmin_pr = mxGetPr(plhs(4))
      zmax_pr = mxGetPr(plhs(5))
      !      
      ! Load the data into Fortran arrays.
      call mxCopyPtrToReal8(d_pr,d,nmax*mmax*np)
      call mxCopyPtrToReal8(manning_pr,manning,nmax*mmax*np)
      !      
      ! Call the computational subroutine
      !      
      call subgrid_depths(nmax,mmax,np,nbin,d,manning,hrep,dhdz,manning_avg,zmin,zmax)
      !              
      ! Load the output into a MATLAB array.
      !              
      call mxCopyReal8ToPtr(hrep,hrep_pr,nmax*mmax*nbin)
      call mxCopyReal8ToPtr(dhdz,dhdz_pr,nmax*mmax)
      call mxCopyReal8ToPtr(manning_avg,manning_avg_pr,nmax*mmax*nbin)
      call mxCopyReal8ToPtr(zmin,zmin_pr,nmax*mmax)
      call mxCopyReal8ToPtr(zmax,zmax_pr,nmax*mmax)
      !              
      deallocate(d)
      deallocate(hrep)
      deallocate(manning_avg)
      deallocate(manning)
      deallocate(dhdz)
      deallocate(zmin)
      deallocate(zmax)
      !              
      !      close(800)
      !                    
      return
      !                    
   end

   subroutine subgrid_depths(nmax,mmax,npix,nbin,d,manning,hrep,dhdz,manning_avg,zmin,zmax)
      !
      integer nmax
      integer mmax
      integer npix
      integer nbin
      double precision d(nmax,mmax,npix)
      double precision manning(nmax,mmax,npix)
      double precision manning_avg(nmax,mmax,nbin)
      double precision zmin(nmax,mmax)
      double precision zmax(nmax,mmax)
      double precision zmin_a
      double precision zmin_b
      double precision zmax_a
      double precision zmax_b
      double precision hrep(nmax,mmax,nbin)
      double precision dhdz(nmax,mmax)
      double precision dbin
      double precision q
      double precision h
      double precision zb
      double precision h10
      double precision zadd
      double precision dsum
      double precision dsum2
      double precision hrepsum
      double precision manning_sum
      double precision n_avg_a
      double precision n_avg_b
      double precision hrep_a
      double precision hrep_b
      !      
      real*8, dimension(:), allocatable :: dd0_a 
      real*8, dimension(:), allocatable :: dd0_b 
      real*8, dimension(:), allocatable :: dd_a 
      real*8, dimension(:), allocatable :: dd_b 
      real*8, dimension(:), allocatable :: manning_a 
      real*8, dimension(:), allocatable :: manning_b 
      real*8, dimension(:), allocatable :: manning0_a 
      real*8, dimension(:), allocatable :: manning0_b 
      integer, dimension(:), allocatable :: indx 
      !
      integer n
      integer m
      integer ibin
      integer j1
      integer j2
      integer nsum
      integer npreal
      integer npreal_a
      integer npreal_b
      ! 
      integer mmx
      !       
      allocate(dd0_a(npix/2))
      allocate(dd0_b(npix/2))      
      allocate(dd_a(npix/2))
      allocate(dd_b(npix/2))      
      allocate(manning_a(npix/2))
      allocate(manning_b(npix/2))
      allocate(manning0_a(npix/2))
      allocate(manning0_b(npix/2))
      allocate(indx(npix/2))
      !       
      ! open(801,file='mx_subgrid_depth.txt')
      ! 
      ! write(801,*)nmax,mmax,nbin,np
      !       
      dsum2       = 0.0
      hrepsum     = 0.0
      !
      hrep        = 0.0
      manning_avg = 0.0
      dhdz        = 1.0
      zmin        = 0.0
      zmax        = 0.0
      !
      ! Loop through all cells
      !
      do n = 1, nmax
         do m = 1, mmax
            !
            ! First make two arrays with depth and manning on both sides 
            !
            ! Side A
            !
            zmin_a =  1.0e6
            zmax_a = -1.0e6
            !
            npreal_a = 0   ! Number of pixels on side A with an actual value
            j        = 0
            dd0_a    = 0.0 ! Pixel elevation of all pixels
            !
            ! Store all pixels in vector
            !
            do ip = 1, npix/2
               !
               j = j + 1
               !
               ! Count the number of pixels with a real value and determine minimum and maximum elevation on this side
               !
               if (d(n,m,ip)<90000.0) then
                  npreal_a = npreal_a + 1
                  zmin_a   = min(zmin_a, d(n,m,ip))
                  zmax_a   = max(zmax_a, d(n,m,ip))
               endif   
               !
               dd0_a(j)      = d(n,m,ip)
               manning0_a(j) = manning(n,m,ip) ! This array must always have 'normal' values (i.e. no NaNs, or -999.0)
               !
            enddo
            !
            ! If only fill values, go to next cell
            !
            if (npreal_a==0) cycle         
            !
            ! Same for Side B
            !
            zmin_b =  1.0e6
            zmax_b = -1.0e6
            !            
            npreal_b = 0
            j        = 0
            do ip = npix/2 + 1, npix
               !
               j = j + 1
               !
               ! Count the number of pixels with a real value and determine minimum and maximum elevation on this side
               !
               if (d(n,m,ip)<90000.0) then
                  npreal_b = npreal_b + 1
                  zmin_b   = min(zmin_b, d(n,m,ip))
                  zmax_b   = max(zmax_b, d(n,m,ip))
               endif   
               !
               dd0_b(j)      = d(n,m,ip)
               manning0_b(j) = manning(n,m,ip)
               !
            enddo
            !
            ! If only fill values, go to next cell
            !                          
            if (npreal_b==0) cycle         
            !
            ! Sort Side A based on elevation and make sure Manning's n is also sorted
            !
            call sort(npix/2, dd0_a, dd_a, indx)
            !
            do ip = 1, npix/2
               manning_a(ip) = manning0_a(indx(ip))
            enddo
            !
            ! Sort Side B based on elevation and make sure Manning's n is also sorted
            !
            call sort(npix/2, dd0_b, dd_b, indx)
            !
            do ip = 1, npix/2
               manning_b(ip) = manning0_b(indx(ip))
            enddo
            !
            ! Determine zmin and zmax for this uv point (takes highest elevation of A and B)
            !
            zmin(n, m) = max(zmin_a, zmin_b)
            zmax(n, m) = max(zmax_a, zmax_b)
            !            
            ! Make sure zmax is always a bit larger than zmin
            !
            if (zmax(n, m)<zmin(n, m) + 0.01) then
               zmax(n, m) = zmax(n, m) + 0.01
            endif
            !
            ! Determine bin size
            !
            dbin = (zmax(n, m) - zmin(n, m))/nbin
            dbin = max(dbin, 1.0e-9)
            !   
            ! Loop through bins
            !
            do ibin = 1, nbin                   
               !            
               ! Top of bin
               !
               zb = zmin(n, m) + ibin*dbin
               !            
               ! Side A
               !
               manning_sum = 0.0
               nsum        = 0
               q           = 0.0
               !
               ! Loop through real pixels to sum q and Manning's n
               ! 
               do j1 = 1, npreal_a
                  !
                  h = max(zb - dd_a(j1), 0.0)
                  q = q + h**(5.0/3.0)/manning_a(j1)
                  !
                  if (zb>dd_a(j1)) then
                     !
                     nsum = nsum + 1
                     manning_sum = manning_sum + manning_a(j1)
                     !
                  endif   
                  !
               enddo
               !
               ! Determine average q of all points (wet and dry)
               !
               q       = q/(npix/2)
               !
               ! Determine Manning's n of wet points
               !
               n_avg_a = manning_sum/nsum
               !
               ! And finally compute hrep for this side
               !
               hrep_a  = (q*n_avg_a)**(3.0/5.0)
               !
               ! Side B
               !
               manning_sum = 0.0
               nsum        = 0
               q           = 0.0
               !
               ! Loop through real pixels to sum q and Manning's n
               ! 
               do j1 = 1, npreal_b
                  !
                  h = max(zb - dd_b(j1), 0.0)
                  q = q + h**(5.0/3.0)/manning_b(j1)
                  !
                  if (zb>dd_b(j1)) then
                     nsum = nsum + 1
                     manning_sum = manning_sum + manning_b(j1)
                  endif   
                  !
               enddo
               !
               ! Determine average q of all points (wet and dry)
               !
               q       = q/(npix/2)
               !
               ! Determine Manning's n of wet points
               !
               n_avg_b = manning_sum/nsum
               !
               ! And finally compute hrep for this side
               !
               hrep_b  = (q*n_avg_b)**(3.0/5.0)
               !               
               ! Now take minimum value of cells A and B
               !               
               if (hrep_a<=hrep_b) then
                  !
                  hrep(n,m,ibin)        = hrep_a
                  manning_avg(n,m,ibin) = n_avg_a
                  !
               else
                  !               
                  hrep(n,m,ibin)        = hrep_b
                  manning_avg(n,m,ibin) = n_avg_b
                  !
               endif
               !
            enddo
            !
            ! Now compute slope dhdz above zmax (I really think this should just be set to 1.0)
            !
            zadd = 5.0 ! elevation added to zmax to get the level from which we determine dhdz (bit arbitrary ...)
            zb   = zmax(n,m) + zadd
            q    = 0.0
            !
            ! Side A
            !
            do j1 = 1, npreal_a
               h = max(zb - dd_a(j1), 0.0)
               q = q + h**(5.0/3.0)/manning_a(j1)
            enddo
            !
            ! Side A
            !
            do j1 = 1, npreal_b
               h = max(zb - dd_b(j1), 0.0)
               q = q + h**(5.0/3.0)/manning_b(j1)
            enddo
            !
            q          = q/npix
            h10        = (q*manning_avg(n,m,nbin))**(3.0/5.0)
            dhdz(n,m)  = (h10 - hrep(n,m,nbin)) / zadd
!            dhdz(n,m)  = 1.0
            !                        
         enddo
      enddo
      !
      ! close(801)
      !
      return
      !
      end subroutine


      subroutine SORT(n,ra,wksp,iwksp)
      !
      integer*8         j,n,iwksp(n)
      double precision          ra(n),wksp(n)
      !
      call INDEXX (n,ra,iwksp)
      !
      do j = 1, n
         wksp(j) = ra(iwksp(j))
      enddo   
      !
      end subroutine
      

      subroutine INDEXX(n,arrin,indx)
      !
      integer*8         i,indxt,ir,l,n,j,indx(n)
      double precision q,arrin(n)
      !
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
