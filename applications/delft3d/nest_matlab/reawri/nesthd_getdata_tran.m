      function [conc] =  getdata_tran(fileInp,istat,nfs_inf,l)

      % getdata_tran : Get concentration data out of a trih or SDS file

      error ('Functionalty of this function is covered by EHY_getmodeldata. Use that function instead');

      conc = [];

      modelType = EHY_getModelType(fileInp);

      switch modelType
         case 'd3d'
            [conc] = nesthd_simhsc(fileInp,istat,nfs_inf,l);
         case 'simona'
            [conc] = nesthd_sdshsc(fileInp,istat,nfs_inf,l);
         case 'dfm'
            [conc] = nesthd_hisncc(fileInp,istat,nfs_inf,l);
      end
