%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18381 $
%$Date: 2022-09-23 16:08:29 +0800 (Fri, 23 Sep 2022) $
%$Author: chavarri $
%$Id: D3D_modify_bed_level.m 18381 2022-09-23 08:08:29Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_modify_bed_level.m $
%
%Modifies the bed elevation of a Delft3D-FM grid based on the 
%values along a polyline referenced to the river kilometer.
%
%Optionally, it first projects the input data to the river axis.
%
%Optionally, it modifies points only inside certain polygons. 
%
%Optionally, it modifies points only outside certain polygons. 
%
%INPUT:
%   -fpath_grd: full path to the grid to be modified [string]
%   -fpath_bedchg: full path to the ascii-file with bed elevation change data [string]
%       -column 1: river kilometer [km]
%       -column 2: river branch [string]. The branch name must match the naming in <fpath_rkm>.
%       -column 3: bed elevation change [m]
%   -fpath_rkm: full path to the file relating river kilometers, branches, and x-y coordinates [string]. See documentation of function <convert2rkm> for more input information. 
%
%OPTIONAL (pair input):
%   -axis: full path to an ascii-file with x-y coordinates of the river axis [string].
%   -polygon_in: full path to the shp-file or directory containing shp-files with poygons in which only points inside are to be modified [string]. 
%   -polygon_out: full path to the shp-file or directory containing shp-files with poygons in which only points outside are to be modified [string]. 
%   -factor: factor multiplying the input data of bed elevation change [-]. Default=1;
%   -fdir_output: full path to the folder where to save the output. [string]. Default is current directory. 
%   -plot: flag for plotting results [logical]. ATTENTION! this is a very crude plot. 
%   -save: flag for saving modified grid [logical].
%
%OUTPUT:
%   -

function D3D_modify_bed_level(fpath_grd,fpath_bedchg,fpath_rkm,varargin)

%% PARSE

fid_log=NaN; %maybe make a log file?

messageOut(fid_log,'Start parsing');

parin=inputParser;

addOptional(parin,'axis','');
addOptional(parin,'polygon_in','');
addOptional(parin,'polygon_out','');
addOptional(parin,'factor',1);
addOptional(parin,'plot',1);
addOptional(parin,'save',1);
addOptional(parin,'save_shp',0);
addOptional(parin,'fdir_output',pwd);
addOptional(parin,'debug',0);
addOptional(parin,'nparts_inpoly',100);
addOptional(parin,'delft3d_exe','c:\Program Files (x86)\Deltares\Delft3D Flexible Mesh Suite HMWQ (2021.03)\plugins\DeltaShell.Dimr\kernels\x64\dimr\scripts\run_dimr.bat');

parse(parin,varargin{:});

fpath_axis=parin.Results.axis;
fpath_pol_in=parin.Results.polygon_in;
fpath_pol_out=parin.Results.polygon_out;
trend_factor=parin.Results.factor;
flg.plot=parin.Results.plot;
flg.save=parin.Results.save;
flg.save_shp=parin.Results.save_shp;
fdir_output=parin.Results.fdir_output;
do_debug=parin.Results.debug;
nparts_inpoly=parin.Results.nparts_inpoly;
fpath_exe=parin.Results.delft3d_exe;

%% FLAGS and INI

do_axis=1;
if isempty(fpath_axis)
    do_axis=0;
end

do_pol_in=1;
if isempty(fpath_pol_in)
    do_pol_in=0;
end

do_pol_out=1;
if isempty(fpath_pol_out)
    do_pol_out=0;
end

if ~isnumeric(trend_factor)
    trend_factor=str2double(trend_factor);
    if isnan(trend_factor)
        error('ERROR! <trend_factor> is not numeric')
    end
end
if numel(trend_factor)>1
    error('ERROR! <trend_factor> can only be one number')
end

if ~isnumeric(do_debug)
    do_debug=str2double(do_debug);
    if isnan(do_debug)
        error('ERROR! <do_debug> is not numeric')
    end
end

mkdir_check(fdir_output,fid_log,1);

%% paths

[fdir_input,fname_grd,fext_grd]=fileparts(fpath_grd);

%would be nice to set the name of the inpolygon file with the name of the
%polygon file, but it becomes too long when using a set of polygons inside a 
%folder. 

% fname_pol='rivpol';

fname_inpol=sprintf('inpol_%s.mat',fname_grd);
fpath_inpol=fullfile(fdir_input,fname_inpol);

fname_outpol=sprintf('outpol_%s.mat',fname_grd);
fpath_outpol=fullfile(fdir_input,fname_outpol);

%% read bed level changes

messageOut(fid_log,'Start reading bed level changes')

fid=fopen(fpath_bedchg,'r');
raw_bl=textscan(fid,'%f %s %f');
fclose(fid);

etab_rkm=raw_bl{1,1};
etab_br=raw_bl{1,2};
etab_dz=raw_bl{1,3};

etab_xy=convert2rkm(fpath_rkm,etab_rkm,etab_br); %xy of the input data

%% river axis

if do_axis
    messageOut(fid_log,'Start projecting to river axis')
    
    %read
    fid=fopen(fpath_axis,'r');
    raw_axis=textscan(fid,'%f %f');
    fclose(fid);

    axis_xy=cell2mat(raw_axis);
else
    messageOut(fid_log,'Skip projecting to river axis')
    
    axis_xy=etab_xy;
end

%prevent identical points
[axis_x_c,axis_y_c,idx_g]=unique_polyline(axis_xy(:,1),axis_xy(:,2));
axis_xy=[axis_x_c,axis_y_c];

%project to axis
if do_axis    
    [axis_dz,idx_g]=z_interpolated_from_polyline(axis_xy(:,1),axis_xy(:,2),etab_xy(:,1),etab_xy(:,2),etab_dz);
else
    axis_dz=etab_dz(idx_g);
end

axis_br=etab_br(idx_g);
axis_dz=axis_dz.*trend_factor;  % apply correction

%% read grid

messageOut(fid_log,'Start reading grid')

switch fext_grd
    case '.nc'
        nodes_x=ncread(fpath_grd,'mesh2d_node_x');
        nodes_y=ncread(fpath_grd,'mesh2d_node_y');
        nodes_z=ncread(fpath_grd,'mesh2d_node_z');
    case '.tif'
        [I,Tinfo]=readgeotiff(fpath_grd);
        [x_m,y_m]=meshgrid(I.x,I.y);
        nodes_x=x_m(:);
        nodes_y=y_m(:);
        nodes_z=I.z(:);
end

np=numel(nodes_x);

%% read polygons of points to include

in_bol=true(np,1);
if do_pol_in
    messageOut(fid_log,'Start finding points in polygon')
    
    [x_pol_in,y_pol_in]=join_shp_xy(fpath_pol_in);
    if exist(fpath_inpol,'file')==2
        load(fpath_inpol,'in_bol')
    else
        in_bol=inpolygon_chunks(nodes_x,nodes_y,x_pol_in,y_pol_in,nparts_inpoly);
        save(fpath_inpol,'in_bol')
    end
else
    messageOut(fid_log,'Skip finding points in polygon')
end

%% read polygons of points to exclude

out_bol=false(np,1);
if do_pol_out
    messageOut(fid_log,'Start finding points out polygon')
    
    [x_pol_out,y_pol_out]=join_shp_xy(fpath_pol_out);
    if exist(fpath_outpol,'file')==2
        load(fpath_outpol,'out_bol')
    else
        out_bol=inpolygon_chunks(nodes_x,nodes_y,x_pol_out,y_pol_out,nparts_inpoly);
        save(fpath_outpol,'out_bol')
    end
else
    messageOut(fid_log,'Skip finding points out polygon')
end

%% identify grid points inside polygons

mod_bol=in_bol&~out_bol;

%% adapt 

messageOut(fid_log,'Start adapting grid')

[~,fname_bedchg]=fileparts(fpath_bedchg);
fname_etab=sprintf('%s.mat',fname_bedchg);
fpath_etab=fullfile(fdir_output,fname_etab);

if exist(fpath_etab,'file')~=2
    [axis_br_u,~,axis_br_u_idx]=unique(axis_br);
    nbr=numel(axis_br_u);

    np=numel(nodes_x);
    dz_loc=zeros(np,1);
    if ~do_debug
    for kp=1:np
        if ~mod_bol(kp)
            continue
        end
        dz_br=NaN(nbr,1);
        min_dist=NaN(nbr,1);
        for kbr=1:nbr
            bol_br=axis_br_u_idx==kbr;
            [dz_br(kbr),~,min_dist(kbr)]=z_interpolated_from_polyline(nodes_x(kp),nodes_y(kp),axis_xy(bol_br,1),axis_xy(bol_br,2),axis_dz(bol_br));
        end %kbr
        [~,min_idx]=min(min_dist);
        dz_loc(kp)=dz_br(min_idx);

        fprintf('changing elevation %4.2f %% \n',kp/np*100);
    end
    end %debug

    fprintf('changing elevation %4.2f %% \n',100);
    nodesZ_new=nodes_z+dz_loc;
    
    data=v2struct(nodesZ_new,dz_loc);
    save_check(fpath_etab,'data')
else
    load(fpath_etab,'data')
    v2struct(data)
end

%% save

if flg.save
    messageOut(fid_log,'Start save new grid')
    
    fname_grd_new=sprintf('%s_mod%s',fname_grd,fext_grd);
    
    switch fext_grd
        case '.nc'
            %grid
            fpath_grd_new=fullfile(fdir_output,fname_grd_new);
            copyfile_check(fpath_grd,fpath_grd_new);
            ncwrite_class(fpath_grd_new,'mesh2d_node_z',nodes_z,nodesZ_new);
            
            %this could also be done with tif files
            if flg.save_shp
                %shp modified
                fpath_shp=fullfile(fdir_output,sprintf('%s_etab_mod.shp',fname_grd)); 
                fpath_map=fullfile(fdir_output,sprintf('%s_mod_map.nc',fname_grd));
                [map_mod,polygons]=D3D_grd2shp(fpath_grd_new,'fpath_exe',fpath_exe,'fpath_map',fpath_map,'fpath_shp',fpath_shp);

                %shp original
                fpath_shp=fullfile(fdir_output,sprintf('%s_etab.shp',fname_grd)); 
                fpath_map=fullfile(fdir_output,sprintf('%s_map.nc',fname_grd));
                map=D3D_grd2shp(fpath_grd,'fpath_exe',fpath_exe,'fpath_map',fpath_map,'fpath_shp',fpath_shp);

                %shp difference
                map_diff=map_mod.val-map.val;
                fpath_shp=fullfile(fdir_output,sprintf('%s_etab_diff.shp',fname_grd)); 
                shapewrite(fpath_shp,'polygon',polygons,map_diff)
                messageOut(fid_log,sprintf('file created: %s',fpath_shp))
            end
        case '.tif'
            image=reshape(nodesZ_new,size(I.z));
            bit_depth=Tinfo.BitDepth;
            option.ModelTiepointTag=Tinfo.ModelTiepointTag;

            geotiffwrite(fname_grd_new,[],image, bit_depth, option)
    end
else
    messageOut(fid_log,'Skip save new grid')
end

%% PLOT

if flg.plot
    messageOut(fid_log,'Start plot')
    
    %% read locations for plot
    
    %really crude fast and dirty
    %It requires <fpath_rkm> to be in a certain format!
    
    rkm_raw=readmatrix(fpath_rkm);
    nrkm=numel(rkm_raw(:,1));
    drkm=5;
    
    %% polyline
    
    fdir_fig_1=fullfile(fdir_output,'fig_polyline');
    mkdir_check(fdir_fig_1);
    
    figure('visible','off')
    hold on
    scatter(etab_xy(:,1),etab_xy(:,2),20,etab_dz,'filled','marker','s','markeredgecolor','k')
    if do_debug
        fprintf('size axis_xy = %d',size(axis_xy));
        fprintf('size axis_dz = %d',size(axis_dz));
    end
    scatter(axis_xy(:,1),axis_xy(:,2),10,axis_dz,'filled','marker','o')
    legend('input','axis')
    axis equal
    han.cbar=colorbar;
    han.cbar.Label.String='bed level change [m]';
    for krkm=1:drkm:nrkm
        x_lims=rkm_raw(krkm,1)+[-drkm/2,+drkm/2].*1000;
        y_lims=rkm_raw(krkm,2)+[-drkm/2,+drkm/2].*1000;
        is_data=any(nodes_x>x_lims(1) & nodes_x<x_lims(2) & nodes_y>y_lims(1) & nodes_y<y_lims(2));
        if ~is_data
            continue
        end
        xlim(x_lims);
        ylim(y_lims);
        fname_fig=sprintf('polyline_%03d.png',krkm);
        fpath_fig=fullfile(fdir_fig_1,fname_fig);
        if exist(fpath_fig,'file')~=2
            print(gcf,fpath_fig,'-dpng','-r300')
        end
        fprintf('printing figure %4.2f %% \n',krkm/nrkm*100)
    end
    close(gcf)
    
    %% inside polygon
    
    fdir_fig_1=fullfile(fdir_output,'fig_polygon');
    mkdir_check(fdir_fig_1);
    
    figure('visible','off')
%     figure('visible','on')
    hold on
    scatter(nodes_x(mod_bol),nodes_y(mod_bol),2,'r','filled')
    scatter(nodes_x(~mod_bol),nodes_y(~mod_bol),2,'k','filled')
%     scatter(nodes_x(in_bol),nodes_y(in_bol),2,'r','filled')
%     scatter(nodes_x(~in_bol),nodes_y(~in_bol),2,'k','filled')
%     scatter(nodes_x(out_bol),nodes_y(out_bol),2,'r','filled')
%     scatter(nodes_x(~out_bol),nodes_y(~out_bol),2,'k','filled')
    if do_pol_in
        plot(x_pol_in,y_pol_in,'-b')
    end
    if do_pol_out
        plot(x_pol_out,y_pol_out,'-g')
    end
    axis equal
    for krkm=1:drkm:nrkm
        x_lims=rkm_raw(krkm,1)+[-drkm/2,+drkm/2].*1000;
        y_lims=rkm_raw(krkm,2)+[-drkm/2,+drkm/2].*1000;
        is_data=any(nodes_x>x_lims(1) & nodes_x<x_lims(2) & nodes_y>y_lims(1) & nodes_y<y_lims(2));
        if ~is_data
            continue
        end
        xlim(x_lims);
        ylim(y_lims);
        fname_fig=sprintf('polygon_%03d.png',krkm);
        fpath_fig=fullfile(fdir_fig_1,fname_fig);
        if exist(fpath_fig,'file')~=2
            print(gcf,fpath_fig,'-dpng','-r300')
        end
        fprintf('printing figure %4.2f %% \n',krkm/nrkm*100)
    end
    close(gcf)
    
    %% bed level change
    
    fdir_fig_1=fullfile(fdir_output,'fig_bed_change');
    mkdir_check(fdir_fig_1);
    
    cmap=brewermap(100,'RdYlGn');
    
    figure('visible','off')
% figure('visible','on')
    hold on
    scatter(nodes_x,nodes_y,2,dz_loc,'filled')
%     scatter(nodes_x,nodes_y,10,dz_loc,'filled')
    plot(x_pol_in,y_pol_in,'-b')
    han.cbar=colorbar;
    han.cbar.Label.String='bed level change [m]';
    clim(absolute_limits(dz_loc));
    colormap(cmap);
    axis equal
%     scatter(axis_xy(:,1),axis_xy(:,2),20,axis_dz,'filled','marker','o')
    plot(axis_xy(:,1),axis_xy(:,2),'c')
%     text(axis_xy(:,1),axis_xy(:,2),num2str(axis_dz))
    for krkm=1:drkm:nrkm
        x_lims=rkm_raw(krkm,1)+[-drkm/2,+drkm/2].*1000;
        y_lims=rkm_raw(krkm,2)+[-drkm/2,+drkm/2].*1000;
        is_data=any(nodes_x>x_lims(1) & nodes_x<x_lims(2) & nodes_y>y_lims(1) & nodes_y<y_lims(2));
        if ~is_data
            continue
        end
        xlim(x_lims);
        ylim(y_lims);
        fname_fig=sprintf('bed_change_%03d.png',krkm);
        fpath_fig=fullfile(fdir_fig_1,fname_fig);
        if exist(fpath_fig,'file')~=2
            print(gcf,fpath_fig,'-dpng','-r300')
        end
        fprintf('printing figure %4.2f %% \n',krkm/nrkm*100)
    end
    close(gcf)
else
    messageOut(fid_log,'Skip plot')
end

%% PLOT DEBUG

    
%     rkm_raw=readmatrix(fpath_rkm);
%     nrkm=numel(rkm_raw(:,1));
%     drkm=5;
%     
%     %%
% cmap=brewermap(100,'RdYlGn');
% figure('visible','on')
% hold on
% scatter(nodes_x,nodes_y,10,dz_loc,'filled')
% plot(x_pol_in,y_pol_in,'-b')
% han.cbar=colorbar;
% han.cbar.Label.String='bed level change [m]';
% clim(absolute_limits(dz_loc)+[-eps,+eps]);
% colormap(cmap);
% axis equal
% % plot(axis_xy(:,1),axis_xy(:,2),'c-*')
% % text(axis_xy(:,1),axis_xy(:,2),num2str(axis_dz))
% plot(rkm_raw(:,1),rkm_raw(:,2),'c-*')
% text(rkm_raw(:,1),rkm_raw(:,2),num2str(rkm_raw(:,4)))
% if do_pol_in
%     plot(x_pol_in,y_pol_in,'-b')
% end
% if do_pol_out
%     plot(x_pol_out,y_pol_out,'-g')
% end

end %function

