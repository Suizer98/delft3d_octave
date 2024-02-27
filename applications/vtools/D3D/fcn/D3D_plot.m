%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17803 $
%$Date: 2022-03-02 16:37:07 +0800 (Wed, 02 Mar 2022) $
%$Author: chavarri $
%$Id: D3D_plot.m 17803 2022-03-02 08:37:07Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_plot.m $
%
function out_read=D3D_plot(simdef,in_read,def)

%% defaults

if isfield(simdef.flg,'save_data')==0
    simdef.flg.save_data=0;
end

%%
if def.sim_in==3
    run(def.script)
end

%number of simulations to analyze
switch def.sim_in
    case 1
        ns=numel(def.simulations); 
    case 2
        ns=1;
    case 3
%         ns=numel(def_folder);
          ns=numel(allinput);
end

%variables to plot
which_v=simdef.flg.which_v;
nv=numel(which_v);

%% loop on simulations
for ks=1:ns
% ks=1
    if def.sim_in==3
%         script2in
        v2struct(allinput(ks));
    end %flg.sim_in
    
    %computer paths
    switch def.sim_in
        case 1
%             if isfield(simdef,'D3D') && isfield(simdef.D3D,'dire_sim')
%                 D3D=rmfield(simdef.D3D,'dire_sim');
%                 simdef.D3D=D3D;
%             end
%             simdef.runid.number=def.simulations{ks};
%             simdef.runid.serie=def.series{ks};
%             simdef.D3D.paths_runs=def.paths_runs;
            simdef.D3D.dire_sim=fullfile(def.paths_runs,def.simulations{ks});
        case {2,3}
%             if isfield(def,'folder')==0
                def.folder=simdef.D3D.dire_sim;
                aux.strspl=strsplit(def.folder,'\');
                simdef.runid.number=str2double(aux.strspl{end-1});
                simdef.runid.serie=aux.strspl{end-2};
%             end
    end %flg.sim_in
%     simdef=D3D_comp(simdef);
    
%     D3D_plot_single_simulation(simdef,in_read,def) %proposal to cut
    
    %simulation paths
    simdef=D3D_simpath(simdef);
    
    %create figures folder (if it does not exist yet)
    if exist(fullfile(simdef.D3D.dire_sim,'figures'),'dir')==0
       mkdir(simdef.D3D.dire_sim,'figures')
    end
    
    %% PLOT GRID
    if strcmp(simdef.flg.which_p,'grid')
        out_read=D3D_read(simdef,NaN);
        D3D_figure_domain(simdef,out_read);
    else
            
    %dimensions
    in_read.kt=0; %give as output the domain size
    out_read=D3D_read(simdef,in_read);
    
    %create results time vector
    nTt=out_read.nTt; %number of map time results
    if ~ischar(simdef.flg.which_p)
        switch def.rsl_input
            case 0
                aux.rsl_v=1:1:nTt; %old
    %             aux.rsl_v=[1,nTt]; %new NO!!
            case 1
                if isnan(def.rsl_time)
                    aux.rsl_v=nTt;
                else
                    aux.rsl_v=def.rsl_time;
                end
            case 2
                aux.rsl_v=1:def.rsl_time:nTt;
        end
    else
        switch def.rsl_input
            case 0
%                 aux.rsl_v=1:1:nTt; %old
                aux.rsl_v=[1,Inf]; %new NO!!
            case 1
                error('ups')
%                 if isnan(def.rsl_time)
%                     aux.rsl_v=nTt;
%                 else
%                     aux.rsl_v=def.rsl_time;
%                 end
            case 2
                error('ups')
%                 aux.rsl_v=1:def.rsl_time:nTt;
        end
    end
    
    %load elliptic
    if isfield(simdef.flg,'elliptic')==1 && simdef.flg.elliptic==1
        load(fullfile(simdef.D3D.dire_sim,'ect','eigen_ell_p'));
    end
    
    %% MAP
    if isa(simdef.flg.which_p,'double')
    if def.rsl_input==0 && isnan(simdef.flg.print) 
        error('You want to plot all time steps but do nothing with the plot. That is nonsense')
    end
    switch simdef.flg.which_p
        case {1,2,3,4,9,10}
        %% loop on time
            for kt=aux.rsl_v
            %% loop on variable
                for kv=1:nv

                    simdef.flg.which_v=which_v(kv);


    
                    switch simdef.D3D.structure
                        case 1
                            in_read.kt=kt; %old
                        case 2
                            in_read.kt=[kt,1]; %new 
                    end
                    out_read=D3D_read(simdef,in_read);
                    if simdef.flg.save_data
                        D3D_save(simdef,out_read)
                    end
                    switch simdef.flg.which_p
                        case 1 % 3D of bed elevation and gs
                            if simdef.D3D.structure==1
                                D3D_figure_3D(simdef,out_read);   
                            else
                                D3D_figure_3D_u(simdef,out_read);   
                            end
                        case 2 % 2DH
                            if simdef.D3D.structure==1
                                D3D_figure_2D(simdef,out_read); 
                            else
                                D3D_figure_2D_u(simdef,out_read); 
                            end
                            %kml

                            %
                        case 3 % 1D
                            if simdef.D3D.structure==1
                                D3D_figure_1D(simdef,out_read);   
                            else
                                D3D_figure_1D_u(simdef,out_read);  
                            end
                        case 4 % patch
                            D3D_figure_patch(simdef,out_read); 
                        case 9
    %                         if simdef.D3D.structure==1
    %                         else    
    %                             D3D_figure_2DV_u(simdef,out_read);
    %                             D3D_figure_2DV_x_u(simdef,out_read);
    %                             D3D_figure_2DV_y_u(simdef,out_read);
                                D3D_figure_2DV_z_u(simdef,out_read);
    %                             D3D_figure_2DV_yz_u(simdef,out_read);
    %                         end
                        case 10 %cross-sections
                            D3D_figure_crosssection(simdef,out_read);

                    end
                            %display
                    aux.strdisp=sprintf('kt=%d %4.2f %%',kt,kt/aux.rsl_v(end)*100);
                    disp(aux.strdisp)
                end %kv
            end %kt
        case 5
        %% xtz
            in_read.kt=aux.rsl_v;
            out_read=D3D_read(simdef,simdef,in_read);
            D3D_figure_xt2(simdef,simdef,out_read); 
        %% xz
        case 6
            in_read.kt=aux.rsl_v;
            out_read=D3D_read(simdef,simdef,in_read);
            D3D_figure_xz(simdef,simdef,out_read); 
        %% 0D
        case 7
            in_read.kt=aux.rsl_v;
            out_read=D3D_read(simdef,simdef,in_read);
        %% 2DH cumulative in time
        case 8
            in_read.kt=aux.rsl_v; 
            out_read=D3D_read(simdef,simdef,in_read);
            D3D_figure_2D(simdef,simdef,out_read); 
        otherwise
                error('mmm')
    end
    %% HIS
    else
    switch simdef.flg.which_p
        case {'a'}
        %% loop on time
            for kt=aux.rsl_v
                in_read.kt=kt; 
                out_read=D3D_read(simdef,in_read);
                switch simdef.flg.which_p
                    case {'a'}
                        D3D_figure_his_verticalprofile(simdef,out_read); 
                end %which_p (2)
            end %kt
        %% other
        case {'b'}
            in_read.kt=aux.rsl_v; 
            out_read=D3D_read(simdef,in_read);
            D3D_figure_his(simdef,out_read); 
    end %loop on time
    end %his
    end %grid

        
end %ks


end 