#include "fintrf.h"
C
#if 0
C     generate with :  mex mxcurvec.f
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
 
      integer*8 np,nt,ncols,nrows

      integer*8 x_pr,y_pr,t_pr,radius_pr
      integer*8 wind_speed_pr,wind_direction_pr,pressure_pr

      double precision, dimension(:), allocatable :: t
      double precision, dimension(:), allocatable :: x
      double precision, dimension(:), allocatable :: y
      double precision, dimension(:), allocatable :: wind_speed
      double precision, dimension(:), allocatable :: wind_direction
      double precision, dimension(:), allocatable :: pressure

      double precision nrows0
      double precision ncols0
      double precision radius
      
      character*256 spwfile
      character*256 refstr

c     Total number of arrows     
      nt = mxGetM(prhs(1))
      np = mxGetM(prhs(4))


      nrows_pr = mxGetPr(prhs(7))
      call mxCopyPtrToReal8(nrows_pr,nrows0,1)
      nrows=int(nrows0)

      ncols_pr = mxGetPr(prhs(8))
      call mxCopyPtrToReal8(ncols_pr,ncols0,1)
      ncols=int(ncols0)

      radius_pr = mxGetPr(prhs(9))
      call mxCopyPtrToReal8(radius_pr,radius,1)


C     Get the string contents (dereference the input integer).
      status = mxGetString(prhs(10), spwfile, 256)

C     Get the string contents (dereference the input integer).
      status = mxGetString(prhs(11), refstr, 256)

c     Allocate

      allocate(t(1:nt))
      allocate(x(1:nt))
      allocate(y(1:nt))

      allocate(wind_speed(1:np))
      allocate(wind_direction(1:np))
      allocate(pressure(1:np))

      t_pr              = mxGetPr(prhs(1))
      x_pr              = mxGetPr(prhs(2))
      y_pr              = mxGetPr(prhs(3))
      wind_speed_pr     = mxGetPr(prhs(4))
      wind_direction_pr = mxGetPr(prhs(5))
      pressure_pr       = mxGetPr(prhs(6))

C     Load the data into Fortran arrays.
      call mxCopyPtrToReal8(t_pr,t,nt)
      call mxCopyPtrToReal8(x_pr,x,nt)
      call mxCopyPtrToReal8(y_pr,y,nt)
      !
      call mxCopyPtrToReal8(wind_speed_pr,wind_speed,np)
      call mxCopyPtrToReal8(wind_direction_pr,wind_direction,np)
      call mxCopyPtrToReal8(pressure_pr,pressure,np)

C     Call the computational subroutine
       call mkspiderweb(nt,nrows,ncols,np,t,x,y,wind_speed,
&         wind_direction,pressure,spwfile,refstr,radius)
     
      deallocate(t)
      deallocate(x)
      deallocate(y)
      deallocate(wind_speed)
      deallocate(wind_direction)
      deallocate(pressure)

      return
      end

      subroutine mkspiderweb(nt,nrows,ncols,np,t,x,y,wind_speed,
&        wind_direction,pressure,spwfile,refstr,radius)

      integer nt,nrows,ncols,it,icol

      double precision x(nt)
      double precision y(nt)
      double precision t(nt)
 
      double precision wind_speed(nt,nrows,ncols)
      double precision wind_direction(nt,nrows,ncols)
      double precision pressure(nt,nrows,ncols)
      
      character*256 spwfile
      character*256 refstr
      double precision pmax
      double precision radius
      
      open(900,file=trim(spwfile))
      
      ! Header

      write(900,'(a)')  'FileVersion    = 1.03'
      write(900,'(a)')  'filetype       = meteo_on_spiderweb_grid'
      write(900,'(a)')  'NODATA_value   = -999.000'
      write(900,'(a,i4)')'n_cols         = ',ncols
      write(900,'(a,i4)')'n_rows         = ',nrows
      write(900,'(a)')  'grid_unit      = m'
      write(900,'(a,f10.1)')  'spw_radius     = ',radius
      write(900,'(a)')  'spw_rad_unit   = m'
      write(900,'(a)')  'n_quantity     = 3'
      write(900,'(a)')  'quantity1      = wind_speed'
      write(900,'(a)')  'quantity2      = wind_from_direction'
      write(900,'(a)')  'quantity3      = p_drop'
      write(900,'(a)')  'unit1          = m s-1'
      write(900,'(a)')  'unit2          = degree'
      write(900,'(a)')  'unit3          = Pa'
      
      do it = 1, nt

         pmax = pressure(it,1,1)

      write(900,'(a,f10.1,a,a,a)')  'TIME           = ',t(it),
&        ' minutes since ',trim(refstr),' +00:00'
      write(900,'(a,f14.4)')  'x_spw_eye      = ',x(it)
      write(900,'(a,f14.4)')  'y_spw_eye      = ',y(it)
      write(900,'(a,f10.1)')  'p_drop_spw_eye = ',pmax
         
         do irow = 1, nrows
            write(900,'(1000f9.2)')(wind_speed(it,irow,icol),
&              icol=1,ncols)
         enddo
         do irow = 1, nrows
            write(900,'(1000f9.2)')(wind_direction(it,irow,icol),
&              icol=1,ncols)
         enddo
         do irow = 1, nrows
            write(900,'(1000f9.2)')(pressure(it,irow,icol),
&              icol=1,ncols)
         enddo
      enddo   
      
      close(900)

      end subroutine


