%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18150 $
%$Date: 2022-06-13 13:00:14 +0800 (Mon, 13 Jun 2022) $
%$Author: chavarri $
%$Id: create_mat_map_sal3D_01.m 18150 2022-06-13 05:00:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_sal3D_01.m $
%
%

function create_mat_map_sal3D_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=simdef.file.map;

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD TIME

[nt,time_dnum,~]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_map);

%% GRID

%load grid for number of layers


%% LOOP POLYGONS

npol=numel(flg_loc.pol);
for kpol=1:npol
    
    %bolean inside analysis polygon
    [bol_grd,pol_name]=gdm_pol_bol_grd(fid_log,flg_loc,simdef,flg_loc.pol{kpol}); 

    %bed level
    fpath_bl_pol=mat_tmp_name(fdir_mat,'bl','pol',pol_name);
    if exist(fpath_bl_pol,'file')==2 && ~flg_loc.overwrite
        messageOut(fid_log,sprintf('File with bed level for polygon exists: %s',fpath_bl_pol));
        load(fpath_bl_pol)
    else
        messageOut(fid_log,'File with bed level for polygon does not exists');
        
        data_bl=gdm_read_data_map(fdir_mat,fpath_map,'bl');
        
        bl_pol=data_bl.val(bol_grd); %#ok
        save_check(fpath_bl_pol,'bl_pol');
    end
    
    %gridInfo
    fpath_gridInfo_pol=mat_tmp_name(fdir_mat,'gridInfo','pol',pol_name);
    if exist(fpath_gridInfo_pol,'file')==2 && ~flg_loc.overwrite
        messageOut(fid_log,sprintf('File with gridInfo for polygon exists: %s',fpath_bl_pol));
        load(fpath_gridInfo_pol,'gridInfo') 
    else
        messageOut(fid_log,'File with gridIndo for polygon does not exists');
        create_mat_grd(fid_log,flg_loc,simdef)
        load(simdef.file.mat.grd,'gridInfo')
        
        gridInfo_pol.no_layers=gridInfo.no_layers;
        gridInfo_pol.Xcen=gridInfo.Xcen(bol_grd,:);
        gridInfo_pol.Ycen=gridInfo.Ycen(bol_grd,:);
        gridInfo_pol.face_nodes_x=gridInfo.face_nodes_x(:,bol_grd);
        gridInfo_pol.face_nodes_y=gridInfo.face_nodes_y(:,bol_grd);
        
        gridInfo=gridInfo_pol; 
        save_check(fpath_gridInfo_pol,'gridInfo')
    end
    
    %grid for interpolation
    xv=min(gridInfo.Xcen):flg_loc.resx(kpol):max(gridInfo.Xcen);
    yv=min(gridInfo.Ycen):flg_loc.resy(kpol):max(gridInfo.Ycen);
    zv=min(bl_pol):flg_loc.resz(kpol):flg_loc.maxz(kpol);
    [x_int,y_int,z_int]=meshgrid(xv,yv,zv);
    
    xvl=repmat(gridInfo.Xcen,1,gridInfo.no_layers);
    yvl=repmat(gridInfo.Ycen,1,gridInfo.no_layers);

    %bed level at corner point for plotting
    F_bl=scatteredInterpolant(gridInfo.Xcen,gridInfo.Ycen,bl_pol,'linear','none');
    
    fpath_bl_cor=mat_tmp_name(fdir_mat,'bl_cor','pol',pol_name);
    if exist(fpath_bl_cor,'file')==2 && ~flg_loc.overwrite
        messageOut(fid_log,sprintf('File with bed level at corner points for polygon exists: %s',fpath_bl_cor));
%         load(fpath_bl_cor) %not needed here, just plotting
    else
        messageOut(fid_log,'File with bed level at corner points for polygon does not exists');
        
        bl_cor=F_bl(gridInfo.face_nodes_x,gridInfo.face_nodes_y); %#ok for plotting
        
        save_check(fpath_bl_cor,'bl_cor');
    end
    

    
    %% LOOP TIME

    kt_v=gdm_kt_v(flg_loc,nt); %time index vector
    niso=numel(flg_loc.isoval);

    ktc=0;
    messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
    for kt=kt_v
        ktc=ktc+1;
        for kiso=1:niso
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'iso',num2str(flg_loc.isoval(kiso)));
            if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end

            %% read data
            
            data_sal=gdm_read_data_map(fdir_mat,fpath_map,'sal','tim',time_dnum(kt));
            sal=squeeze(data_sal.val(:,bol_grd,:));

            %special case to use zw if existing rather than readin zcc
            fpath_zcc=mat_tmp_name(fdir_mat,'zcc','tim',time_dnum(kt));
            if exist(fpath_zcc,'file')==2
                messageOut(fid_log,sprintf('Loading mat-file with raw data: %s',fpath_zcc));
                load(fpath_zcc,'data_zcc')
                zcc=squeeze(data_zcc.val(:,bol_grd,:));
            else
                fpath_zw=mat_tmp_name(fdir_mat,'zw','tim',time_dnum(kt));
                if exist(fpath_zw,'file')==2
                    messageOut(fid_log,sprintf('Loading mat-file with raw data: %s',fpath_zw));
                    load(fpath_zw,'data_zw')
                    zw=squeeze(data_zw.val(:,bol_grd,:));
                    zw_diff=diff(zw,1,2);
                    zcc=zw(:,1:end-1)+zw_diff/2;
                else
                    messageOut(fid_log,sprintf('Reading raw data for variable: %s','mesh2d_flowelem_zcc'));
                    data_zcc=EHY_getMapModelData(fpath_map,'varName','mesh2d_flowelem_zcc','t0',time_dnum(kt),'tend',time_dnum(kt),'mergePartitions',1,'disp',0); %#ok
                    save_check(fpath_zcc,'data_zcc');
                    zcc=squeeze(data_zcc.val(:,bol_grd,:));
                end
            end

            %% calc
            messageOut(fid_log,'Finding iso surface')
            
            %interpolation structure of sal
            bol_nan=isnan(zcc(:));
            warning('off')
            F=scatteredInterpolant(xvl(~bol_nan),yvl(~bol_nan),zcc(~bol_nan),sal(~bol_nan),'linear','none');
            warning('on')
            
            %interpolate on grid
            sal_int=F(x_int,y_int,z_int);

            %isosurface
            sal_iso=isosurface(x_int,y_int,z_int,sal_int,flg_loc.isoval(kiso));
            
            %remove faces below bed level
            if ~isempty(sal_iso.vertices)
                bl_v=F_bl(sal_iso.vertices(:,1),sal_iso.vertices(:,2));
                idx_out=find(sal_iso.vertices(:,3)<bl_v);            
                bol_out=any(ismember(sal_iso.faces,idx_out),2); 
                sal_iso.faces(bol_out,:)=[];
            end
                        
            %data
            data=sal_iso; %#ok
%             data=v2struct(sal_iso); %#ok
            
            %% save and disp
            save_check(fpath_mat_tmp,'data');
            messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));

            %% BEGIN DEBUG

%             figure
%             hold on
%             patch(sal_iso,'edgecolor','none','facecolor','r')
%             EHY_plotMapModelData_V(gridInfo,bl_pol,'t',1,'z',bl_cor);            
%             camlight;
%             lighting gouraud;

            %END DEBUG
        end    

        %% JOIN

        %if creating files in parallel, another instance may have already created it.
        %
        %Not a good idea because of the overwriting flag. Maybe best to join it several times.
        %
        % if exist(fpath_mat,'file')==2
        %     messageOut(fid_log,'Finished looping and mat-file already exist, not joining.')
        %     return
        % end

        % data=struct();

        %% first time for allocating

%         kt=1;
%         fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
%         tmp=load(fpath_mat_tmp,'data');
% 
%         %constant
% 
%         %time varying
%         nF=size(tmp.data.q_mag,2);
% 
%         q_mag=NaN(nt,nF);
%         q_x=NaN(nt,nF);
%         q_y=NaN(nt,nF);
% 
%         %% loop 
% 
%         for kt=1:nt
%             fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
%             tmp=load(fpath_mat_tmp,'data');
% 
%             q_mag(kt,:)=tmp.data.q_mag;
%             q_x(kt,:)=tmp.data.q_x;
%             q_y(kt,:)=tmp.data.q_y;
% 
%         end
% 
%         data=v2struct(q_mag,q_x,q_y); %#ok
%         save_check(fpath_mat,'data');

    end %kiso
end %kpol

end %function

%% 
%% FUNCTION
%%
