function wricon(fileOut,bnd,nfs_inf,bndval,add_inf,varargin)

% wricon : Write transport boundary conditions to a bcc (Delft3D) or timser (SIMONA) file

modelType    = EHY_getModelType(fileOut);
[~,fileType] = EHY_getTypeOfModelFile(fileOut);
nopnt        = length(bnd.DATA);
OPT.ipnt     = NaN;
OPT          = setproperty(OPT,varargin);

switch modelType
   case 'd3d'
      nesthd_wricon_bcc    (fileOut,bnd,nfs_inf,bndval,add_inf,'ipnt',OPT.ipnt);
   case 'simona'
      nesthd_wricon_timeser(fileOut,bnd,nfs_inf,bndval,add_inf,'ipnt',OPT.ipnt);
   case 'dfm'
       switch fileType
           
           % Old (HK) format 
           case 'tim'      
               nesthd_wrihyd_dflowfmtim (fileOut,bnd,nfs_inf,bndval,add_inf)
           % New inifile format
           case 'bc'
               if isnan(OPT.ipnt)
                   nesthd_wrihyd_dflowfmbc  (fileOut,bnd,nfs_inf,bndval,add_inf)
               else
                   if OPT.ipnt == 1
                       nesthd_wrihyd_dflowfmbc  (fileOut,bnd,nfs_inf,bndval,add_inf,'first',true ,'ipnt',OPT.ipnt);
                   else
                       nesthd_wrihyd_dflowfmbc  (fileOut,bnd,nfs_inf,bndval,add_inf,'first',false,'ipnt',OPT.ipnt);
                   end
               end
       end
end
