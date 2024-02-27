function mdf = simona2mdf_numerical(S,mdf,name_mdf, varargin)

% siminp2mdf_bathy : Gets numerical parameters out of the parsed siminp file

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'BATHYMETRY'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.BATHYMETRY.GLOBAL')
    global_vars  = siminp_struc.ParsedTree.MESH.BATHYMETRY.GLOBAL;
else
    return
end

%
% The depth definition
%

global_vars = siminp_struc.ParsedTree.MESH.BATHYMETRY.GLOBAL;

if ~simona2mdf_fieldandvalue(global_vars,'DPS_GIVEN')

    %
    % Depths specifief in depth(corner) points
    %

    mdf.dpsopt = 'MAX';
    mdf.dpuopt = 'MEAN';
    if simona2mdf_fieldandvalue(global_vars,'METH_DPS')
        if strcmpi(global_vars.METH_DPS,'MEAN_DPD')
            mdf.dpsopt = 'MEAN';
        elseif strcmpi(global_vars.METH_DPS,'MAX_DPD') || strcmpi(global_vars.METH_DPS,'MAX_DPUV')
            mdf.dpsopt = 'MAX';
        elseif strcmpi(global_vars.METH_DPS,'MIN_DPUV')
           mdf.dpsopt = 'MIN';
        end
    end
else
    mdf.dpsopt = 'DP';
    mdf.dpuopt = 'MIN';
end

if simona2mdf_fieldandvalue(global_vars,'METH_DPUV')
    dryfl_max = strfind(lower(global_vars.METH_DPUV),'max');
    if ~isempty(dryfl_max)
        mdf.dpuopt = 'MAX';
    end
    dryfl_min = strfind(lower(global_vars.METH_DPUV),'min');
    if ~isempty(dryfl_min)
        mdf.dpuopt = 'MIN';
    end
end

%
% drying flooding criterion
%

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'PROBLEM'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.PROBLEM.DRYING')
    drying = siminp_struc.ParsedTree.FLOW.PROBLEM.DRYING;
else
    mdf.dryflc = 0.3; % Simona default value
end

if ~isempty(drying.DEPCRIT)
    mdf.dryflc = drying.DEPCRIT;
end
if ~isempty(drying.THRES_UV_FLOODING)
    mdf.dryflc = drying.THRES_UV_FLOODING;
end

%
% Reset default furuv (does not exist in SIMONA, not a good plan to start with anyway)
%

mdf.forfuv = 'N';
