%% Check created models

clear all
close all
clc

%% 0. Settings
% destin = 'p:\11207152-dca-sfincs\03_modelruns\version06\northwest_2006_original\subgrid\';
destin = 'p:\11207152-dca-sfincs\03_modelruns\version05\northwest_2006_original\subgrid\';

names = {'dx_100_adv0'}; %'dx_100_adv0','dx_1000_adv0',

% sbgin = 'p:\11207152-dca-sfincs\03_modelruns\version06\northwest_2006_original\subgrid\dx_50_adv0\';
sbgin = 'p:\11207152-dca-sfincs\03_modelruns\version05\northwest_2006_original\subgrid\dx_100_adv0\';


%% 1. Load data and plot
varplot = {'z_zmin','u_zmin','v_zmin','z_zmax','u_zmax','v_zmax'};
cmin = -5;
cmax = 5;

for ii = 1:length(names)
    destintmp = [destin, names{ii},filesep];
    cd(destintmp)
    
    subgrd=sfincs_read_binary_subgrid_tables_v8(destintmp);

    inp=struct;
    inp = sfincs_read_input([destintmp, 'sfincs.inp'],inp);

    points=sfincs_read_observation_points(inp.obsfile);
    
    [xg,yg,xz,yz]=sfincs_make_grid(inp.x0,inp.y0,inp.dx,inp.dy,inp.mmax,inp.nmax,inp.rotation);

    [z,msk]=sfincs_read_binary_inputs(inp.mmax,inp.nmax,inp.indexfile,inp.depfile,inp.mskfile);
    
    xz_ = xz(:);
    yz_ = yz(:);
    msk_ = msk(:);
    
    factor = 1000;
    for jj = 1:length(varplot)
        vartmp = subgrd.(varplot{jj});
        vartmp_ = vartmp(:);
        
        id_missing = isnan(vartmp_) & ~isnan(msk_);
        
        close all
        A4fac(1); hold on;
        axis equal
        pcolor(xz/factor,yz/factor,vartmp); shading flat
%         plot(ldbx/factor, ldby/factor,'w')    
        title(varplot{jj},'interpreter','none')
        cb = colorbar;
        ylabel(cb, 'Elevation [m+NAVD88]')
        caxis([cmin cmax])
        
        plot(xz_(id_missing)/factor,yz_(id_missing)/factor,'ms')
        
        for kk = 1:size(points.x,1)
           plot( points.x(kk)/factor, points.y(kk)/factor , 'r.')
           
           % determine value per station
           [index, distance, twoout] = nearxy(xz_, yz_, points.x(kk), points.y(kk));
           
           text(xz_(index)/factor,yz_(index)/factor, num2str(vartmp_(index),'%.2f'),'color','k')
           
        end
        xlabel('X in UTM17N [km]')
        ylabel('X in UTM17N [km]')
        
        xylim(xz/factor,yz/factor)
    
        printpng(['subgrid_',varplot{jj},'_',names{ii}])
        
    end
    

end

%% 2. Load data and plot - ones with multiple levels - manning
varplot = {'z_dep'};
cmin = -5;
cmax = 5;

level = 3;

for ii = 1:length(names)
    destintmp = [destin, names{ii},filesep];
    cd(destintmp)
    
    subgrd=sfincs_read_binary_subgrid_tables_v8(destintmp);

    inp=struct;
    inp = sfincs_read_input([destintmp, 'sfincs.inp'],inp);

    points=sfincs_read_observation_points(inp.obsfile);
    
    [xg,yg,xz,yz]=sfincs_make_grid(inp.x0,inp.y0,inp.dx,inp.dy,inp.mmax,inp.nmax,inp.rotation);

    [z,msk]=sfincs_read_binary_inputs(inp.mmax,inp.nmax,inp.indexfile,inp.depfile,inp.mskfile);
    
    xz_ = xz(:);
    yz_ = yz(:);
    msk_ = msk(:);
    
    factor = 1000;
    for jj = 1:length(varplot)
        vartmp = subgrd.(varplot{jj});
        vartmp = squeeze(vartmp(:,:,level));
        vartmp_ = vartmp(:);
        
        id_missing = isnan(vartmp_) & ~isnan(msk_);
        
        close all
        A4fac(1); hold on;
        axis equal
        pcolor(xz/factor,yz/factor,vartmp); shading flat
%         plot(ldbx/factor, ldby/factor,'w')    
        title(varplot{jj},'interpreter','none')
        cb = colorbar;
        ylabel(cb, 'Elevation [m+NAVD88]')
        caxis([cmin cmax])
        
        plot(xz_(id_missing)/factor,yz_(id_missing)/factor,'ms')
        
        for kk = 1:size(points.x,1)
           plot( points.x(kk)/factor, points.y(kk)/factor , 'r.')
           
           % determine value per station
           [index, distance, twoout] = nearxy(xz_, yz_, points.x(kk), points.y(kk));
           
           text(xz_(index)/factor,yz_(index)/factor, num2str(vartmp_(index),'%.2f'),'color','k')
           
        end
        xlabel('X in UTM17N [km]')
        ylabel('X in UTM17N [km]')
        
        xylim(xz/factor,yz/factor)
    
        printpng(['subgrid_',varplot{jj},'_',names{ii}])
        
    end
    

end

%% 3. Load data and plot - ones with multiple levels - manning
varplot = {'u_navg','v_navg'};
cmin = 0;
cmax = 0.06;

level = 3;

for ii = 1:length(names)
    destintmp = [destin, names{ii},filesep];
    cd(destintmp)
    
    subgrd=sfincs_read_binary_subgrid_tables_v8(destintmp);

    inp=struct;
    inp = sfincs_read_input([destintmp, 'sfincs.inp'],inp);

    points=sfincs_read_observation_points(inp.obsfile);
    
    [xg,yg,xz,yz]=sfincs_make_grid(inp.x0,inp.y0,inp.dx,inp.dy,inp.mmax,inp.nmax,inp.rotation);

    [z,msk]=sfincs_read_binary_inputs(inp.mmax,inp.nmax,inp.indexfile,inp.depfile,inp.mskfile);
    
    xz_ = xz(:);
    yz_ = yz(:);
    msk_ = msk(:);
    
    factor = 1000;
    for jj = 1:length(varplot)
        vartmp = subgrd.(varplot{jj});
        vartmp = squeeze(vartmp(:,:,level));
        vartmp_ = vartmp(:);
        
        id_missing = isnan(vartmp_) & ~isnan(msk_);
        
        close all
        A4fac(1); hold on;
        axis equal
        pcolor(xz/factor,yz/factor,vartmp); shading flat
%         plot(ldbx/factor, ldby/factor,'w')    
        title(varplot{jj},'interpreter','none')
        cb = colorbar;
        ylabel(cb, 'Elevation [m+NAVD88]')
        caxis([cmin cmax])
        
        plot(xz_(id_missing)/factor,yz_(id_missing)/factor,'ms')
        
        for kk = 1:size(points.x,1)
           plot( points.x(kk)/factor, points.y(kk)/factor , 'r.')
           
           % determine value per station
           [index, distance, twoout] = nearxy(xz_, yz_, points.x(kk), points.y(kk));
           
           text(xz_(index)/factor,yz_(index)/factor, num2str(vartmp_(index),'%.2f'),'color','k')
           
        end
        xlabel('X in UTM17N [km]')
        ylabel('X in UTM17N [km]')
        
        xylim(xz/factor,yz/factor)
    
        printpng(['subgrid_',varplot{jj},'_',names{ii}])
        
    end
    

end