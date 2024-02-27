%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18270 $
%$Date: 2022-08-01 18:23:51 +0800 (Mon, 01 Aug 2022) $
%$Author: chavarri $
%$Id: D3D_rework.m 18270 2022-08-01 10:23:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_rework.m $
%
%generate other input parameters 

%INPUT:
%   -simdef.ini.s = bed slope [-] [integer(1,1)]; e.g. [3e-4] 
%   -simdef.ini.h = uniform flow depth [m] [double(1,1)]; e.g. [0.19]
%   -simdef.ini.u = uniform flow velocity [m/s] [double(1,1)]; e.g. [0.6452] 
%   -simdef.grd.L = domain length [m] [integer(1,1)] [100]
%   -simdef.ini.etab = initial downstream bed level [m] [double(1,1)] e.g. [0]
%   -simdef.bct.Q =  water discharge [m3/s]
%
%OUTPUT:
%   -node_number
%   -M 
%   -etab
%   -h
%   -u
%
%ATTENTION:
%   -Very specific for 1D case in positive x direction
%

function [simdef]=D3D_rework(simdef) 
%% RENAME IN

% L=simdef.grd.L;
% B=simdef.grd.B;
% dx=simdef.grd.dx;
% dy=simdef.grd.dy;
% ds=simdef.grd.dx;
% dn=simdef.grd.dy;
% Q=simdef.bct.Q;
% s=simdef_in.ini.s;
% h=simdef.ini.h;
% C=simdef_in.mdf.C;
% etab=simdef_in.mdf.etab;
% lambda=simdef.grd.lambda; % [m] wave length
% lambda_num=simdef.grd.lambda_num; % [-] number of wave lengths
% Tstop=simdef.mdf.Tstop;
% Dt=simdef.mdf.Dt;
% C=simdef.mdf.C;

simdef.mdf.vkappa=0.41; %von Karman



%%
%% D3D
%%

simdef.D3D.dummy=NaN;

if isfield(simdef.D3D,'dire_sim')==0
    if isfield(simdef.runid,'serie')
        if strcmp(simdef.runid.serie,'Rhine')
            simdef.D3D.dire_sim=fullfile(file.main_folder,sprintf('%02d',runid.number));
        else
            simdef.D3D.dire_sim=fullfile(simdef.D3D.paths_runs,simdef.runid.serie,simdef.runid.number);
        end
    else
        simdef.D3D.dire_sim='';
    end
end
if isfield(simdef.D3D,'structure')==0
    simdef.D3D.structure=0;
end

%%
%% FILE
%%

simdef.file.dummy=NaN;

switch simdef.D3D.structure
    case 1
        if isfield(simdef.file,'tra')==0
            simdef.file.tra=fullfile(simdef.D3D.dire_sim,'tra.tra');
        end
end

%%
%% GRID
%%

simdef.grd.dummy=NaN;

if isfield(simdef.file,'grd')==0
    if simdef.D3D.structure==1
        simdef.file.grd=fullfile(simdef.D3D.dire_sim,'grd.grd');
    else
        simdef.file.grd=fullfile(simdef.D3D.dire_sim,'grd_net.nc');
    end
end

if isfield(simdef.grd,'cell_type')==0
    simdef.grd.cell_type=1;
end

%grid variables
if isfield(simdef.grd,'type')==0
    simdef.grd.type=0;
end

switch simdef.grd.type
    case 0
    case 1
        simdef.grd.node_number_x=simdef.grd.L/simdef.grd.dx; %number of nodes 
        simdef.grd.node_number_y=simdef.grd.B/simdef.grd.dy; %number of nodes 
        simdef.grd.M=simdef.grd.node_number_x+2; %M (number of cells in x direction)
        simdef.grd.N=simdef.grd.node_number_y+2; %N (number of cells in y direction)


        if rem(simdef.grd.node_number_x,1) || rem(simdef.grd.node_number_y,1) 
            error('Make L and B to be multiples of dx and dy')
        end
    case 2
        mmax=round(simdef.grd.lambda_num*simdef.grd.lambda/ds);
        nmax=floor(simdef.grd.B/simdef.grd.dy*2);
        
        simdef.grd.M=mmax+1; %M (number of cells in x direction)
        simdef.grd.N=nmax+1; %N (number of cells in y direction)
        simdef.grd.node_number_x=simdef.grd.M-2; %number of nodes 
        simdef.grd.node_number_y=simdef.grd.N-2; %number of nodes 
        simdef.grd.L=simdef.grd.node_number_x*dx;
    case 3
        simdef.grd.node_number_y=round(simdef.grd.B/simdef.grd.dy); %number of nodes
        simdef.grd.node_number_x=ceil(simdef.grd.L1/simdef.grd.dx)+ceil(simdef.grd.L2/simdef.grd.dx)+round(simdef.grd.R*2*pi*simdef.grd.angle/360/simdef.grd.dx); %number of nodes
        
        simdef.grd.M=simdef.grd.node_number_x+2; %M (number of cells in x direction)
        simdef.grd.N=simdef.grd.node_number_y+2; %N (number of cells in y direction)
    otherwise
        error('idiot...')    
        
end

%uniform flow
% if isnan(simdef.ini.h)
%     error('add call to equilibrium')
%     h=((Q/B)^2./C^2./s).^(1/3);
%     etab=-h(end);
% end

%%
%% MDF
%%

simdef.mdf.dummy=NaN;

%grd
[~,fname,fext]=fileparts(simdef.file.grd); %should always be in simulation folder
simdef.mdf.grd=sprintf('%s%s',fname,fext);

%secondary flow
if isfield(simdef.mdf,'secflow')
    
else
    simdef.mdf.secflow=0;
end

%time units
if isfield(simdef.mdf,'Tunit')==0
    simdef.mdf.Tunit='S';
    simdef.mdf.Tfact=1; %input is in seconds
end

%start time
if isfield(simdef.mdf,'Tstart')==0
    simdef.mdf.Tstart=0;
end

%stop time
if isfield(simdef.mdf,'Tstop')==0
    simdef.mdf.Tstop=NaN;
end

%dt
if isfield(simdef.mdf,'Dt')==0
    simdef.mdf.Dt=NaN;
end
if numel(simdef.mdf.Dt)>1
    error('Dimension of <Dt> should be 1')
end

%restart
if isfield(simdef.mdf,'restart')==0
    simdef.mdf.restart=0;
end

if simdef.mdf.restart==1
    simdef.mdf.Tunit='M'; %there is a bug with the time units. when you restart a simulation it only works when the units are minutes
    simdef.mdf.Tfact=1/60; %input is in seconds
end

%rework stop time
if rem(simdef.mdf.Tstop,simdef.mdf.Dt)~=0
    simdef.mdf.Tstop=(floor(simdef.mdf.Tstop/simdef.mdf.Dt)+1)*simdef.mdf.Dt; %output in seconds
    
    warning('Simulation time does not match with time step. I have changed the simulation time.')
end

%map time
if isfield(simdef.mdf,'Flmap_dt')==0
    warning('you are not saving map results')
    simdef.mdf.Flmap_dt=[0,0]; %start, interval
else
    if numel(simdef.mdf.Flmap_dt)==1
        simdef.mdf.Flmap_dt=[0,simdef.mdf.Flmap_dt];
    elseif numel(simdef.mdf.Flmap_dt)==2
    else
        error('Flmap_dt [start,interval]')
    end
    if rem(simdef.mdf.Flmap_dt(2),simdef.mdf.Dt)~=0 
        warning('Map results time is not multiple of time step. I am rewring the map results time.')
        simdef.mdf.Flmap_dt=(floor(simdef.mdf.Flmap_dt(2)/simdef.mdf.Dt)+1)*simdef.mdf.Dt;
    end
end

%history time and observations filr
simdef.mdf.obs_filename='obs.xyn';
if isfield(simdef.mdf,'Flhis_dt')==0
    simdef.mdf.Flhis_dt=0;
    simdef.mdf.obs_filename='';
else
    if rem(simdef.mdf.Flhis_dt,simdef.mdf.Dt)~=0 
        warning('History results time is not multiple of time step. I am rewring the history results time.')
        simdef.mdf.Flhis_dt=(floor(simdef.mdf.Flhis_dt/simdef.mdf.Dt)+1)*simdef.mdf.Dt;
    end
end

%gravity
if isfield(simdef.mdf,'g')==0
    simdef.mdf.g=9.81;
end

%friction
if isfield(simdef.mdf,'C')==0
    simdef.mdf.C=NaN;
%     error('specify friction coefficient, even though it is not used') %why?
end
if isnan(simdef.mdf.C) %no friction
    switch simdef.D3D.structure
        case 1
            simdef.mdf.C=5e3;
        case 2
            simdef.mdf.C=0;
    end
% if simdef.mdf.C==0 && simdef.D3D.structure=1
%     error('friction coefficient cannot be 0 in D3D4
%     warning('You may not want to specify friction (i.e., friction type = 10), then, set the coefficient to 1, but not zero!')
end
%in d3d, even when friction is set to constant, it accounts for some
%roughness height that messes all... I think it is incorrect. Here I solve
%it 
% Cw=30.712688432783460;
% vkappa=0.41;
% simdef.mdf.g=9.81;
if isfield(simdef.mdf,'correct_C')==0
    simdef.mdf.correct_C=0;
end
if simdef.mdf.correct_C==1
    simdef.mdf.C=sqrt(simdef.mdf.g)/simdef.mdf.vkappa*log(-1+exp(simdef.mdf.C*simdef.mdf.vkappa/sqrt(simdef.mdf.g)));
end
% Cin =sqrt(simdef.mdf.g)/vkappa*log(-1+exp(Cw *vkappa/sqrt(simdef.mdf.g)));
% Cd3d=sqrt(simdef.mdf.g)/vkappa*log(+1+exp(Cin*vkappa/sqrt(simdef.mdf.g)));

if isfield(simdef.mdf,'wall_rough')==0
    simdef.mdf.wall_rough=0;
    simdef.mdf.wall_ks=0;
end
if simdef.mdf.wall_rough==1 && isfield(simdef.mdf,'wall_ks')==0
    error('specify wall friction!')
end

%2D/3D

switch simdef.D3D.structure
    case 1
        if isfield(simdef.grd,'K')==0
            simdef.grd.K=1; 
        end
    case 2
        if isfield(simdef.grd,'K')==0
            simdef.grd.K=0; 
        end
        if simdef.grd.K==1
            warning('You want a 3D computation with one layer')
        end    
        if isfield(simdef.grd,'Thick') && simdef.grd.K>0 && simdef.D3D.structure==2
            warning('You want a 3D computation with varying layer thickness. This is not yet possible')
        end
end

if isfield(simdef.grd,'Thick')==0
    simdef.grd.Thick=(1./(simdef.grd.K.*ones(1,simdef.grd.K-1)))*100;
end

if isfield(simdef.mdf,'Flrst_dt')==0
    simdef.mdf.Flrst_dt=0;
end
 
if isfield(simdef.mdf,'filter')==0
    simdef.mdf.filter=0;
end

if isfield(simdef.mdf,'Dpsopt')==0
    simdef.mdf.Dpsopt='MEAN';
end
if isfield(simdef.mdf,'Dpuopt')==0
    simdef.mdf.Dpuopt='min_dps'; %this is default. Most accurate is <mean_dps>
end
% if strcmp(simdef.mdf.Dpsopt,'MEAN')~=1
%     error('adjust flow depth file accordingly')
% end

if isfield(simdef.mdf,'ext')==0
    simdef.mdf.ext='ext.ext';
end

if isfield(simdef.mdf,'extn')==0
    simdef.mdf.extn='bnd.ext';
end

if isfield(simdef.mdf,'mor')==0
    simdef.mdf.mor='mor.mor';
end

if isfield(simdef.mdf,'sed')==0
    simdef.mdf.sed='sed.sed';
end

if simdef.D3D.structure==1
if isfield(simdef.mdf,'tra')==0
    simdef.mdf.tra='tra.tra';
end
end

if isfield(simdef.mdf,'izbndpos')==0
    if simdef.D3D.structure==1
        simdef.mdf.izbndpos=0;
    else
        simdef.mdf.izbndpos=1;
    end
end

if isfield(simdef.mdf,'CFLMax')==0
    simdef.mdf.CFLMax=0.7;
end

if isfield(simdef.mdf,'TransportAutoTimestepdiff')==0
    simdef.mdf.TransportAutoTimestepdiff=1;
end

%%
%% SED
%%

simdef.sed.dummy=NaN;

if isfield(simdef.file,'sed')==0
    simdef.file.sed=fullfile(simdef.D3D.dire_sim,'sed.sed');
end

if isfield(simdef.sed,'dk')==0
    simdef.sed.dk=[];
end

%%
%% MOR
%%

simdef.mor.dummy=NaN;

if isfield(simdef.file,'mor')==0
    simdef.file.mor=fullfile(simdef.D3D.dire_sim,'mor.mor');
end

nf=numel(simdef.sed.dk);
if nf==1
    simdef.mor.IUnderLyr=1;
else
    simdef.mor.IUnderLyr=2;
end

if isfield(simdef.mor,'CondPerNode')==0
    simdef.mor.CondPerNode=0;
end
switch simdef.mor.CondPerNode
    case 0
        simdef.mor.upstream_nodes=1;
    case 1
%         if simdef.grd.type~=3
%             error('CondPerNode for another grid wich is not DHL is not implemented')
%         end
        simdef.mor.upstream_nodes=simdef.grd.node_number_y;
        
end

if isfield(simdef.mor,'IBedCond')==0
    simdef.mor.IBedCond=NaN;
end

if isfield(simdef.mor,'UpwindBedload')==0
    simdef.mor.UpwindBedload=1;
end
if isfield(simdef.mor,'BedloadScheme')==1
    simdef.mor.UpwindBedload=NaN;
else
    simdef.mor.BedloadScheme=NaN;
end

%% 
%% BCM
%%

simdef.bcm.dummy=NaN;

if isfield(simdef.bcm,'fname')==0
    simdef.bcm.fname=fullfile(simdef.D3D.dire_sim,'bcm.bcm');
end

switch simdef.mor.IBedCond
    case 3
%         deta_dt=simdef.bcm.deta_dt;
    case 5
        time=simdef.bcm.time;
        nt=length(time);
        transport=simdef.bcm.transport;
        [nt_a,nf_a]=size(transport);
        if nf>0
            if nf_a~=nf
                error('Inconsistent input in simdef.bcm.transport')
            end
        end
        if nt_a~=nt
            error('Time does not match transport')
        end
end

if isfield(simdef.bcm,'location')==0
    simdef.bcm.location=cell(simdef.mor.upstream_nodes,1);
    for kn=1:simdef.mor.upstream_nodes
        simdef.bcm.location{kn,1}=sprintf('Upstream_%02d',kn); 
    end
end
        
%% ILL-POSEDNESS

if isfield(simdef.mor,'HiranoCheck')==0
    simdef.mor.HiranoCheck=0;
end
if isfield(simdef.mor,'HiranoRegularize')==0
    simdef.mor.HiranoRegularize=0;
end
if isfield(simdef.mor,'HiranoDiffusion')==0
    simdef.mor.HiranoDiffusion=1;
end
if simdef.mor.HiranoRegularize==1 && simdef.mor.HiranoCheck==0
    error('You want to regularize the active layer model but you don''t want to check for ill-posedness')
end
if simdef.mor.HiranoRegularize==1 && simdef.mdf.Dicouv==0
    error('You want to regularize the active layer model but the diffusion coefficient of trachitops (simdef.mdf.Dicouv) is set to 0. This should not be a problem, but in the way it is implemented simdef.mdf.Dicouv needs to be different than 0 to work')
end

%%
%% FINI
%%

simdef.ini.dummy=NaN;

if isfield(simdef.ini,'etaw_type')==0
    simdef.ini.etaw_type=1;
end

if isfield(simdef.ini,'h')==0
    simdef.ini.h=NaN;
end

if isfield(simdef.ini,'u')==0
    simdef.ini.u=0;
end

if isfield(simdef.ini,'v')==0
    simdef.ini.v=0;
end

if simdef.D3D.structure==1
    if isfield(simdef.file,'fini')==0
        simdef.file.fini=fullfile(simdef.D3D.dire_sim,'fini.ini');
    end
    if isfield(simdef.ini,'I0')==0
        simdef.ini.I0=0;
    end
else
    if isfield(simdef.file,'ext')==0
        simdef.file.ext=fullfile(simdef.D3D.dire_sim,'ext.ext');
    end
    if isfield(simdef.file,'etaw')==0
        simdef.file.etaw=fullfile(simdef.D3D.dire_sim,'etaw.xyz');
    end
    if isfield(simdef.ini,'etaw_file')==0
        simdef.ini.etaw_type='etaw.xyz';
    end
    if isfield(simdef.file,'ini_vx')==0
        simdef.file.ini_vx=fullfile(simdef.D3D.dire_sim,'ini_vx.xyz');
    end
    if isfield(simdef.file,'ini_vy')==0
        simdef.file.ini_vy=fullfile(simdef.D3D.dire_sim,'ini_vy.xyz');
    end
end
    
if isfield(simdef.ini,'etab0_type')==0
    simdef.ini.etab0_type=1;
end
switch simdef.ini.etab0_type
    case {1,2}
    case 3
        aux_dim=size(simdef.ini.xyz);
        if aux_dim(2)~=3
            error('dimensions do not agree')
        end
    otherwise
        error('etab0_type nonexistent')
end

if isfield(simdef.ini,'etaw_noise')==0
    simdef.ini.etaw_noise=0;
end

%%
%% RUNID
%%

simdef.runid.dummy=NaN;
if isfield(simdef.runid,'name')==0
    if isfield(simdef.runid,'number')
        if isa(simdef.runid.number,'double')
            error('specify runid as string')
        end
    end
    switch simdef.D3D.structure
        case 1
            ext='mdf';
        case 2
            ext='mdu';
    end
%     simdef.runid.name=sprintf('sim_%s%s.%s',simdef.runid.serie,simdef.runid.number,ext);
    simdef.runid.name=sprintf('r%s%s.%s',simdef.runid.serie,simdef.runid.number,ext);
end

%% 
%% DEP
%%

if isfield(simdef.file,'dep')==0
    switch simdef.D3D.structure
        case 1
            simdef.mdf.dep='dep.dep';
            simdef.file.dep=fullfile(simdef.D3D.dire_sim,'dep.dep');
        case 2
            simdef.mdf.dep='dep.xyz';
            simdef.file.dep=fullfile(simdef.D3D.dire_sim,'dep.xyz');
    end
end

%%
%% PLI
%%

simdef.pli.dummy=NaN;
if isfield(simdef.file,'fdir_pli')==0
    simdef.file.fdir_pli=simdef.D3D.dire_sim;
    simdef.file.fdir_pli_rel='';
end

if isfield(simdef.pli,'fname_u')==0
    simdef.pli.fname_u='Upstream';
end

if isfield(simdef.pli,'str_bc_u')==0
    simdef.pli.str_bc_u='bc_q0';    
end

if isfield(simdef.pli,'fname_d')==0
    simdef.pli.fname_d='Downstream';
end

if isfield(simdef.pli,'str_bc_d')==0
    simdef.pli.str_bc_u='bc_wL';    
end

%%
%% EXTN
%%

if isfield(simdef.file,'bc_wL')==0
    simdef.file.bc_wL=fullfile(simdef.D3D.dire_sim,'bc_wL.bc');    
end

if isfield(simdef.file,'bc_q0')==0
    simdef.file.bc_q0=fullfile(simdef.D3D.dire_sim,'bc_q0.bc');    
end

if isfield(simdef.file,'extn')==0
    simdef.file.extn=fullfile(simdef.D3D.dire_sim,'bnd.ext');
end

%%
%% BC
%%

if isfield(simdef.file,'fdir_bc_rel')==0
    simdef.file.fdir_bc_rel='';
end

simdef.bc.dummy=NaN;
if isfield(simdef.bc,'fname_u')==0
    simdef.bc.fname_u='bc_q0';
end
if isfield(simdef.bc,'fname_d')==0
    simdef.bc.fname_d='bc_wL';
end

%%
%% BCT
%%

%discharge
if isfield(simdef.bct,'time_Q')==0
    simdef.bct.time_Q=[simdef.mdf.Tstart;simdef.mdf.Tstop];
end
if numel(simdef.bct.Q)==1
    simdef.bct.Q=simdef.bct.Q.*ones(size(simdef.bct.time_Q));
end
if any(size(simdef.bct.time_Q)-size(simdef.bct.Q))
    error('dimensions of Q boundary condition do not agree')
end

%add extra time with same value as last in case the last time step gets outside the domain
if simdef.D3D.structure==2
simdef.bct.Q=cat(1,simdef.bct.Q,simdef.bct.Q(end));
simdef.bct.time_Q=cat(1,simdef.bct.time_Q,simdef.bct.time_Q(end)*1.1);
end

%water level
if isfield(simdef.bct,'time')==0
    simdef.bct.time=[simdef.mdf.Tstart;simdef.mdf.Tstop];
end
if numel(simdef.bct.etaw)==1
    simdef.bct.etaw=simdef.bct.etaw.*ones(size(simdef.bct.time));
end
if any(size(simdef.bct.time)-size(simdef.bct.etaw))
    error('dimensions of etaw boundary condition do not agree')
end
    %correcting for last cell
if simdef.mdf.izbndpos==0
    simdef.bct.etaw=simdef.bct.etaw-simdef.grd.dx/2*simdef.ini.s; %displacement of boundary condition to ghost node
end
    %correcting for dpuopt. 
%This correction only makes sense in idealistic cases maybe. If bed level at velocity points is 'min' in an ideal case (normal flow, sloping case),
%there is a shift of half a cell in the water level at velocity points. To start under normal flow, we correct for that shift in the BC. 
if strcmp(simdef.mdf.Dpuopt,'min_dps')
    warning('correction of BC')
    simdef.bct.etaw=simdef.bct.etaw+simdef.grd.dx/2*simdef.ini.s;
    
    %as a consequence, the flow depth at the water level point is larger than it should and the velocity smaller. We correct the sedimen transport rate. 
    %ACal_corrected=ACal*qb_intended/qb_wrong
    %qb_wrong: sediment transport with the wrong velocity at water level point
    switch simdef.tra.IFORM
        case 4
            if simdef.tra.sedTrans(3)==0
                warning('correction ACal')
                h_wrong=simdef.ini.h+simdef.ini.s*simdef.grd.dx/2;
                u_wrong=simdef.bct.Q(1)/simdef.grd.B/h_wrong;
                simdef.tra.sedTrans(1)=simdef.tra.sedTrans(1)*(simdef.ini.u/u_wrong)^(simdef.tra.sedTrans(2)*2);
            else
                messageOut(NaN,'A correction should be applied to <ACal>')
            end
        otherwise
            messageOut(NaN,'A correction should be applied to <ACal>')
    end
end



%add extra time with same value as last in case the last time step gets outside the domain
if simdef.D3D.structure==2
simdef.bct.etaw=cat(1,simdef.bct.etaw,simdef.bct.etaw(end));
simdef.bct.time=cat(1,simdef.bct.time,simdef.bct.time(end)*1.1);
end

%% RENAME OUT

% simdef.grd.M=M;
% simdef.grd.N=N;
% % simdef_out.ini.etab=etab;
% simdef.ini.h=h;
% simdef.ini.u=u;
% simdef.grd.L=L;