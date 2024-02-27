function delft3d_wnd_from_knmi_potwind(varargin)
%delft3d_wnd_from_knmi_potwind     script that transforms KNMI hydra file to delft3d *.wnd file
%
%  delft3d_wnd_from_knmi_potwind(fname,ref_datenum)
%
% writes *.wnd file from knmi_hydra file valied for ref_datenum in mdf file
%
%See also: KNMI_POTWIND, DELFT3D_IO_WND, delft3d_tem_from_knmi_etmgeg, delft3d_wnd_from_nc

   OPT.filename   = 'potwind_249_2001';
   OPT.dir        = pwd;
   OPT.refdatenum = []; %datenum(2007,1,1) ; % same as in MDF !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   OPT = setproperty(OPT,varargin{:});

   if ischar(OPT.refdatenum)
      mdf            = delft3d_io_mdf('read',OPT.refdatenum);
      OPT.refdatenum = datenum(mdf.keywords.itdate,'yyyy-mm-dd');
   elseif isempty(OPT.refdatenum)
      error('refdatenum missing')
   end

   W = knmi_potwind(OPT.filename,'calms',0,'variables',0,'pol2cart',1)

%% Negative with respect to reference date not posible

   mask       = W.datenum > OPT.refdatenum;
   W.datenum  = W.datenum(mask);
   W.UP       = W.UP     (mask);
   W.DD       = W.DD     (mask);
   W.UX       = W.UX     (mask);
   W.UY       = W.UY     (mask);

%% Mind that there are NaN's in the direction
  
  mask = (isnan(W.DD));
  
  plot(W.UP(mask))
  ylabel('m/s')
  title('Wind speed when direction is NaN')
  print2screensize([OPT.dir,filesep,filename(OPT.filename),'_after_refdate_',datestr(OPT.refdatenum,30),'_NaN_in_direction.png'])
  
%% Remove nans (of either directory or speed)
%  For Delft3D there is no need to be equidistant in time.

   mask      = find(~isnan(W.UP) & ~isnan(W.DD));
 % W.UX      = interp1(W.datenum(mask),W.UX(mask),W.datenum);
 % W.UY      = interp1(W.datenum(mask),W.UY(mask),W.datenum);
 %[W.DD,W.UP] = CART2POL(W.UX,W.UY);
 % W.DD = deguc2degn(rad2deg(W.DD));
   
   W.datenum  = W.datenum(mask);
   W.UP       = W.UP     (mask);
   W.DD       = W.DD     (mask);

  delft3d_io_wnd('write',[OPT.dir,filesep,filename(OPT.filename),'_after_refdate_',datestr(OPT.refdatenum,30),'_nonan.wnd'],W,'refdatenum',OPT.refdatenum)