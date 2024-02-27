%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17749 $
%$Date: 2022-02-10 14:52:25 +0800 (Thu, 10 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_export_1D.m 17749 2022-02-10 06:52:25Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_export_1D.m $
%
                
function D3D_export_1D(br_name,dire_sim_v,z,SZ,zlab,refdate)

[ns,nb,nt,nv]=size(SZ);

if time_data==0
    
    for kv=1:nv
        for kb=1:nb
            for ks=1:ns
                %%
                refdate_str=num2str(refdate{ks,1});
                time_d=datetime(str2double(refdate_str(1:4)),str2double(refdate_str(5:6)),str2double(refdate_str(7:8)))+seconds(time_r{ks,kb,kt,kv});
                [~,idx_min]=min(abs(time_d-datetime(2050,1,1)));

                sim_id=dire_sim_v{ks};
                br_id=br_name{kb,1};
                if isfield(in_read,'path_rkm')
                    x_wr='river km [km]';
                else
                    x_wr='streamwise coordinate [m]';
                end
                z_m_wr=z{ks,kb,kt,kv};
                x_v_wr=SZ{ks,kb,kt,kv};
    %             y_v_wr=time_d;
                y_v_wr=time_r{ks,kb,kt,kv};
                zlab_wr=zlab{kv};
                refdata_wr=num2str(refdate{ks,1});

                fpath_out=fullfile(pwd,sprintf('export_sim_%02d_br_%02d_var_%02d.ascii',ks,kb,kv));
                D3D_export(fpath_out,sim_id,br_id,x_wr,x_v_wr,refdata_wr,y_v_wr,zlab_wr,z_m_wr)

                %one time
                y_v_wr=time_r{ks,kb,kt,kv}(idx_min);
                z_m_wr=z{ks,kb,kt,kv}(:,idx_min);
                fpath_out=fullfile(pwd,sprintf('export_sim_%02d_br_%02d_var_%02d_t2050.ascii',ks,kb,kv));
                D3D_export(fpath_out,sim_id,br_id,x_wr,x_v_wr,refdata_wr,y_v_wr,zlab_wr,z_m_wr)

                %one time diff
                y_v_wr=time_r{ks,kb,kt,kv}(idx_min);
                z_m_wr=z{ks,kb,kt,kv}(:,idx_min)-z{ks,kb,kt,kv}(:,1);
                zlab_wr=sprintf('change in %s',zlab{kv});
                fpath_out=fullfile(pwd,sprintf('export_sim_%02d_br_%02d_var_%02d_t2050_diff.ascii',ks,kb,kv));
                D3D_export(fpath_out,sim_id,br_id,x_wr,x_v_wr,refdata_wr,y_v_wr,zlab_wr,z_m_wr)

            end
        end
    end

end %time_data

end %function