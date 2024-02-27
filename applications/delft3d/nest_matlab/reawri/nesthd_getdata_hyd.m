      function [wl,uu,vv] =  getdata_hyd(fileInp,istat,nfs_inf,vartype)

      error ('Functionalty of this function is covered by EHY_getmodeldata. Use that function instead');

      % getdata_hyd : gets water level and/or velocity data from trih or SDS file

      wl = [];
      uu = [];
      vv = [];

      modelType = EHY_getModelType(fileInp);

      switch modelType
         case 'd3d'
             [wl,uu,vv] = nesthd_simhsh(fileInp,istat,nfs_inf,vartype);
         case 'simona'
             [wl,uu,vv] = nesthd_sdshsh(fileInp,istat,nfs_inf,vartype);
         case 'dfm'
             [wl,uu,vv] = nesthd_hisnch(fileInp,istat,nfs_inf,vartype);
      end
