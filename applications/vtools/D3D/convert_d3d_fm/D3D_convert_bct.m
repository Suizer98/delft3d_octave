%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_convert_bct.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/convert_d3d_fm/D3D_convert_bct.m $
%

function D3D_convert_bct(paths_bct_in,paths_bct_out)

%% COMBINE DATA

nf=numel(paths_bct_in);

kbc=1; %counter on all bc
bct_all=cell(1,1);

for kf=1:nf
    
    if isempty(paths_bct_in{kf,1})==0
    %read table
    bct=bct_io('read',paths_bct_in{kf,1});

    %put together the data of all tables
    nval=numel(bct.Table);
    for kv=1:nval %counter on bc's in each file
        aux=bct.Table(kv).Data;
        bct_all{1,kbc}=aux(:,1:2);
        bct_all{2,kbc}=bct.Table(kv).Location;
        bct_all{3,kbc}=bct.Table(kv).Parameter(2).Name;
        bct_all{4,kbc}=bct.Table(kv).Parameter(2).Name;

        kbc=kbc+1;
    end %nv
    end %isempty
end %kf

%% FILE

nval_tot=size(bct_all,2);

kl=1;
data=cell(1,1);
for kbc=1:nval_tot

    nt=size(bct_all{1,kbc},1);

    for kp=1:2 %two ends of the polyline
        data{kl, 1}=        '[forcing]'; kl=kl+1;
        data{kl, 1}=sprintf('Name                            = %s_%04d',bct_all{2,kbc},kp); kl=kl+1;
        data{kl, 1}=        'Function                        = timeseries'; kl=kl+1;
        data{kl, 1}=        'Time-interpolation              = linear'; kl=kl+1;
        data{kl, 1}=        'Quantity                        = time'; kl=kl+1;
        data{kl, 1}=        'Unit                            = minutes since 2000-01-01 00:00:00'; kl=kl+1;
        switch bct_all{3,kbc}
            case 'flux/discharge  (q)  end A'
        data{kl, 1}=        'Quantity                        = dischargebnd'; kl=kl+1;
        data{kl, 1}=        'Unit                            = m³/s'; kl=kl+1;
            case 'water elevation (z)  end A'
        data{kl, 1}=        'Quantity                        = waterlevelbnd'; kl=kl+1;
        data{kl, 1}=        'Unit                            = m'; kl=kl+1;
        end
        for kt=1:nt
            data{kl, 1}=sprintf(repmat('%0.7E \t',1,2),bct_all{1,kbc}(kt,1),bct_all{1,kbc}(kt,2)); kl=kl+1;
        end
        data{kl, 1}=''; kl=kl+1;
    end %kp

end %knu

%% WRITE

file_name=paths_bct_out;
writetxt(file_name,data)
