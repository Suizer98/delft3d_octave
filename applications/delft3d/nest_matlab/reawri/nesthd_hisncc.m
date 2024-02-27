      function [conc] = nesthd_hisncc(filename,istat,nfs_inf,l)

      % nesthd_hisncc : gets concentrations from DFLOWFM history file
      error ('Functionalty of this function is covered by EHY_getmodeldata. Use that function instead');

      %% Initialisation
      kmax   = nfs_inf.kmax;
      notims = nfs_inf.notims;

      %% Variables on his file
      Info = ncinfo(filename);
      Vars = {Info.Variables.Name};
      i_conc = find(strcmpi(Vars,strtrim(nfs_inf.namcon(l,1:20)))==1);

%%    Get Concentration data
      if  nfs_inf.kmax == 1         % depth averaged
          conc = ncread(filename,Vars{i_conc},[istat 1]  ,[1 Inf]    )';
      else
          conc = squeeze(ncread(filename,Vars{i_conc},[1 istat 1],[Inf 1 Inf]))';
      end
