%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17316 $
%$Date: 2021-06-03 18:01:47 +0800 (Thu, 03 Jun 2021) $
%$Author: chavarri $
%$Id: D3D_bcm_s.m 17316 2021-06-03 10:01:47Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_bcm_s.m $
%
%bcm file creation

%INPUT:
%   -simdef.D3D.dire_sim  = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.bcm.time = time at which the fractiosn are specified [s] [double(nt,1)] e.g. [0,10000]
%   -simdef.bcm.transport = transport excluding pores of each fraction at each time [m^2/s] [double(nt,nf)] e.g. [3e-4,4e-2;5e-4,2e-2]
%
%OUTPUT:
%   -a .bcm compatible with D3D is created in file_name

%150728->151104
%   -bug solved for more than two fractions

function D3D_bcm_s(simdef,varargin)

[simdef]=D3D_rework(simdef); 

%% RENAME

% dire_sim=simdef.D3D.dire_sim;
time=simdef.bcm.time;
Tunit=simdef.mdf.Tunit;
Tfact=simdef.mdf.Tfact;
IBedCond=simdef.mor.IBedCond;
upstream_nodes=simdef.mor.upstream_nodes;
switch IBedCond
    case 3
        deta_dt=simdef.bcm.deta_dt;
    case 5
        transport=simdef.bcm.transport;
        [nt,nf]=size(transport);
end

%% FILE

kl=1;
for kn=1:upstream_nodes
%no edit
data{kl, 1}=sprintf('table-name          ''Boundary Section : %d''',kn); kl=kl+1;
data{kl, 1}=        'contents            ''Uniform'''; kl=kl+1;
% data{kl, 1}=sprintf('location            ''Upstream_%02d''',kn); kl=kl+1;
data{kl, 1}=sprintf('location            ''%s''',simdef.bcm.location{kn,1}); kl=kl+1;
data{kl, 1}=        'time-function       ''non-equidistant'''; kl=kl+1;
data{kl, 1}=        'reference-time       20000101'; kl=kl+1;
switch Tunit
    case 'S'
data{kl, 1}=        'time-unit           ''seconds'''; kl=kl+1;
    case 'M'
data{kl, 1}=        'time-unit           ''minutes'''; kl=kl+1;
end
data{kl, 1}=        'interpolation       ''linear'''; kl=kl+1;
switch Tunit
    case 'S'
data{kl, 1}=        'parameter           ''time'' unit ''[sec]'''; kl=kl+1;
    case 'M'
data{kl, 1}=        'parameter           ''time'' unit ''[min]'''; kl=kl+1;
end

%edit
switch IBedCond
    case 3
        data{kl, 1}=       'parameter           ''depth change        '' unit ''[m/s]'''; kl=kl+1;
        data{kl,1}=sprintf('records-in-table     %d',nt); kl=kl+1;
        for kt=1:nt
            data{kl,1}=sprintf(repmat('%0.7E \t',1,2),time(kt)*Tfact,-deta_dt(kt)); kl=kl+1; %attention! in D3D it is depth (positive down) while for me it is bed elevation (positive up)
        end        
    case 5
        for kf=1:nf
            data{kl, 1}=sprintf('parameter           ''transport excl pores Sediment%d'' unit ''[m2/s]''',kf); kl=kl+1;
        end
        data{kl,1}=sprintf('records-in-table     %d',nt); kl=kl+1;
        for kt=1:nt
            data{kl,1}=sprintf(repmat('%0.7E \t',1,1+nf),time(kt)*Tfact,transport(kt,:)); kl=kl+1;
        end
    otherwise
        error('You need to specify what to write. If you do not need a bcm, do not write the file (modify D3D_bcm and D3D_mor)')
end
end
%% WRITE

file_name=simdef.bcm.fname;
writetxt(file_name,data,varargin{:})
