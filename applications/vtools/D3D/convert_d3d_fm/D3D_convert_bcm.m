%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_convert_bcm.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/convert_d3d_fm/D3D_convert_bcm.m $
%

% paths_bcm_in{1,1}='c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\02_runs\D3D\runs\Rhine_bifurcation\00\delft3d_4-rijn-2017-v1\source\br0.bcm';

% paths_bcm_out='c:\Users\chavarri\Downloads\out_2\bcm.bcm';

% D3D_convert_bcm(paths_bcm_in,paths_bcm_out)

function D3D_convert_bcm(paths_bcm_in,paths_bcm_out)

nd=numel(paths_bcm_in);

for kd=1:nd

if isempty(paths_bcm_in{kd,1})==0
copyfile(paths_bcm_in{kd,1},paths_bcm_out);
end

end

end %function
%%
%% POSSIBLE CHANGE
%%

% %% COMBINE DATA
% 
% nf=numel(paths_bcm_in);
% 
% kbc=1; %counter on all bc
% bcm_all=cell(1,1);
% 
% for kf=1:nf
%     %read table
%     bcm=bct_io('read',paths_bcm_in{kf,1});
% 
%     %put together the data of all tables
%     nval=numel(bcm.Table);
%     for kv=1:nval %counter on bc's in each file
%         aux=bcm.Table(kv).Data;
%         bcm_all{1,kbc}=aux(:,1:2);
%         bcm_all{2,kbc}=bcm.Table(kv).Location;
%         bcm_all{3,kbc}=bcm.Table(kv).Parameter(2).Name;
%         bcm_all{3,kbc}=bcm.Table(kv).Parameter(2).Name;
% 
%         kbc=kbc+1;
%     end %nv
% 
% end %kf
% 
% %% FILE
% 
% nval_tot=size(bcm_all,2);
% 
% kl=1;
% data=cell(1,1);
% 
% for kun=1:nval_tot
% data{kl, 1}=sprintf('table-name          ''Boundary Section : %d''',kun); kl=kl+1;
% data{kl, 1}=        'contents            ''Uniform'''; kl=kl+1;
% data{kl, 1}=sprintf('location            ''Upstream_%02d''',kun); kl=kl+1;
% data{kl, 1}=        'time-function       ''non-equidistant'''; kl=kl+1;
% data{kl, 1}=        'reference-time       20000101'; kl=kl+1;
% switch Tunit
%     case 'S'
% data{kl, 1}='time-unit           ''seconds'''; kl=kl+1;
%     case 'M'
% data{kl, 1}='time-unit           ''minutes'''; kl=kl+1;
% end
% data{kl, 1}='interpolation       ''linear'''; kl=kl+1;
% switch Tunit
%     case 'S'
% data{kl, 1}='parameter           ''time'' unit ''[sec]'''; kl=kl+1;
%     case 'M'
% data{kl, 1}='parameter           ''time'' unit ''[min]'''; kl=kl+1;
% end
% 
% switch IBedCond
%     case 2
%         data{kl, 1}=       'parameter           ''depth'' unit ''[m]'''; kl=kl+1;
%         data{kl,1}=sprintf('records-in-table     %d',nt); kl=kl+1;
%         for kt=1:nt
%             data{10+kt,1}=sprintf(repmat('%0.7E \t',1,2),time(kt)*Tfact,eta(kt)); kl=kl+1; %attention! in FM D3D it is depth (positive down) while for me it is bed elevation (positive up)
%         end                
%     case 7
%         data{kl, 1}=       'parameter           ''bed level change'' unit ''[m/s]'''; kl=kl+1;
%         data{kl,1}=sprintf('records-in-table     %d',nt); kl=kl+1;
%         for kt=1:nt
%             data{kl,1}=sprintf(repmat('%0.7E \t',1,2),time(kt)*Tfact,deta_dt(kt)); kl=kl+1; %attention! in FM D3D it is depth (positive down) while for me it is bed elevation (positive up)
%         end        
%     case 5
%         for kf=1:nf
%                 data{kl, 1}=sprintf('parameter           ''transport excl pores Sediment%d'' unit ''[m³/s/m]''',kf); kl=kl+1;
%         end
%         data{kl,1}=sprintf('records-in-table     %d',nt); kl=kl+1;
%         for kt=1:nt
%             data{kl,1}=sprintf(repmat('%0.7E \t',1,1+nf),time(kt)*Tfact,transport(kt,:)); kl=kl+1;
%         end
%     otherwise
%         error('IBedCond not accepted')
% end
% data{kl, 1}=''; kl=kl+1;
% end %for 
% 
% %% WRITE
% 
% file_name=paths_bcm_out;
% writetxt(file_name,data)
