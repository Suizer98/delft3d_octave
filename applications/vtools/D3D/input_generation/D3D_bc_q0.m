%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17778 $
%$Date: 2022-02-19 00:06:51 +0800 (Sat, 19 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_bc_q0.m 17778 2022-02-18 16:06:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_bc_q0.m $
%
%bnd file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_bc_q0(simdef)
%% RENAME

file_name=simdef.file.bc_q0;
% dire_sim=simdef.D3D.dire_sim;
fname_pli_u=simdef.pli.fname_u;
time=simdef.bct.time_Q;
Q=simdef.bct.Q;

% Tunit=simdef.mdf.Tunit;
% Tfact=simdef.mdf.Tfact;
Tfact=1; %only for s
Tstop=simdef.mdf.Tstop;
Dt=simdef.mdf.Dt; 

%round time
if time(end)<Tstop
    time(end)=(floor(Tstop/Dt)+1)*Dt;
    warning('The end time in bct is smaller than the end time of the simulation (maybe due to rounding issues). I have changed it.')
end

upstream_nodes=simdef.mor.upstream_nodes;

%other
nt=length(time);

%% FILE

%no edit
kl=1;
for kun=1:upstream_nodes
    data{kl, 1}=        '[forcing]'; kl=kl+1;
    data{kl, 1}=sprintf('Name                            = %s_%02d_0001',fname_pli_u,kun); kl=kl+1;
    data{kl, 1}=        'Function                        = timeseries'; kl=kl+1;
    data{kl, 1}=        'Time-interpolation              = linear'; kl=kl+1;
    data{kl, 1}=        'Quantity                        = time'; kl=kl+1;
    data{kl, 1}=        'Unit                            = seconds since 2000-01-01 00:00:00'; kl=kl+1;
    data{kl, 1}=        'Quantity                        = dischargebnd'; kl=kl+1;
    data{kl, 1}=        'Unit                            = m³/s'; kl=kl+1;
    for kt=1:nt
        data{kl, 1}=sprintf(repmat('%0.7E \t',1,2),time(kt)*Tfact,Q(kt)/upstream_nodes); kl=kl+1;
    end
    data{kl, 1}=''; kl=kl+1;
    data{kl, 1}=        '[forcing]'; kl=kl+1;
    data{kl, 1}=sprintf('Name                            = %s_%02d_0002',fname_pli_u,kun); kl=kl+1;
    data{kl, 1}=        'Function                        = timeseries'; kl=kl+1;
    data{kl, 1}=        'Time-interpolation              = linear'; kl=kl+1;
    data{kl, 1}=        'Quantity                        = time'; kl=kl+1;
    data{kl, 1}=        'Unit                            = seconds since 2000-01-01 00:00:00'; kl=kl+1;
    data{kl, 1}=        'Quantity                        = dischargebnd'; kl=kl+1;
    data{kl, 1}=        'Unit                            = m³/s'; kl=kl+1;
    for kt=1:nt
        data{kl, 1}=sprintf(repmat('%0.7E \t',1,2),time(kt)*Tfact,Q(kt)/upstream_nodes); kl=kl+1;
    end
    data{kl, 1}=''; kl=kl+1;
end %knu

%% WRITE

% file_name=fullfile(dire_sim,'bc_q0.bc');
writetxt(file_name,data)

