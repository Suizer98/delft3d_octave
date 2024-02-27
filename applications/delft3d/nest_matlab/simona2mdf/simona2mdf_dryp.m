function mdf = simona2mdf_dryp(S,mdf,name_mdf, varargin);

% simona2mdf_dryp : gets dry points out of the parsed siminp tree

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'DRYPOINTS' 'DAMPOINTS'});

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.DRYPOINTS.DAMPOINTS.COORDINATES.DAMCOOR')

   drypoints  = siminp_struc.ParsedTree.MESH.DRYPOINTS.DAMPOINTS.COORDINATES.DAMCOOR;
   drypoints  = reshape(drypoints,2,[])';
   file       = [name_mdf '.dry'];
   delft3d_io_dry('write',file,drypoints(:,1),drypoints(:,2));
   mdf.fildry = simona2mdf_rmpath(file);
end



