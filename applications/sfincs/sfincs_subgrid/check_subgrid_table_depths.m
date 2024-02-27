%% Script to inspect subgrid tables from SFINCS
% v1.0  Leijnse     
% v2.0  Nederhoff   08-2022     - for SFINCS release
clear all
close all

% Settings
destin      = 'p:\11202255-sfincs\organise_scripts\sfincs_modelsetup\example01_SFBay\';
names{1}    = 'mymodel_subgrid25m';

%% Inspect these variables
varplot     = {'z_zmin','u_zmin','v_zmin','z_zmax','u_zmax','v_zmax'};
cmin        = -20;
cmax        = 20;

% Loop over the models
for ii = 1:length(names)
    
    % Go to Locations
    destintmp = [destin, names{ii},filesep];
    destout   = [destintmp, filesep, 'subgrid_figures']; mkdir(destout);
    
    % Read the data
    subgrd  = sfincs_read_binary_subgrid_tables(destintmp);
    inp     = struct;
    inp     = sfincs_read_input([destintmp, 'sfincs.inp'],inp);
    [xg,yg,xz,yz]=sfincs_make_grid(inp.x0,inp.y0,inp.dx,inp.dy,inp.mmax,inp.nmax,inp.rotation);
    
    % Go over variables
    factor = 1000;
    for jj = 1:length(varplot)
        
        % Get subset data
        vartmp = subgrd.(varplot{jj});
        
        % Make figure
        close all
        A4fig; hold on;
        axis equal
        pcolor(xz/factor,yz/factor,vartmp); shading flat
        title(varplot{jj},'interpreter','none')
        cb = colorbar;
        ylabel(cb, 'Elevation [m]')
        caxis([cmin cmax])
        xlabel('X [km]')
        ylabel('X [km]')
        axis tight
        cd(destout)
        print([varplot{jj}],'-dpng','-r200')
    end
    
    % Go over variables per level
    varplot     = {'z_dep','u_hrep','v_hrep'};
    level       = 1:size(subgrd.z_dep,3);

    for jj = 1:length(varplot)
        
        % Get subset data
        vartmp = subgrd.(varplot{jj});
        
        % Derermine range
        cmin        = round(quantile(vartmp(:),0.05));
        cmax        = round(quantile(vartmp(:),0.95));
        
        % Go over levels
        for ll = level
            
            % Make figure
            close all
            A4fig; hold on;
            axis equal
            pcolor(xz/factor,yz/factor,squeeze(vartmp(:,:,ll))); shading flat
            title([varplot{jj} ,'_level_', num2str(ll)],'interpreter','none')
            cb = colorbar;
            ylabel(cb, 'Elevation [m]')
            caxis([cmin cmax])
            xlabel('X [km]')
            ylabel('X [km]')
            axis tight
            cd(destout)
            print([varplot{jj},'_level_', num2str(ll)],'-dpng','-r200')
        end
    end

    % Go over manning per level
    varplot = {'u_navg','v_navg'};
    cmin    = 0.02;
    cmax    = 0.04;
    for jj = 1:length(varplot)
        
        % Get subset data
        vartmp = subgrd.(varplot{jj});
        
        % Go over levels
        for ll = level
            
            % Make figure
            close all
            A4fig; hold on;
            axis equal
            pcolor(xz/factor,yz/factor,squeeze(vartmp(:,:,ll))); shading flat
            title([varplot{jj} ,'_level_', num2str(ll)],'interpreter','none')
            cb = colorbar;
            ylabel(cb, 'Elevation [m]')
            caxis([cmin cmax])
            xlabel('X [km]')
            ylabel('X [km]')
            axis tight
            cd(destout)
            print([varplot{jj},'_level_', num2str(ll)],'-dpng','-r200')
        end
    end
end