%Reading sediment transport rate from map-file and compute cumulative
%value. 
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%200422

%add openearthtolls and RIV tools:
% -   https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab
% -   https://repos.deltares.nl/repos/RIVmodels/rivtools/trunk/matlab/scripts/vtools

%% PREAMBLE

clear
clc

%% INPUT

%path to the folder containing the runs
if ispc %windows
    path_runs='p:\11203223-tki-rivers\02_rijntakken_2020\04_runs\07_sedtrans_relation\'; 
else %cluster
    path_runs='../../04_runs/07_sedtrans_relation/'; 
end

%path to each folder containing .mdu or .md1d files
kf=0;

    %one by one
% kf=kf+1; 
% dire_sim_v{kf}=fullfile(path_runs,'/str_010/dflowfm/'); 

    %several
for ks=20:28
kf=kf+1; 
dire_sim_v{kf}=fullfile(path_runs,sprintf('/str_%03d/dflowfm/',ks)); 
end

%branches 
kb=0;

kb=kb+1;
branch_v{kb,1}={'29_A','29_B_A','29_B_B','29_B_C','29_B_D','52_A','52_B','31_A_A','31_A_B','31_A_C','31_B','51_A','BovenLobith','Bovenrijn'};

kb=kb+1;
branch_v{kb,1}={'Waal1','Waal2','Waal3','Waal4','Waal5','Waal6'}; 

kb=kb+1;
branch_v{kb,1}={'IJssel01','IJssel02','IJssel03','IJssel04','IJssel05','IJssel06','IJssel07','IJssel08','IJssel09','IJssel10','IJssel11','IJssel12'}; 

kb=kb+1;
branch_v{kb,1}={'PanKan1','PanKan2'}; 

kb=kb+1;
branch_v{kb,1}={'Nederrijn1','Nederrijn2','Nederrijn3','Nederrijn4','Nederrijn5','Nederrijn6','Lek1','Lek2','Lek4','Lek5','Lek6','Lek7','Lek8'}; 

%duration for creating cumulative results [s].
dt_cum=3600*24*365; 
% dt_cum=3600*24*30; warning('test value'); pause(1); %for testing

%conversion from xy to rkm (it increases coputational time, better to do it
%afterwards)
% in_read.path_rkm="c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\river_kilometers\rijntakken\irm\rkm_rijntakken_rhein.csv";
% in_read.rkm_curved="c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\river_kilometers\rijntakken\irm\rijn-flow-model_map_curved.nc";
% in_read.rkm_TolMinDist=300; %tolerance for accepting an rkm point

flg.do_profile=0;

%paths in p
path_p_oetools ='../../../04_software/01_matlab_tools/openearth/oetsettings.m';
path_p_rivtools='../../../04_software/01_matlab_tools/riv_matlab/rivsettings.m';

%% ADD PATHS IN P

if ~ispc
run(path_p_oetools)
run(path_p_rivtools)
end

%% other

simdef.flg.which_p=3; %plot type 
which_v=29; %29=sediment transport magnitude at edges m^2/s

%% max number time steps

nb=numel(branch_v);
ns=numel(dire_sim_v);

%preallocate
aux_max_nTt=NaN(ns,1);

for ks=1:ns

in_read.kt=0;
simdef.D3D.dire_sim=dire_sim_v{ks};
simdef=D3D_comp(simdef);
simdef=D3D_simpath(simdef);
out_read=D3D_read(simdef,in_read);

aux_max_nTt(ks)=out_read.nTt;
nf=out_read.nf;

end

max_nTt=min(aux_max_nTt);
% max_nTt=366; warning('test value'); pause(1); %for testing
fprintf('number of map results = %d \n',max_nTt)

%% GET DATA

time_v=1:1:max_nTt; %results time index vector.

%get results time vector
ks=1; %does not matter
in_read.kt=[1,max_nTt];
simdef.flg.which_v=0;
simdef.D3D.dire_sim=dire_sim_v{ks};
simdef=D3D_comp(simdef);
simdef=D3D_simpath(simdef);
out_read=D3D_read(simdef,in_read);
time_r=out_read.time_r;

%results interval vector
dt_r=diff(time_r);
dt_r=[dt_r(1);dt_r]; %we assume the first MapInterval to be the same as the second (in general it is constant).

%cumulative resuls time vector
time_rc=time_r(1):dt_cum:time_r(end);
ntc=numel(time_rc)-1;
 
if flg.do_profile
   profile off
   profile on 
end

%% loop on simulations
for ks=1:ns
    

    %separate results per branch
    kss=1;

    %simulation paths
    simdef.D3D.dire_sim=dire_sim_v{ks};
    simdef=D3D_comp(simdef);
    simdef=D3D_simpath(simdef);       
    simdef.flg.which_v=which_v; %read right variable
    
    %get number of size fractions
    dk=D3D_read_sed(simdef.file.sed);
    nf=numel(dk);
    
    %% loop on branches
    for kb=1:nb
        
        %results togehter
%         kbb=kb;
        %separate results per branch
        kbb=1;
        z=cell(1,1);
        SZ=cell(1,1);
        
        in_read.branch=branch_v{kb,1}; 
        ktc=1;
                
        %we parse it before for speeding up
        in_read.kf=1:1:nf;
        in_read.kF=NaN;
        in_read.kcs=NaN;
        in_read.nfl=1;
        
        %we call once to get branch dimension to preallocate
        kt=1;
        in_read.kt=[time_v(kt),1];
        out_read=NC_read_map(simdef,in_read); 
        z_loc=out_read.z*dt_r(kt); %m^2
        
        z{kss,kbb}=zeros(size(out_read.z,1),size(out_read.z,2),ntc);
        z{kss,kbb}(:,:,ktc)=z_loc;
        
        %% loop on time
        for kt=2:max_nTt      
            
            in_read.kt=[time_v(kt),1];
            out_read=NC_read_map(simdef,in_read); 
            
            z_loc=out_read.z*dt_r(kt); %m^2
            z{kss,kbb}(:,:,ktc)=z{kss,kbb}(:,:,ktc)+z_loc;
            
            if out_read.time_r>time_rc(ktc+1)
                if ktc~=ntc %we put the remaining ones in the last bin
                    ktc=ktc+1;
                end
            end
            
            %display
            fprintf('branch %4.2f %% simulation %4.2f %% time %4.2f %% \n',kb/nb*100,ks/ns*100,kt/max_nTt*100);
            
        end %kt
        
        SZ{kss,kbb}=out_read.SZ; %streamwise vector
        
        %save
        cum_sedtrans=v2struct(z,SZ,time_rc,branch_v);
        path_fold_res=fileparts(simdef.file.map);
        path_cum_sedtrans=fullfile(path_fold_res,sprintf('cum_sedtrans_branch_%d.mat',kb));
        save(path_cum_sedtrans,'cum_sedtrans')
                
    end %kb
end %ks

if flg.do_profile
    profile off
    profile viewer
end