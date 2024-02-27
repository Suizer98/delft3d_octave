      function [wl,uu,vv] =  simhsh(runid,istat,nfs_inf,vartype)

      % simhsh : gets water level and/or velocity data from a trih file

%-----------------------------------------------------------------------
%     Function: 1) Read time series (hydrodynamics) from the NEFIS
%                  history file
%
%               2) Converts u- and v-velocities to north and south
%                  velocities
%----------------------------------------------------------------------
      error ('Functionalty of this function is covered by EHY_getmodeldata. Use that function instead');

      wl = [];
      uu = [];
      vv = [];

      deg2rd = pi/180.;

      kmax   = nfs_inf.kmax;
      alfas  = nfs_inf.alfas;
      notims = nfs_inf.notims;

      nfs    = vs_use (runid,'quiet');

      if strcmpi(vartype,'wl') || strcmpi(vartype,'all')

%----------------------------------------------------------------------
%        Get all the waterlevel data
%----------------------------------------------------------------------

         wl       = vs_let(nfs,'his-series',{1  :notims},'ZWL',{istat},'quiet');

      end

      if strcmpi(vartype,'c') || strcmpi(vartype,'all')

%-------------------------------------------------------------------
%        Get velocity data and rotate to obtain north and south velocities
%-------------------------------------------------------------------

         uuu       = vs_let(nfs,'his-series',{1:notims},'ZCURU',{istat; 1:kmax},'quiet');
         vvv       = vs_let(nfs,'his-series',{1:notims},'ZCURV',{istat; 1:kmax},'quiet');

         [uu,vv]   = nesthd_rotate_vector(uuu,vvv,alfas(istat)*deg2rd);
      end
