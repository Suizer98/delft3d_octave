
function D3D_plot_testbench(case_name,path_sim_test,path_sim_ref,fig_prnt)

    simdef_test.D3D.dire_sim=path_sim_test;
    simdef_test=D3D_simpath(simdef_test);
    
    simdef_ref.D3D.dire_sim=path_sim_ref;
    simdef_ref=D3D_simpath(simdef_ref);
    
    path_figs=fullfile(path_sim_test,'figures');
    mkdir(path_figs);
%     nc_info=ncinfo(simdef_test.file.map);
    
    switch case_name
        case {'c01_mc_sediment_transport_Engelund_Hansen','c02_mc_sediment_transport_MPM'}
            node_x_test=ncread(simdef_test.file.map,'mesh1d_node_x');
            node_y_test=ncread(simdef_test.file.map,'mesh1d_node_y');
            tim_test=ncread(simdef_test.file.map,'time');
            
            node_x_ref=ncread(simdef_ref.file.map,'mesh1d_node_x');
            node_y_ref=ncread(simdef_ref.file.map,'mesh1d_node_y');

            var_v={'mesh1d_waterdepth', 'mesh1d_mor_bl','mesh1d_sbcx'};

            nb=4;
            branch_id=NaN(size(node_x_test));
            branch_id(1 :10)=1;
            branch_id(11:20)=2;
            branch_id(21:30)=3;
            branch_id(31:40)=4;

            nt=numel(tim_test);
%             cmap=brewermap(nt,'Reds');
            cmap=jet(nt);

            nv=numel(var_v);
            for kv=1:nv
                var_loc_test=ncread(simdef_test.file.map,var_v{kv});
                var_loc_ref=ncread(simdef_ref.file.map,var_v{kv});

                for kb=1:nb
                    
                    %% var
                    figure('visible',~fig_prnt)
                    subplot(2,1,1)
                    hold on
                    scatter(node_x_test,node_y_test,10,'k')
                    scatter(node_x_test(branch_id==kb),node_y_test(branch_id==kb),10,'r','filled')
                    xlabel('x-coordinate [m]')
                    ylabel('y-coordinate [m]')

                    subplot(2,1,2)
                    hold on
                    for kt=1:nt
                        han_test=plot(node_x_test(branch_id==kb),var_loc_test(branch_id==kb,kt),'color',cmap(kt,:),'linestyle','-','marker','o');
                        han_ref=plot(node_x_ref(branch_id==kb),var_loc_ref(branch_id==kb,kt),'color',cmap(kt,:),'linestyle','--','marker','*');
                    end
                    xlabel('x-coordinate [m]')
                    ylabel(strrep(var_v{kv},'_','\_'))
                    colorbar('location','northoutside')
                    clim([tim_test(1),tim_test(end)])
                    legend([han_test,han_ref],{'test','ref'})
                    colormap(cmap)
                    
                    if fig_prnt
                        print(gcf,fullfile(path_figs,sprintf('br_%02d_var_%02d.png',kb,kv)),'-dpng','-r300')
                    end
                    
                    %% diff
                    figure('visible',~fig_prnt)
                    subplot(2,1,1)
                    hold on
                    scatter(node_x_test,node_y_test,10,'k')
                    scatter(node_x_test(branch_id==kb),node_y_test(branch_id==kb),10,'r','filled')
                    xlabel('x-coordinate [m]')
                    ylabel('y-coordinate [m]')

                    subplot(2,1,2)
                    hold on
                    for kt=1:nt
                        han_diff=plot(node_x_test(branch_id==kb),var_loc_test(branch_id==kb,kt)-var_loc_ref(branch_id==kb,kt),'color',cmap(kt,:),'linestyle','-');
                    end
                    xlabel('x-coordinate [m]')
                    ylabel(strrep(var_v{kv},'_','\_'))
                    colorbar('location','northoutside')
                    clim([tim_test(1),tim_test(end)])
                    legend([han_test],{'difference'})
                    colormap(cmap)
                    
                    if fig_prnt
                        print(gcf,fullfile(path_figs,sprintf('br_%02d_var_%02d_diff.png',kb,kv)),'-dpng','-r300')
                    end
                    
                end %kb
            end %kv
        %%
        case 'c11_sediment_transport_bifurcation'
            node_x_test=ncread(simdef_test.file.map,'mesh1d_node_x');
            node_y_test=ncread(simdef_test.file.map,'mesh1d_node_y');
            node_branch_test=ncread(simdef_test.file.map,'mesh1d_node_branch');
            tim_test=ncread(simdef_test.file.map,'time');
            
            node_x_ref=ncread(simdef_ref.file.map,'mesh1d_node_x');
            node_y_ref=ncread(simdef_ref.file.map,'mesh1d_node_y');

            var_v={'mesh1d_waterdepth','mesh1d_mor_bl','mesh1d_s1'};

            nb=numel(unique(node_branch_test));
            branch_id=node_branch_test+1;

            nt=numel(tim_test);
%             cmap=brewermap(nt,'Reds');
            cmap=jet(nt);

            nv=numel(var_v);
            for kv=1:nv
                var_loc_test=squeeze(ncread(simdef_test.file.map,var_v{kv}));
                var_loc_ref=squeeze(ncread(simdef_ref.file.map,var_v{kv}));

                for kb=1:nb
                    
                    %% var
                    figure('visible',~fig_prnt)
                    subplot(2,1,1)
                    hold on
                    scatter(node_x_test,node_y_test,10,'k')
                    scatter(node_x_test(branch_id==kb),node_y_test(branch_id==kb),10,'r','filled')
                    xlabel('x-coordinate [m]')
                    ylabel('y-coordinate [m]')

                    subplot(2,1,2)
                    hold on
                    for kt=1:nt
                        han_test=plot(node_x_test(branch_id==kb),var_loc_test(branch_id==kb,kt),'color',cmap(kt,:),'linestyle','-','marker','o');
                        han_ref=plot(node_x_ref(branch_id==kb),var_loc_ref(branch_id==kb,kt),'color',cmap(kt,:),'linestyle','--','marker','*');
                    end
                    xlabel('x-coordinate [m]')
                    ylabel(strrep(var_v{kv},'_','\_'))
                    colorbar('location','northoutside')
                    clim([tim_test(1),tim_test(end)])
                    legend([han_test,han_ref],{'test','ref'})
                    colormap(cmap)
                    
                    if fig_prnt
                        print(gcf,fullfile(path_figs,sprintf('br_%02d_var_%02d.png',kb,kv)),'-dpng','-r300')
                    end
                    
                    %% diff
                    figure('visible',~fig_prnt)
                    subplot(2,1,1)
                    hold on
                    scatter(node_x_test,node_y_test,10,'k')
                    scatter(node_x_test(branch_id==kb),node_y_test(branch_id==kb),10,'r','filled')
                    xlabel('x-coordinate [m]')
                    ylabel('y-coordinate [m]')

                    subplot(2,1,2)
                    hold on
                    for kt=1:nt
                        han_diff=plot(node_x_test(branch_id==kb),var_loc_test(branch_id==kb,kt)-var_loc_ref(branch_id==kb,kt),'color',cmap(kt,:),'linestyle','-');
                    end
                    xlabel('x-coordinate [m]')
                    ylabel(strrep(var_v{kv},'_','\_'))
                    colorbar('location','northoutside')
                    clim([tim_test(1),tim_test(end)])
                    legend([han_test],{'difference'})
                    colormap(cmap)
                    
                    if fig_prnt
                        print(gcf,fullfile(path_figs,sprintf('br_%02d_var_%02d_diff.png',kb,kv)),'-dpng','-r300')
                    end
                    
                end %kb
            end %kv
        %
        case {'c31_shoal_ds_IBedCond0_us_IBedCond1','c32_shoal_ds_IBedCond0_us_IBedCond1_toe','c33_shoal_ds_IBedCond0_us_IBedCond1_toe_sd_low'}
            node_x_test=ncread(simdef_test.file.map,'mesh1d_node_x');
            node_x_ref=ncread(simdef_ref.file.map,'mesh1d_node_x');
            tim_test=ncread(simdef_test.file.map,'time');
            
            var_v={'mesh1d_waterdepth','mesh1d_mor_bl','mesh1d_s1'};
            
            nt=numel(tim_test);
            cmap=jet(nt);

            nv=numel(var_v);
            for kv=1:nv
                var_loc_test=squeeze(ncread(simdef_test.file.map,var_v{kv}));
                var_loc_ref=squeeze(ncread(simdef_ref.file.map,var_v{kv}));

                    %% var
                    figure('visible',~fig_prnt)
                    hold on
                    for kt=1:nt
                        han_test=plot(node_x_test,var_loc_test(:,kt),'color',cmap(kt,:),'linestyle','-','marker','o');
                        han_ref=plot(node_x_ref,var_loc_ref(:,kt),'color',cmap(kt,:),'linestyle','--','marker','*');
                    end
                    xlabel('x-coordinate [m]')
                    ylabel(strrep(var_v{kv},'_','\_'))
                    colorbar('location','northoutside')
                    clim([tim_test(1),tim_test(end)])
                    legend([han_test,han_ref],{'test','ref'})
                    colormap(cmap)
                    
                    if fig_prnt
                        print(gcf,fullfile(path_figs,sprintf('var_%02d.png',kv)),'-dpng','-r300')
                    end
                    
                    %% diff
                    figure('visible',~fig_prnt)
                    hold on
                    for kt=1:nt
                        han_diff=plot(node_x_test(:),var_loc_test(:,kt)-var_loc_ref(:,kt),'color',cmap(kt,:),'linestyle','-');
                    end
                    xlabel('x-coordinate [m]')
                    ylabel(strrep(var_v{kv},'_','\_'))
                    colorbar('location','northoutside')
                    clim([tim_test(1),tim_test(end)])
                    legend([han_test],{'difference'})
                    colormap(cmap)
                    
                    if fig_prnt
                        print(gcf,fullfile(path_figs,sprintf('var_%02d_diff.png',kv)),'-dpng','-r300')
                    end
                    
            end %kv
            
        otherwise
            messageOut(NaN,'no plotting function available')
    end
