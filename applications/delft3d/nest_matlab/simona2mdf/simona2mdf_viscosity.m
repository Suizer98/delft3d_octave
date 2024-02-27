function mdf=simona2mdf_viscosity(S,mdf,name_mdf, varargin)

% simona2mdf_viscosity : gets the iviscosity information (horizontal) out of the siminp file


%
% get information out of struc
%
turbulence  = [];
problem     = [];

OPT.nesthd_path = getenv_np('nesthd_path');
OPT             = setproperty(OPT,varargin{1:end});

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'TURBULENCE_MODEL'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.TURBULENCE_MODEL')
    turbulence   = siminp_struc.ParsedTree.TURBULENCE_MODEL;
end

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'PROBLEM'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.PROBLEM')
    problem      = siminp_struc.ParsedTree.FLOW.PROBLEM;
end

%
% Check for HLES
%

if ~isempty(turbulence)
    if simona2mdf_fieldandvalue(turbulence,'HLES')
        siminp2mdf_warning('HLES not implemented yet');
    end
end

%
% Fill viscosity values/arrays and write (in case of space varying values)
%
mdf.vicouv = 0.; % specified as space varying values
mdf.dicouv = 0.; % specified as space varying values

mmax       = mdf.mnkmax(1);
nmax       = mdf.mnkmax(2);

if ~simona2mdf_fieldandvalue(problem,'VISCOSITY') && ~simona2mdf_fieldandvalue(problem,'HOR_VISCOSITY')
    vico(1:mmax,1:nmax) = 10.0; % Insane default value
elseif simona2mdf_fieldandvalue(problem,'VISCOSITY.EDDYVISCOSIT')
    vico(1:mmax,1:nmax) = problem.VISCOSITY.EDDYVISCOSIT;
else
    %
    % Space varying
    %

    vico(1:mmax,1:nmax) = 0.0;

    if simona2mdf_fieldandvalue(problem,'HOR_VISCOSITY.GLOBAL')
        vico = simona2mdf_getglobaldata (problem.HOR_VISCOSITY.GLOBAL,vico);
    end
    if simona2mdf_fieldandvalue(problem,'HOR_VISCOSITY.LOCAL.BOX')
        vico = simona2mdf_getboxdata(problem.HOR_VISCOSITY.LOCAL.BOX,vico);
    end
end

%
% Get diffusivity ( if salinity is active)
%

dico(1:mmax,1:nmax) = -999.999;
if strcmpi(mdf.sub1(1:1),'s')
    siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'GENERAL' 'DIFFUSION'});
    if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.GENERAL.DIFFUSION')
        diff = siminp_struc.ParsedTree.GENERAL.DIFFUSION;
        if simona2mdf_fieldandvalue(diff,'GLOBAL')
            dico = simona2mdf_getglobaldata (diff.GLOBAL,dico);
        end
        if simona2mdf_fieldandvalue(diff,'LOCAL.BOX')
            dico = simona2mdf_getboxdata(diff.LOCAL.BOX,dico);
        end
    end
end

%
% write file
%

edy(1).Data = vico(1:mmax,1:nmax);
edy(2).Data = dico(1:mmax,1:nmax);
mdf.filedy = [name_mdf '.edy'];
wldep ('write',mdf.filedy,edy);
mdf.filedy = simona2mdf_rmpath(mdf.filedy);

