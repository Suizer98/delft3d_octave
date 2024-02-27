      function [wl,uu,vv] =  sdshsh(filename,istat,nfs_inf,vartype)

      % sdshsh : gets water level and or velocity data from an SDS file
      error ('Functionalty of this function is covered by EHY_getmodeldata. Use that function instead');

%-----------------------------------------------------------------------
%     Function: Read time series from SDS file
%----------------------------------------------------------------------

      wl = [];
      uu = [];
      vv = [];

%----------------------------------------------------------------------
%     Open SDS file
%----------------------------------------------------------------------
      sds      = qpfopen (filename);

      if strcmpi(vartype,'wl') || strcmpi(vartype,'all')
%----------------------------------------------------------------------
%     Get the waterlevel data
%----------------------------------------------------------------------
         wl = waquaio  (sds,[],'wlstat',1:nfs_inf.notims,istat);
      end
      if strcmpi(vartype,'c')  || strcmpi(vartype,'all')
%----------------------------------------------------------------------
%     Get the velocity data
%----------------------------------------------------------------------
         [uu,vv] = waquaio(sds,[],'uv-stat',1:nfs_inf.notims,istat);
      end
