%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17936 $
%$Date: 2022-04-05 19:43:17 +0800 (Tue, 05 Apr 2022) $
%$Author: chavarri $
%$Id: create_mat_layout.m 17936 2022-04-05 11:43:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/create_mat_layout.m $
%
%

function create_mat_layout(fid_log,flg_loc,simdef)

% tag='map_sal_mass_01';
tag=flg_loc.tag;

%% DO

if ~flg_loc.do
    messageOut(fid_log,sprintf('Not doing ''%s''',tag));
    return
end
messageOut(fid_log,sprintf('Start ''%s''',tag));

%% PARSE

if isfield(flg_loc,'overwrite')==0
    flg_loc.overwrite=0;
end
if isfield(flg_loc,'order_anl')==0
    flg_loc.order_anl=1;
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=simdef.file.map;

%% OVERWRITE

if exist(fpath_mat,'file')==2
    messageOut(fid_log,'Mat-file already exist.')
    if flg_loc.overwrite==0
        messageOut(fid_log,'Not overwriting mat-file already exist.')
        return
    end
    messageOut(fid_log,'Overwriting mat-file.')
else
    messageOut(fid_log,'Mat-file does not exist. Reading.')
end

%% LOAD TIME

load_tim=false;
if exist(fpath_mat_time,'file')==2 
    messageOut(fid_log,'Time-file already exists');
    if flg_loc.overwrite==0
        messageOut(fid_log,'Not overwriting time-file.')
        load(fpath_mat_time,'tim');
        v2struct(tim);
    else 
        messageOut(fid_log,'Overwriting time-file.')
        load_tim=true;
    end
else
    messageOut(fid_log,'Time-file does not exist. Reading.');
    load_tim=true;
end
if load_tim
    [time_dnum,time_dtime]=D3D_time_dnum(fpath_map,flg_loc.tim);
    tim=v2struct(time_dnum,time_dtime); %#ok
    save_check(fpath_mat_time,'tim');
end
nt=numel(time_dnum);

%% CONSTANT IN TIME

%load grid for number of layers
% load(simdef.file.mat.grd,'gridInfo')

raw_ba=EHY_getMapModelData(fpath_map,'varName','mesh2d_flowelem_ba','mergePartitions',1,'disp',0);

%% LOOP

switch flg_loc.order_anl
    case 1
        kt_v=1:1:nt;
    case 2
        kt_v=randi(nt,1,nt);
end

messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,0/nt*100));
for kt=kt_v
    fpath_mat_tmp=mat_tmp_name(tag,kt);
    if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end
    
    %read data
    data_u=EHY_getMapModelData(fpath_map,'varName','uv','t0',time_dnum(kt),'tend',time_dnum(kt),'mergePartitions',1,'disp',0,'pli',pli);
    data_h=EHY_getMapModelData(fpath_map,'varName','wd','t0',time_dnum(kt),'tend',time_dnum(kt),'mergePartitions',1,'disp',0,'pli',pli);
    q=data_u.vel_perp.*data_h.val;
    Q=q.*diff(data_h.Scor)';

    %differentiate parts
    bol_sb=inpolygon(data_h.Xcen,data_h.Ycen,sb_raw.xy.XY{1,1}(:,1),sb_raw.xy.XY{1,1}(:,2));

    idx_sb_1=find(bol_sb==1,1,'first');
    idx_sb_f=find(bol_sb==1,1,'last');
    idx_cs=zeros(size(bol_sb));
    idx_cs(1:idx_sb_1-1)=1;
    idx_cs(idx_sb_1:idx_sb_f)=2;
    idx_cs(idx_sb_f+1:end)=3;

    ncs=3;
    Q_cs=NaN(1,ncs);
    for kcs=1:ncs
        Q_cs(kcs)=sum(Q(idx_cs==kcs),'omitnan');
    end
    Q_cs_frac=Q_cs./sum(Q_cs);

    %data
    data=v2struct(data_u,data_h,q,Q,idx_cs,Q_cs,Q_cs_frac); %#ok

    %% save and disp
    save_check(fpath_mat_tmp,'data');
    messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,kt/nt*100));
    
end    

%% JOIN

data=struct();

%% first time for allocating

kt=1;
fpath_mat_tmp=mat_tmp_name(tag,kt);
tmp=load(fpath_mat_tmp,'data');

%constant
data(kpli).Xcor=tmp.data.data_h.Xcor;
data(kpli).Ycor=tmp.data.data_h.Ycor;
data(kpli).Scor=tmp.data.data_h.Scor;
data(kpli).Scen=tmp.data.data_h.Scen;
data(kpli).Xcen=tmp.data.data_h.Xcen;
data(kpli).Ycen=tmp.data.data_h.Ycen;
data(kpli).idx_cs=tmp.data.idx_cs;

%time varying
[~,ncx,~]=size(tmp.data.data_h.val);
ncs=numel(tmp.data.Q_cs);

data(kpli).h=NaN(nt,ncx);
data(kpli).vel_x=NaN(nt,ncx);
data(kpli).vel_y=NaN(nt,ncx);
data(kpli).vel_mag=NaN(nt,ncx);
data(kpli).vel_dir=NaN(nt,ncx);
data(kpli).vel_para=NaN(nt,ncx);
data(kpli).vel_perp=NaN(nt,ncx);
data(kpli).q=NaN(nt,ncx);
data(kpli).Q=NaN(nt,ncx);

data(kpli).Q_cs=NaN(nt,ncs);
data(kpli).Q_cs_frac=NaN(nt,ncs);

%% loop 

for kt=1:nt
    fpath_mat_tmp=mat_tmp_name(tag,kt);
    tmp=load(fpath_mat_tmp,'data');

    data(kpli).h(kt,:)=tmp.data.data_h.val;
    data(kpli).vel_x(kt,:)=tmp.data.data_u.vel_x;
    data(kpli).vel_y(kt,:)=tmp.data.data_u.vel_y;
    data(kpli).vel_mag(kt,:)=tmp.data.data_u.vel_mag;
    data(kpli).vel_dir(kt,:)=tmp.data.data_u.vel_dir;
    data(kpli).vel_para(kt,:)=tmp.data.data_u.vel_para;
    data(kpli).vel_perp(kt,:)=tmp.data.data_u.vel_perp;
    data(kpli).q(kt,:)=tmp.data.q;
    data(kpli).Q(kt,:)=tmp.data.Q;

    data(kpli).Q_cs(kt,:)=tmp.data.Q_cs;
    data(kpli).Q_cs_frac(kt,:)=tmp.data.Q_cs_frac;

end

save_check(fpath_mat,'data');

end %function

%% 
%% FUNCTION
%%

function fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,kt)

fpath_mat_tmp=fullfile(fdir_mat,sprintf('%s_tmp_kt_%04d.mat',tag,kt));

end %function