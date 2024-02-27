function mdf = simona2mdf_bathy(S,mdf,name_mdf, varargin)

% siminp2mdf_bathy : Gets bathymetry data out of the parsed siminp file

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'DEPTH_CONTROL'});

%
% positive upward or downward
%

sign = 1.0;

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.DEPTH_CONTROL.ORIENTATION')
    upward = strfind(siminp_struc.ParsedTree.DEPTH_CONTROL.ORIENTATION,'upwards');
    if ~isempty(upward)
        sign = -1.0;
    end
end

%
% Get bethymetry related information
%

if isfield(mdf,'mnkmax')
    depth(1:mdf.mnkmax(1),1:mdf.mnkmax(2)) = 0.;
else
    depth = [];
end

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'BATHYMETRY'});

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.BATHYMETRY.GLOBAL')
    global_vars = siminp_struc.ParsedTree.MESH.BATHYMETRY.GLOBAL;

    %
    % get bathymetry values
    %

    depth = simona2mdf_getglobaldata(global_vars,depth);
end

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.BATHYMETRY.LOCAL.BOX')
    depth = simona2mdf_getboxdata(siminp_struc.ParsedTree.MESH.BATHYMETRY.LOCAL.BOX,depth);
end

if isfield(mdf,'depuni') mdf        = rmfield(mdf,'depuni');end
mdf.fildep = [name_mdf '.dep'];
wldep('write',mdf.fildep,sign*depth,'quit');
mdf.fildep = simona2mdf_rmpath(mdf.fildep);
