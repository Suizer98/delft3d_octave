%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18336 $
%$Date: 2022-08-26 17:21:36 +0800 (Fri, 26 Aug 2022) $
%$Author: chavarri $
%$Id: plot_his_xt_01.m 18336 2022-08-26 09:21:36Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_his_xt_01.m $
%
%

function plot_his_xt_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

if contains(tag_fig,'all')
    tag_do='do_all';
else
    tag_do='do_p';
end
ret=gdm_do_mat(fid_log,flg_loc,tag,tag_do); if ret; return; end

%% PARSE

nS=numel(simdef);

if isfield(flg_loc,'do_fil')==0
    flg_loc.do_fil=zeros(nS,1);
end
if isfield(flg_loc,'fil_method')==0
    flg_loc.do_fil=repmat({'godin'},1,nS);
end
if isfield(flg_loc,'fil_tim')==0
    flg_loc.fil_tim=25*3600;
end

%% PATHS


fdir_mat=simdef(1).file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie);
fpath_his=simdef(1).file.his;
mkdir_check(fdir_fig);

%% STATIONS


%% TIME

[~,time_dnum,time_dtime]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_his);

%% GRID

if simdef(1).D3D.structure~=3
    gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);
else
    gridInfo=NaN;
end

%% DIMENSIONS

% ns=numel(stations);
nvar=numel(flg_loc.var);
ntr=numel(flg_loc.stations_track);

%% FIGURE INI

in_p=flg_loc;
if isfield(in_p,'fig_print')==0
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
end
in_p.fig_visible=0;
in_p.tim=time_dtime;
in_p.s_fact=1/1000; 

if nS>1
    in_p.leg_str=flg_loc.leg_str;
end

% fext=ext_of_fig(in_p.fig_print);

%% LOOP

for ktr=1:ntr
    flg_loc.stations=flg_loc.stations_track{ktr};
    stations=gdm_station_names(fid_log,flg_loc,fpath_his,'model_type',simdef(1).D3D.structure);
    
    nclim=size(flg_loc.clims{ktr},1);
    
    %%
    for kvar=1:nvar
        
        varname=flg_loc.var{kvar};
        var_str=D3D_var_num2str_structure(varname,simdef(1));
        
        %2DO: solve!
%         layer=gdm_station_layer(flg_loc,gridInfo,fpath_his,stations{ks});
        layer=1;
        
        data_all=[];
        for kS=1:nS
            fdir_mat=simdef(kS).file.mat.dir;
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'var',var_str,'layer',layer,'station',flg_loc.stations_track_name{ktr});
            load(fpath_mat_tmp,'data');
            data_all=cat(3,data_all,data);
        end
        data=data_all;
        
        in_p.unit=var_str;
        if isfield(flg_loc,'unit')
            if ~isempty(flg_loc.unit{kvar})
                in_p.unit=flg_loc.unit{kvar};
            end
        end
        
        %% measurements
        
        %2DO move to function
        in_p.do_measurements=0; %it is compulsory for this figure...
      
        if isfield(flg_loc,'measurements')
            fpath_mea=fullfile(fdir_mat,sprintf('%s_mea.mat',tag));

                if isfolder(flg_loc.measurements) && exist(fullfile(flg_loc.measurements,'data_stations_index.mat'),'file')
                    [str_sta,str_found]=RWS_location_clear(stations);
                    %pass o
                    ns=numel(str_sta);
                    clear data_mea %better to preallocate
                    for ks=1:ns
                        aux=read_data_stations(flg_loc.measurements,'location_clear',str_sta{ks}); %location maybe better?
                        if ~isempty(aux) %not nice
                            data_mea(ks)=aux;
                        end
                    end
                    if exist('data_mea','var')==0
                        in_p.do_measurements=0;
                    else
                        in_p.do_measurements=1;
                        in_p.data_stations=data_mea;
                    end
                else
                    error('do reader')
                end
                
                if in_p.do_measurements==1
                    data_mea_mat=load_mea(fpath_mea,data_mea,time_dtime);
                end
            
        end

        %%

        if in_p.do_measurements
            [x,idx_s]=sort([data_mea.raai]);
            [t_m,d_m]=meshgrid(time_dtime,x);
        
            in_p.t_m=t_m;
            in_p.d_m=d_m.*1000;
%             in_p.val_m=data(:,idx_s)';
            data_aux=data(:,idx_s,:);
            in_p.val_m=permute(data_aux,[2,1,3]);
       
            in_p.t_m_mea=data_mea_mat.data.t_m_mea;
            in_p.d_m_mea=data_mea_mat.data.d_m_mea.*1000;
            in_p.val_m_mea=data_mea_mat.data.val_m_mea;
        else
            [t_m,d_m]=meshgrid(time_dtime,flg_loc.s{ktr});
            
            in_p.t_m=t_m;
            in_p.d_m=d_m.*1000; %km->m change input!
%             in_p.val_m=data';
            in_p.val_m=permute(data,[2,1,3]);
        end
        

        %% filtered data
        if flg_loc.do_fil(ktr) 
            in_p.do_fil=1;
            
            for kS=1:nS
                [tim_f,data_f(:,:,kS)]=filter_1D(time_dtime,data(:,:,kS),'method',flg_loc.fil_method{ktr},'window',flg_loc.fil_tim,'x',flg_loc.s{ktr}); %we could first do 1 to preallocate...
            end
            
%             in_p.val_m=data_f';
            in_p.val_m=permute(data_f,[2,1,3]);
            
            [t_m,d_m]=meshgrid(tim_f,flg_loc.s{ktr});
            in_p.t_m=t_m;
            in_p.d_m=d_m.*1000; %km->m change input!
            
            if in_p.do_measurements                
                [tim_f,data_f]=filter_1D(data_mea.time,data_mea.waarde,'method',flg_loc.fil_method{ktr},'window',flg_loc.fil_tim);
                error('do right data type')
%                 in_p.data_stations_f.time=tim_f;
%                 in_p.data_stations_f.waarde=data_f;
            end
        end
        
        %% value
        
        fdir_fig_var=fullfile(fdir_fig,var_str);
        mkdir_check(fdir_fig_var,NaN,1,0);
        
        for kylim=1:nclim
            fname_noext=fullfile(fdir_fig_var,sprintf('%s_%s_%s_%s_layer_%04d_ylim_%02d',tag,simdef(1).file.runid,var_str,flg_loc.stations_track_name{ktr},layer,kylim));

            in_p.fname=fname_noext;
            
%             in_p.ylims=get_ylims(flg_loc.ylims(kylim,:),in_p.do_measurements,data,data_mea);
            in_p.clims=flg_loc.clims{ktr}(kylim,:);
            in_p.lim_t=[min(time_dtime),max(time_dtime)];
            
            fig_his_xt_01(in_p);
        end %kylim
        
    end %kvar

end %ktr

%% movies

% dt_aux=diff(time_dnum);
% dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
% rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
% for kclim=1:nclim
%    make_video(fpath_file(:,kclim),'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
% end

end %function

%%
%% FUNCTIONS
%%

function ylims=get_ylims(ylims,do_measurements,data,data_mea)

if isnan(ylims)
    if do_measurements
        ylims_1=[min(data(:)),max(data(:))];
        switch data_mea.eenheid
            case 'mg/l'
                ylims_2=[min(sal2cl(-1,data_mea.waarde)),sal2cl(-1,max(data_mea.waarde))];
            otherwise
                ylims_2=[min(data_mea.waarde),max(data_mea.waarde)];
        end

        ylims=[min(ylims_1(1),ylims_2(1)),max(ylims_1(2),ylims_2(2))];
    else
        ylims=[min(data(:)),max(data(:))];
    end
end

end %function

%%

function data_mea_mat=load_mea(fpath_mea,data_mea,time_dtime)

if exist(fpath_mea,'file')==2
    data_mea_mat=load(fpath_mea,'data');
else
    x=sort([data_mea.raai]);
    [t_m_mea,d_m_mea,val_m_mea]=interpolate_xy_data_stations(data_mea,x,time_dtime(1:2:end));
    data=v2struct(t_m_mea,d_m_mea,val_m_mea);
    data_mea_mat.data=data;
    save_check(fpath_mea,'data')
end           

end %function