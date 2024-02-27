%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_bcm_u.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_bcm_u.m $
%
%bcm file creation

%INPUT:
%   -
%
%OUTPUT:
%   -


function D3D_bcm_u(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;

time=simdef.bcm.time;
Tunit=simdef.mdf.Tunit;
Tfact=simdef.mdf.Tfact;
IBedCond=simdef.mor.IBedCond;
nt=length(time);
upstream_nodes=simdef.mor.upstream_nodes;

%I change the sign of 3 in structured, so in all cases it is 7
if IBedCond==3
    IBedCond=7;
end
    
switch IBedCond
    case 2
        eta=-simdef.bcm.eta;
    case 5
        transport=simdef.bcm.transport;
        nf=size(transport,2);
    case 7
        deta_dt=simdef.bcm.deta_dt;
end

%% FILE

kl=1;
for kun=1:upstream_nodes
data{kl, 1}=sprintf('table-name          ''Boundary Section : %d''',kun); kl=kl+1;
data{kl, 1}=        'contents            ''Uniform'''; kl=kl+1;
data{kl, 1}=sprintf('location            ''Upstream_%02d''',kun); kl=kl+1;
data{kl, 1}=        'time-function       ''non-equidistant'''; kl=kl+1;
data{kl, 1}=        'reference-time       20000101'; kl=kl+1;
switch Tunit
    case 'S'
data{kl, 1}='time-unit           ''seconds'''; kl=kl+1;
    case 'M'
data{kl, 1}='time-unit           ''minutes'''; kl=kl+1;
end
data{kl, 1}='interpolation       ''linear'''; kl=kl+1;
switch Tunit
    case 'S'
data{kl, 1}='parameter           ''time'' unit ''[sec]'''; kl=kl+1;
    case 'M'
data{kl, 1}='parameter           ''time'' unit ''[min]'''; kl=kl+1;
end

switch IBedCond
    case 2
        data{kl, 1}=       'parameter           ''depth'' unit ''[m]'''; kl=kl+1;
        data{kl,1}=sprintf('records-in-table     %d',nt); kl=kl+1;
        for kt=1:nt
            data{10+kt,1}=sprintf(repmat('%0.7E \t',1,2),time(kt)*Tfact,eta(kt)); kl=kl+1; %attention! in FM D3D it is depth (positive down) while for me it is bed elevation (positive up)
        end                
    case 7
        data{kl, 1}=       'parameter           ''bed level change'' unit ''[m/s]'''; kl=kl+1;
        data{kl,1}=sprintf('records-in-table     %d',nt); kl=kl+1;
        for kt=1:nt
            data{kl,1}=sprintf(repmat('%0.7E \t',1,2),time(kt)*Tfact,deta_dt(kt)); kl=kl+1; %attention! in FM D3D it is depth (positive down) while for me it is bed elevation (positive up)
        end        
    case 5
        for kf=1:nf
                data{kl, 1}=sprintf('parameter           ''transport excl pores Sediment%d'' unit ''[m³/s/m]''',kf); kl=kl+1;
        end
        data{kl,1}=sprintf('records-in-table     %d',nt); kl=kl+1;
        for kt=1:nt
            data{kl,1}=sprintf(repmat('%0.7E \t',1,1+nf),time(kt)*Tfact,transport(kt,:)); kl=kl+1;
        end
    otherwise
        error('IBedCond not accepted')
end
data{kl, 1}=''; kl=kl+1;
end %for 

%% WRITE

file_name=fullfile(dire_sim,'bcm.bcm'); kl=kl+1;
writetxt(file_name,data);
