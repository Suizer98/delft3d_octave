function wrihyd(fileOut,bnd,nfs_inf,bndval,add_inf,varargin)

% wrihyd : writes hydrodynamic bc to either Delft3D-Flow format or SIMONA format
modelType    = EHY_getModelType      (fileOut);
[~,fileType] = EHY_getTypeOfModelFile(fileOut);
nopnt        = length(bnd.DATA);
OPT.ipnt   = NaN;
OPT        = setproperty(OPT,varargin);
openFile   = false;

switch modelType
   case 'd3d'
       nesthd_wrihyd_bct   (fileOut,bnd,nfs_inf,bndval,add_inf,'ipnt',OPT.ipnt);
   case 'simona'
      nesthd_wrihyd_timeser(fileOut,bnd,nfs_inf,bndval,add_inf,'ipnt',OPT.ipnt);
   case 'dfm'
       switch fileType
           
           % Old (HK) format 
           case 'tim'             
               nesthd_wrihyd_dflowfmtim (fileOut,bnd,nfs_inf,bndval,add_inf                 ,'ipnt',OPT.ipnt);
           % New inifile format
           case 'bc'
               if OPT.ipnt == 1 openFile = true; end
               nesthd_wrihyd_dflowfmbc  (fileOut,bnd,nfs_inf,bndval,add_inf,'first',openFile,'ipnt',OPT.ipnt);
       end
end
