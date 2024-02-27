      function [wl,uu,vv] =  nesthd_hisnch(runid,istat,nfs_inf,vartype)

      % nesthd_hisnch : gets water level and/or velocity data from a DFLOWFM history file
      error ('Functionalty of this function is covered by EHY_getmodeldata. Use that function instead');

      %% Initialisation
      wl = [];
      uu = [];
      vv = [];

      kmax   = nfs_inf.kmax;
      notims = nfs_inf.notims;

      if strcmpi(vartype,'wl') || strcmpi(vartype,'all')
%%       Get the waterlevel data

         wl       = ncread(runid,'waterlevel',[istat 1],[1 Inf]);
      end

      if strcmpi(vartype,'c') || strcmpi(vartype,'all')
%%        Get velocity data and rotate to obtain north and south velocities

         if  nfs_inf.kmax == 1         % depth averaged
             uu       = ncread(runid,'x_velocity',[istat 1]  ,[1 Inf]    )';
             vv       = ncread(runid,'y_velocity',[istat 1]  ,[1 Inf]    )';
         else
             uu       = squeeze(ncread(runid,'x_velocity',[1 istat 1],[Inf 1 Inf]))';
             vv       = squeeze(ncread(runid,'y_velocity',[1 istat 1],[Inf 1 Inf]))';
         end
      end
