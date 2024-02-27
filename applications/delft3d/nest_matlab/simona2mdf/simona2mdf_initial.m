function mdf=simona2mdf_initial(S,mdf,name_mdf, varargin)

% simona2mdf_initial : gets the initial conditions out of the siminp file (always write to inital condition file)

mmax                        = mdf.mnkmax(1);
nmax                        = mdf.mnkmax(2);
kmax                        = mdf.mnkmax(3);
zeta0(1:mmax,1:nmax,1     ) = 0.;
u0   (1:mmax,1:nmax,1:kmax) = 0.;
v0   (1:mmax,1:nmax,1:kmax) = 0.;
s0                          = [];

%
% get information out of struc
%

OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{1:end});

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'FLOW' 'FORCINGS' 'INITIAL'});
if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.FLOW.FORCINGS.INITIAL')
    initial      = siminp_struc.ParsedTree.FLOW.FORCINGS.INITIAL;
else
    return
end

%
% first some warnings
%

if ~isempty(initial.READ_FROM)
    simona2mdf_message('READ_FROM (initial conditions) not supported','Window','SIMONA2MDF Warning','Close',true,'n_sec',10);
end
if ~isempty(initial.COMPUTE)
    simona2mdf_message('COMPUTE (initial conditions) not supported','Window','SIMONA2MDF Warning','Close',true,'n_sec',10);
end

%
% Read initial conditions and write
%

%
% Waterlevel
%

if simona2mdf_fieldandvalue(initial,'WATLEVEL.GLOBAL')
    zeta0 = simona2mdf_getglobaldata(initial.WATLEVEL.GLOBAL,zeta0);
end
if simona2mdf_fieldandvalue(initial,'WATLEVEL.LOCAL.BOX')
    zeta0  = simona2mdf_getboxdata(initial.WATLEVEL.LOCAL.BOX,zeta0);
end

%
% UVELOCITY
%

if simona2mdf_fieldandvalue(initial,'UVELOCITY.GLOBAL')
    u0    = simona2mdf_getglobaldata(initial.UVELOCITY.GLOBAL,u0);
end
if simona2mdf_fieldandvalue(initial,'UVELOCITY.LOCAL.BOX')
    u0     = simona2mdf_getboxdata(initial.UVELOCITY.LOCAL.BOX,u0);
end

%
% VVELOCITY
%

if simona2mdf_fieldandvalue(initial,'VVELOCITY.GLOBAL')
    v0    = simona2mdf_getglobaldata(initial.VVELOCITY.GLOBAL,v0);
end
if simona2mdf_fieldandvalue(initial,'VVELOCITY.LOCAL.BOX')
    v0      = simona2mdf_getboxdata(initial.VVELOCITY.LOCAL.BOX,v0);
end

%
% Salinity
%

siminp_struc = siminp(S,[OPT.nesthd_path filesep 'bin' filesep 'waquaref.tab'],{'TRANSPORT'});


if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.TRANSPORT')
    if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.TRANSPORT.PROBLEM.SALINITY')
        s0(1:mmax,1:nmax,1:kmax) = 0.;

        constnr = siminp_struc.ParsedTree.TRANSPORT.PROBLEM.SALINITY.CO;
        initial = siminp_struc.ParsedTree.TRANSPORT.FORCINGS.INITIAL.CONSTITUENT.CO;

        for icons = 1: length(initial)
            if initial(icons).SEQNR == constnr
                sal_ini = initial(icons);
            end
        end

        if simona2mdf_fieldandvalue(sal_ini,'GLOBAL')
            s0    = simona2mdf_getglobaldata(sal_ini.GLOBAL,s0);
        end

        if simona2mdf_fieldandvalue(sal_ini,'LOCAL.BOX')
            s0    = simona2mdf_getboxdata(sal_ini.LOCAL.BOX,s0);
        end
    end
end

%
% Finally write
%

ini(1).Data                  = zeta0(:,:,1);
for k = 1:kmax
    ini(k+1     ).Data = u0(:,:,k);
    ini(kmax+k+1).Data = v0(:,:,k);
    if ~isempty(s0)
        ini(2*kmax+k+1).Data = s0;
    end
end

mdf.filic  = [name_mdf '.ini'];
wldep('write',mdf.filic ,ini);
mdf.filic  = simona2mdf_rmpath(mdf.filic);


%
% Remove non necessary (constat values) fields
%

mdf = rmfield(mdf,'zeta0');
mdf = rmfield(mdf,'u0');
mdf = rmfield(mdf,'v0');
mdf = rmfield(mdf,'s0');
mdf = rmfield(mdf,'t0');
