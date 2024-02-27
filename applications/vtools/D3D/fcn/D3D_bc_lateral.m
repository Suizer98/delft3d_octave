%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_bc_lateral.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_bc_lateral.m $
%
%bnd file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_bc_lateral(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;

lat_t_unit=simdef.bct.lat_t_unit;
lat_name=simdef.bct.lat_name;
lat_Q=simdef.bct.lat_Q;
lat_t=simdef.bct.lat_t;

%other
nt=length(lat_t);

%% FILE

error('too slow for large time series')
data=cell(500e3,1);
%no edit
kl=1;
data{kl, 1}=        '[forcing]                                                  '; kl=kl+1;
data{kl, 1}=sprintf('name                  = %s								    ',lat_name); kl=kl+1;
data{kl, 1}=        'function              = timeseries                         '; kl=kl+1;
data{kl, 1}=        'time-interpolation    = linear                             '; kl=kl+1;
data{kl, 1}=        'quantity              = time                               '; kl=kl+1;
data{kl, 1}=sprintf('unit                  = %s  ',lat_t_unit); kl=kl+1;
data{kl, 1}=        'quantity              = lateral_discharge                  '; kl=kl+1;
data{kl, 1}=        'unit                  = m3/s                               '; kl=kl+1;
for kt=1:nt
    data{kl, 1}=sprintf(repmat('%0.7E \t',1,2),lat_t(kt),lat_Q); kl=kl+1;
        fprintf('file %4.2f %% \n',kt/nt*100)
end
data{kl, 1}=''; kl=kl+1;

data=data{1:kl-1,:};
%% WRITE

file_name=fullfile(dire_sim,sprintf('%s.bc',lat_name));
writetxt(file_name,data)

