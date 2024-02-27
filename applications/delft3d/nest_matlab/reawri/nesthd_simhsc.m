      function [conc] =  simhsc(runid,istat,nfs_inf,l)

      % simhsc : Get transport data out of a trih file

      error ('Functionalty of this function is covered by EHY_getmodeldata. Use that function instead');

%-----------------------------------------------------------------------
%     Function: 1) Read constituents data from the NEFIS
%                  history file (timestep itim)
%----------------------------------------------------------------------

      notims= nfs_inf.notims;
      kmax  = nfs_inf.kmax;

      nfs    = vs_use (runid,'quiet');

%----------------------------------------------------------------------
%     Get all the transport data for constituent l
%----------------------------------------------------------------------

      conc = vs_let(nfs,'his-series',{1:notims},'GRO',{istat;1:kmax;l},'quiet');

