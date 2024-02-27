%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17190 $
%$Date: 2021-04-15 16:24:15 +0800 (Thu, 15 Apr 2021) $
%$Author: chavarri $
%$Id: NC_read_his.m 17190 2021-04-15 08:24:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_his.m $
%
%get data from 1 time step in D3D, output name as in D3D

function out=NC_read_his(simdef,in)

messageOut(NaN,'start reading his data')

%% RENAME in

file=simdef.file;
if isfield(simdef,'flg')
    flg=simdef.flg;
end

kt=in.kt; %times to plot
kf=in.kf; %fractions to plot
kF=in.kF; %faces to plot
kcs=in.kcs; %cross-sections to plot

if isfield(flg,'get_cord')==0
    flg.get_cord=1;
end
if isfield(flg,'get_EHY')==0
    flg.get_EHY=0;
end

%overwritten by input variable
if flg.which_v==3
    mean_type=2;
elseif flg.which_v==26
    mean_type=1;
else
    mean_type=1;
end

if isfield(flg,'elliptic')==0
    flg.elliptic=0;
end

%is 
[ismor,is1d,str_network]=D3D_is(file.map);

if numel(kt)==2 && kt(2)==1
    warning('you want to plot one single time for a history file. that is weird')
end

%% LOAD

%HELP
% file.his='c:\Users\chavarri\temporal\D3D\runs\P\035\DFM_OUTPUT_sim_P035\sim_P035_map.nc';
% ncdisp(file.his)

    %% time, space, fractions
if flg.which_p~=-1
    %time
[time_r,time_mor_r,time_dnum]=D3D_results_time(file.his,ismor,kt);

    %space
switch simdef.D3D.structure
    case 2 %FM
        
        %station or area
        switch flg.which_v
            case {1,11,12,18} %variables that are at stations
                where_is_var=1; %default is station
            case {22} %variables at dump area
                where_is_var=2;
            case 24 %variables that are at cross sections
                where_is_var=3;
            case 35 %variables at dredge area
                where_is_var=4;
            otherwise
                error('specify where is this variable')
        end
        
        switch where_is_var
            case 1
                sdc_name=ncread(file.his,'station_name')';
            case 2
                sdc_name=ncread(file.his,'dump_area_name')';
            case 3
                sdc_name=ncread(file.his,'cross_section_name')';
            case 4
                sdc_name=ncread(file.his,'dredge_area_name')';
        end

        if in.nfl~=1
            zcoordinate_c=ncread(file.his,'zcoordinate_c',[1,sdc_2p_idx,kt(1)],[Inf,1,numel(kt)]);
        end
        
    case 3 %SOBEK
        
        sdc_name=ncread(file.his,'observation_id')';
end

sdc_2p_idx=get_branch_idx(in.station,sdc_name);    

if numel(sdc_2p_idx)>1
    error('You cannot read information from more than one station at the same time')
end

    %sediment
% if isfield(file,'sed')
%     sed=D3D_io_input('read',simdef.file.sed);
%     dchar=D3D_read_sed(simdef.file.sed);
% end

% if isfield(file,'mor')
% mor_in=delft3d_io_mor(file.mor);
% end

%some interesting output...
% if exist('mor_in','var')
% if isfield(mor_in.Morphology0,'MorFac')
% out.MorFac=mor_in.Morphology0.MorFac;
% end
% if isfield(mor_in.Morphology0,'MorStt')
% out.MorStt=mor_in.Morphology0.MorStt;
% end
% end

end
    %% vars

%get coordinate of stations in case of SOBEK-3
tol_obs_sta=250; %tolerance for accepting station (in units od coordinates), very adhoc

if simdef.D3D.structure==3
    x_cord=ncread(file.map,'x_coordinate');    
    y_cord=ncread(file.map,'y_coordinate');    
    branchid=ncread(file.map,'branchid');
    chainage=ncread(file.map,'chainage');
    
    branchid_obs=ncread(file.his,'branchid',sdc_2p_idx,1);
    chainage_obs=ncread(file.his,'chainage',sdc_2p_idx,1);
    
    idx_br=find(branchid==branchid_obs);
    [min_va,min_idx]=min((abs(chainage(idx_br)-chainage_obs)));
    if min_va>tol_obs_sta
        warning('The station %s is at %f m from the coordinate given as output',sdc_name(sdc_2p_idx,:),min_va)
    end
    out.X=x_cord(idx_br(min_idx));
    out.Y=y_cord(idx_br(min_idx));
end

switch flg.which_p
    case {'a','b'}
        %common output
        out.time_r=time_r; 
        out.time_mor_r=time_mor_r; 
        out.time_dnum=time_dnum; 
        
        switch flg.which_v
                            
            case 1 %bed level
                switch simdef.D3D.structure
                    case 2
                        z=ncread(file.his,'bedlevel',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                    case 3
                        error('')
%                         wl=ncread(file.his,'water_discharge',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                end
                %output
                out.z=z;
                out.zlabel='bed level [m]';
                out.station=sdc_name(sdc_2p_idx,:);
            case 11 %velocity
                vx=ncread(file.his,'x_velocity',[1,sdc_2p_idx,kt(1)],[Inf,1,kt(2)]);
                vy=ncread(file.his,'y_velocity',[1,sdc_2p_idx,kt(1)],[Inf,1,kt(2)]);
                vz=ncread(file.his,'z_velocity',[1,sdc_2p_idx,kt(1)],[Inf,1,kt(2)]);
                
                out.z=[vx,vy,vz];
                out.zcoordinate_c=zcoordinate_c;
%                 out.time_r=time_r(kt(1):kt(2)); 
                out.zlabel='velocity [m/s]';                
            case 12 %water level
                switch simdef.D3D.structure
                    case 2
                        wl=ncread(file.his,'waterlevel',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                    case 3
                        wl=ncread(file.his,'water_level',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                end
                %output
                out.z=wl;
%                 out.time_r=time_r(kt(1):kt(2)); 
                out.zlabel='water level [m]';
                out.station=sdc_name(sdc_2p_idx,:);
            case 18 %water discharge
                switch simdef.D3D.structure
                    case 2
                        wl=ncread(file.his,'cross_section_discharge',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                    case 3
                        wl=ncread(file.his,'water_discharge',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                end
                
                %output
                out.z=wl;
%                 out.time_r=time_r(kt(1):kt(2)); 
                out.zlabel='water discharge [m^3/s]';
                out.station=sdc_name(sdc_2p_idx,:);
            case 22 %dredged volume
                wl=ncread(file.his,'dump_discharge',[1,kt(1)],[sdc_2p_idx,kt(2)]);
                wl=wl(sdc_2p_idx,:);

                %output
                out.z=wl;
                out.station=sdc_name(sdc_2p_idx,:);
                out.zlabel='cumulative nourished volume [m^3]';
            case 24 %cumulative bedload
                switch simdef.D3D.structure
                    case 2
                        wl=ncread(file.his,'cross_section_bedload_sediment_transport',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                    case 3
                        error('')
                        wl=ncread(file.his,'water_discharge',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                end
                
                %output
                out.z=wl;
%                 out.time_r=time_r(kt(1):kt(2)); 
                out.zlabel='cumulative bed load sediment transport [kg]';
                out.station=sdc_name(sdc_2p_idx,:);    
            case 35
                wl=ncread(file.his,'dred_discharge',[1,kt(1)],[sdc_2p_idx,kt(2)]);
                wl=wl(sdc_2p_idx,:);

                %output
                out.z=wl;
                out.station=sdc_name(sdc_2p_idx,:);
                out.zlabel='cumulative dredged volume [m^3]';
            otherwise
                error('This variable has no his data')
        end

end
