function mdf=simona2mdf_friction(S,mdf,name_mdf, varargin)

% simona2mdf_friction : gets the initial conditions out of the siminp file

mmax                      = mdf.mnkmax(1);
nmax                      = mdf.mnkmax(2);
friction_u(1:mmax,1:nmax) = 0.;
friction_v(1:mmax,1:nmax) = 0.;

%
% get information out of struc
%

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'PROBLEM' 'FRICTION'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.PROBLEM.FRICTION')
    friction     = siminp_struc.ParsedTree.FLOW.PROBLEM.FRICTION;
else
    return
end

%
% Determine friction type
%

if simona2mdf_fieldandvalue(friction,'GLOBAL.FORMULA')
    if strncmpi(friction.GLOBAL.FORMULA,'Manning' ,3)       ;mdf.roumet='M';end;
    if strncmpi(friction.GLOBAL.FORMULA,'Chezy'   ,3)       ;mdf.roumet='C';end;
    if strncmpi(friction.GLOBAL.FORMULA,'White'   ,3)       ;mdf.roumet='W';end;
    if strncmpi(friction.GLOBAL.FORMULA,'Z0-based',3)       ;mdf.roumet='Z';end;
end

%
% U-Friction
%

if simona2mdf_fieldandvalue(friction,'UDIREC.GLOBAL')
    friction_u                = simona2mdf_getglobaldata(friction.UDIREC.GLOBAL,friction_u);
end
if simona2mdf_fieldandvalue(friction,'UDIREC.LOCAL.BOX')
    friction_u            = simona2mdf_getboxdata   (friction.UDIREC.LOCAL.BOX,friction_u);
end

%
% V-Friction
%

if simona2mdf_fieldandvalue(friction,'VDIREC.GLOBAL')
    friction_v                = simona2mdf_getglobaldata(friction.VDIREC.GLOBAL,friction_v);
end
if simona2mdf_fieldandvalue(friction,'VDIREC.LOCAL.BOX')
    friction_v            = simona2mdf_getboxdata   (friction.VDIREC.LOCAL.BOX,friction_v);
end

%
% Finally write
%

rgh(1).Data = friction_u(1:mmax,1:nmax);
rgh(2).Data = friction_v(1:mmax,1:nmax);
mdf.filrgh  = [name_mdf '.rgh'];
wldep('write',mdf.filrgh,rgh);
mdf.filrgh  = simona2mdf_rmpath(mdf.filrgh);

%
% Remove constant value fields from mdf structure
%

mdf = rmfield(mdf,'ccofu');
mdf = rmfield(mdf,'ccofv');
