%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_bnd_s.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_bnd_s.m $
%
%bnd file creation

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.grd.M = number of nodes in the domain [integer(1,1)] e.g. [1002]
%
%OUTPUT:
%   -a .bnd compatible with D3D is created in file_name

function D3D_bnd_s(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;
path_grd=fullfile(dire_sim,'grd.grd');

%only straight flume!
% M=simdef.grd.M;
% N=simdef.grd.N;

%read grid
grd=wlgrid('read',path_grd);
M=size(grd.X,1)+1;
N=size(grd.X,2)+1;

upstream_nodes=simdef.mor.upstream_nodes;
grd_type=simdef.grd.type;

%% FILE

if simdef.grd.K>1
    str_typeb='Logarithmic';
else
    str_typeb='Uniform';
end

%old
switch grd_type
    case 1
        % data{1,1}=sprintf('Upstream             T T        1     2       1      %d  0.0000000e+000 Uniform',N-1);
        % data{2,1}=sprintf('Downstream           Z T     %d     2    %d      %d  0.0000000e+000',M,M,N-1);
        kl=1;
        for kn=1:upstream_nodes
        data{kl,1}=sprintf('Upstream_%02d             T T        1     2       1      %d  0.0000000e+000 %s',kn,N-1,str_typeb); kl=kl+1;
        end
        data{kl,1}=sprintf('Downstream           Z T     %d     2    %d      %d  0.0000000e+000',M,M,N-1);
    case 3
        kl=1;
        if upstream_nodes>1
            for kn=1:upstream_nodes
                data{kl,1}=sprintf('Upstream_%02d             Q T        1     %d       1      %d  0.0000000e+000 %s',kn,kn+1,kn+1,str_typeb); kl=kl+1;
    %         data{kl,1}=sprintf('Upstream_%02d             T T        1     %d       1      %d  0.0000000e+000 Uniform',kn,kn+1,kn+1); kl=kl+1;
            end
        else
            kn=1;
            data{kl,1}=sprintf('Upstream_%02d             T T        1     %d       1      %d  0.0000000e+000 %s',kn,kn+1,N-1,str_typeb); kl=kl+1;
        end
        data{kl,1}=sprintf('Downstream           Z T     %d     2    %d      %d  0.0000000e+000',M,M,N-1);
end
            
%% WRITE

file_name=fullfile(dire_sim,'bnd.bnd');
writetxt(file_name,data);
