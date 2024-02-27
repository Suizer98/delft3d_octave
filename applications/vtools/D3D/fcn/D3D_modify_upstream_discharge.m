%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18138 $
%$Date: 2022-06-10 12:17:52 +0800 (Fri, 10 Jun 2022) $
%$Author: chavarri $
%$Id: D3D_modify_upstream_discharge.m 18138 2022-06-10 04:17:52Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_modify_upstream_discharge.m $
%
%Based on a simulation it redistributes the discharge at the
%upstream boundary based on the function <f_m> along s-coordinate
%<s_m>. The discharge is read along pli-file <fpath_pli>
%
%To do:
%allow more than one bc. I.e., read and sum the discharge of all of them.
%time series management
%read the grid and find the nodes closest to the pli for substituting <fpath_pli>

function D3D_modify_upstream_discharge(fdir_sim,fpath_pli,s_m,f_m,fpath_us_pli_pc,tag_mod,varargin)

%% parse

OPT.lan='en';
OPT.write=1;

OPT=setproperty(OPT,varargin{:});

%% path

simdef.D3D.dire_sim=fdir_sim;
simdef=D3D_simpath(simdef);
fpath_map=simdef.file.map;
fpath_ext=simdef.file.extforcefilenew;
fdir_fig=fullfile(simdef.D3D.dire_sim,'figures');
mkdir_check(fdir_fig);
% nci=ncinfo(fpath_map);

%% read original q

%original external
extn=D3D_io_input('read',fpath_ext);
[fdir_ext,fname_ext,fext_ext]=fileparts(fpath_ext);

%modified external
extn_mod=struct();
extn_mod.General=extn.General;

%find upstream boundaries in external
field_name=fieldnames(extn);
nfn=numel(field_name);
kubc=0;
for kfn=1:nfn
    if ~strcmp(field_name{kfn}(1:4),'boun') %boundary
        continue
    end
    if strcmp(extn.(field_name{kfn}).quantity,'dischargebnd')
        kubc=kubc+1;
        ubc(kubc).locationfile_rel=extn.(field_name{kfn}).locationfile;
        ubc(kubc).locationfile=fullfile(fdir_ext,extn.(field_name{kfn}).locationfile);
        ubc(kubc).forcingfile_rel=extn.(field_name{kfn}).forcingfile;
        ubc(kubc).forcingfile=fullfile(fdir_ext,extn.(field_name{kfn}).forcingfile);
    else
        extn_mod.(field_name{kfn})=extn.(field_name{kfn});
    end
end

%read boundary conditions that are upstream
% bc_u=struct('Name','','Contents','','Location','','TimeFunction','','ReferenceTime',[],'TimeUnit','','Interpolation','','Parameter',struct(),'Data',[]);
bc_u=struct('Name','','Contents','','Location','','TimeFunction','','ReferenceTime',[],'TimeUnit','','Interpolation','','Parameter',struct(),'Data',[],'Time',[]);
nubc=numel(ubc);
for kubc=1:nubc
    bc_o=D3D_io_input('read',ubc(kubc).forcingfile);
    [~,bc_name]=fileparts(ubc(kubc).locationfile);
    bc_name_num=sprintf('%s_0001',bc_name); %possible error if varying along polyline
    idx_table=find_str_in_cell({bc_o.Table.Location},{bc_name_num});
    bc_u=[bc_u,bc_o.Table(idx_table)];
end
bc_u=bc_u(2:end);

if numel(bc_u)>1
    error('do')
    %read all pli and put together (now we use <ubc(kubc).forcingfile>)
    %check all timeseries are the same
    %...
end

%% read discharge along the input pli-file

[ismor,~,~]=D3D_is(fpath_map);
[~,~,tend,~]=D3D_results_time(fpath_map,ismor,NaN);
% q1=EHY_getMapModelData(fpath_map,'varName','mesh2d_q1','t0',tend,'tend',tend,'disp',0,'pliFile',fpath_us_pli); %this is at links
u=EHY_getMapModelData(fpath_map,'varName','mesh2d_ucmag','t0',tend,'tend',tend,'disp',0,'pliFile',fpath_pli);
h=EHY_getMapModelData(fpath_map,'varName','mesh2d_waterdepth','t0',tend,'tend',tend,'disp',0,'pliFile',fpath_pli);

% bol_cor_nn=~isnan(u.Scor);
B=diff(u.Scor)';

bol_cen_nn=~isnan(u.Scen);
s=u.Scen(bol_cen_nn);
q=u.val(bol_cen_nn).*h.val(bol_cen_nn);
Q=q.*B(bol_cen_nn);

%% modify according to input function

Q_tot=sum(Q);
Q_frac=Q./Q_tot; %fraction of discharge
F=griddedInterpolant(s_m,f_m);
f_m_atsim=F(s);
Q_fm=Q_frac.*f_m_atsim';
Q_frac_m=Q_fm/sum(Q_fm,'omitnan');
Q_m=Q_tot.*Q_frac_m; %m^2/s

%% write per cell

%obtaining names for writing file
fpath_us_pli=ubc.locationfile; 
[fdir,fname,fext]=fileparts(fpath_us_pli);

fdirrel_us_pli=fileparts(ubc.locationfile_rel);
fdirrel_us_bc=fileparts(ubc.forcingfile_rel);
[fdir_bc,fnam_bc,fext_bc]=fileparts(ubc(kubc).forcingfile);
fname_bc_mod=sprintf('%s_%s%s',fnam_bc,tag_mod,fext_bc);


%read original pli

%this does not work well. I need precise coordinates of the corners
%of the cells that are boundary. It can be taken from the grid and the pli
%
% fpath_us_pli=ubc.locationfile; 

fpath_us_pli=fpath_us_pli_pc;

us_pli=D3D_io_input('read',fpath_us_pli);
% xy_pli_ori=us_pli.val{1,1};
xy_pli_ori=us_pli(1).xy;
nu=size(xy_pli_ori,1)-1;
if nu~=numel(Q_m)
    error('something is going wrong with the interpolation')
end
    
%flip if different direction than analysis pli
pli_anl=D3D_io_input('read',fpath_pli);
% xy_pli_anl=pli_anl.val{1,1};
xy_pli_anl=pli_anl(1).xy;
[~,mind_idx]=min(sqrt(sum((xy_pli_anl-xy_pli_ori(1,:))^2,2)));
if mind_idx==2
    xy_pli_ori=flipud(xy_pli_ori);
end
us_xy_parts=xy_pli_ori;
% us_xy_parts=increaseCoordinateDensity(xy_pli_ori,nu); %necessary if reading from <ubc.locationfile>

for ku=1:nu
    %write pli
    pli_name=sprintf('%s_p%03d',fname,ku);
    fpath_pli_us_loc=fullfile(fdir,sprintf('%s%s',pli_name,fext));
    xy=us_xy_parts(ku:ku+1,:);
    
    pli_loc.name=pli_name;
    pli_loc.xy=xy;
    if OPT.write
    D3D_io_input('write',fpath_pli_us_loc,pli_loc);
    end
    
    %fill bc
    bc_mod(ku).name=pli_name;
    bc_mod(ku).function=bc_u.Contents;
    bc_mod(ku).time_interpolation=bc_u.Interpolation;
    bc_mod(ku).quantity={bc_u.Parameter.Name};
    bc_mod(ku).unit={bc_u.Parameter.Unit};
    bc_mod(ku).val=[bc_u.Data(:,1),Q_m(ku).*ones(size(bc_u.Data(:,1)))];
    
    %fill ext
    kbnu=0;
    while isfield(extn_mod,sprintf('boundary%d',kbnu))
        kbnu=kbnu+1;
    end
    extn_mod.(sprintf('boundary%d',kbnu)).quantity='dischargebnd';
    extn_mod.(sprintf('boundary%d',kbnu)).locationfile=strrep(fullfile(fdirrel_us_pli,sprintf('%s.pli',pli_name)),'\','/');
    extn_mod.(sprintf('boundary%d',kbnu)).forcingfile=strrep(fullfile(fdirrel_us_bc,fname_bc_mod),'\','/');
end

if OPT.write
%write bc
fpath_bc_mod=fullfile(fdir_bc,fname_bc_mod);
D3D_io_input('write',fpath_bc_mod,bc_mod);

%write ext
fpath_ext_mod=fullfile(fdir_ext,sprintf('%s_%s%s',fname_ext,tag_mod,fext_ext));
D3D_io_input('write',fpath_ext_mod,extn_mod);
end

%% PLOT

in_p.fname=fullfile(fdir_fig,'modify_upstream_discharge');
in_p.fig_visible=0;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.s=s;
in_p.Q=Q;
in_p.Q_m=Q_m;
in_p.lan=OPT.lan;

D3D_figure_modify_upstream_discharge(in_p)

%%
figure
subplot(2,1,1)
hold on
hanp(1)=plot(s,Q,'b-*');
hanp(2)=plot(s,Q_m,'r-*');
xlabel('distance along cross-section [m]')
ylabel('discharge [m^3/s]')
legend(hanp,{'original','modified'})

subplot(2,1,2)
hold on
hanp(1)=plot(s,Q_frac,'b-*');
hanp(2)=plot(s,f_m_atsim,'r-*');
xlabel('distance along cross-section [m]')
ylabel('fracion [-]')
legend(hanp,{'original discharge ratio','multiplication function'})


