function extractPRO(input_data,ray_file,varargin)
%extractPRO  Extracts profiles from bathymetry data (grid+depth or wavm file)
%
%   Extracts and writes a unibest profile file (also computes location of shoreline, dynamic boundary and grid settings)
%
%   Syntax:
%      extractPRO(input_data,ray_file,z_dynbound, ref_level, path_out, pro_file, z_limits)
%
%   Input:
%      input_data           struct with filenames, with for each field a string with filename OR cellstring with filenames
%                             define either a grid with depth field or a wavm field, optional to define an input_path
%                             - input_data.grid & input_data.depth
%                             - input_data.wavm
%                             - input_data.path (optional, default = '')
%      ray_file             string with filename of polygon defining rays (ray1=[x1,y1;x2,y2], ray2=[x4,y4;x5,y5], etc) (x3,y3=NaN)
%      z_dynbound           depth at which dynamic boudnary is defined (optional; default = 8)
%      reference_level      reference level (optional; default = 0)
%      path_out             struct with output_paths for png and pro files (optional parameter, default = 'png\' & 'pro\')
%                             - path_out.pro  : string
%                             - path_out.png  : string
%      pro_file             (optional) filename of .PRO file (default = 'ray')
%      z_limits             (optional) maximum and minimum z-level (sepcify as bottom level!) included in profile ([zmin zmax])
%      no_samples           (optional) calibration parameter defining number of steps in x-direction (not advised to change, default = 20)
%
%   Output:
%      .pro-files
%      .png-figures with used samples and schematisation
%      .txt-file with used grids%
%
%   Example
%      input_depth.path     = 'D:\Projects\Z4581-Zandhonger Oosterschelde\2.setup_SWAN\SWAN_bathy&grids\'; % location of depth and grid files
%      input_depth.grid{1}  = 'med_walcheren.grd';                                 % grid second choice when deriving a cross-shore profile
%      input_depth.grid{2}  = 'coarse_zeeland.grd';                                % grid third choice when deriving a cross-shore profile
%      input_depth.depth{1} = 'med_walcheren_2004.dep';                            % depth second choice when deriving a cross-shore profile
%      input_depth.depth{2} = 'coarse_zeeland_2004N.dep';                          % depth third choice when deriving a cross-shore profile
%      z_dynbound           = 8;                                                   % depth at which the dynamic boundary (in the .pro-file{1}) is located
%      ref_level            = 0;                                                   % reference water level (i.e. chart datum = MSL -1.5m -> ref_level = -1.5)
%      ray_file             = [ldb_path,'profile_rays01to30.pol'];                 % string with filename of polygon defining rays (ray1=[x1,y1;x2,y2], ray2=[x4,y4;x5,y5], etc) (x3,y3=NaN)
%      path_out.png         = [unibest_path,'png\'];
%      path_out.pro         = [unibest_path];
%      PROfile              = {'ray'};
%      extractPRO(input_depth,ray_file{1},z_dynbound,ref_level,path_out,PROfile{1},[-15,5]);
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 <COMPANY>
%       huism_b
%
%       <EMAIL>
%
%       <ADDRESS>
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Jun 2014
% Created with Matlab version: 8.3.0.532 (R2014a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%-------------------------------------------------------------------------
% INPUT
%%-------------------------------------------------------------------------
if isempty(which('vs_use.m'))
    fprintf('Error : please add vs_use.m and vs_get.m from Delft3D matlab library!\n')
    return;
else
    z_dynbound   = 8;
    ref_level    = 0;
    path_out.png = 'png\';
    path_out.pro = 'pro\';
    pro_file     = 'ray';
    z_limits     = [];
    x_limits     = [-inf,inf];
    if nargin>2; z_dynbound   = varargin{1}; end
    if nargin>3; ref_level    = varargin{2}; end
    if nargin>4; path_out     = varargin{3}; end
    if nargin>5; pro_file     = varargin{4}; end
    if nargin>6; z_limits     = varargin{5}; end
    if nargin>7; x_limits     = varargin{6}; end

    %----input data profile schematisation-----
    minimum_no_points_truncation    = 5;      % minimum number of points before truncation above a specified level
    max_distance_between_gridpoints = 5;      % the specified ray (e.g. 2 points) is densified with this discretisation step 
    max_dist_from_line_factor       = 10;       % 'nearest depth samples' are only included if distance between sample is smaller than 'this factor' x 'gridcellsize'
    z_stepsize                      = 0.1;     % the stepsize in z-direction of the resampled cross-shore profile (determining the schematised number of depth points)
    resample_refine_factor          = 1;       % calibration parameter: profile is resampled to 'resample_refine_factor' times the 'no_samples' in the preprocessing of the profile schematisation (note: set to 1 to cancel preprocessing) 
    NANvalue                        = -999;     
    replaceNAN                      = nan;    %replaceNAN=-3;    
    %not implemented yet :   truncation_depth = 4;    % depth larger than ..m not included in the resampling (note: if depth is defined as a bottom level a negative value should be used)
    if nargin==9
        no_samples = varargin{7};  %calibration parameter: number of steps in x-direction for initial horizontal discretisation
    else
        no_samples = 20;           %calibration parameter: number of steps in x-direction for initial horizontal discretisation
    end


    %----input data profile schematisation-----
    legendtext = {'original samples',...
                  'reduced sample set (smallest distance to sample only)',...
                  'resampled profile 1 (1st order)',...
                  'resampled profile 2 (2nd order)'};

    %-------------------------------------------------------------------------
    %--------------------------------PROGRAM----------------------------------
    %-------------------------------------------------------------------------

    %------------read ray data--------------
    rays = readLDBS([ray_file]);
    %------------adjust z_dynbound if single value is specified--------------
    if length(z_dynbound)<length(rays)
        z_dynbound = repmat(z_dynbound(1),[length(rays),1]);
    end

    %-------------------read grid data--------------------
    %-----------------------------------------------------
    clear X Y Z grid_maxsamples samplesize ray
    IN1={};IN2={};
    wavm_grid_no = repmat(0,[length(rays),1]);

    if isfield(input_data,'grid')
        % check which grid file covers the output location (stored in wavm_select)
        input_data.used = input_data.grid;
        if isstr(input_data.used)
            input_data.used={input_data.used};
        end
        if isstr('input_data.path')
            input_data.path=num2cell(repmat(input_data.path,[length(input_data.used),1]),2);
            if isempty(input_data.path)
                input_data.path={''}; 
            end
        end
        for ii=1:length(input_data.used)
            XY    = wlgrid('read',[input_data.path{ii},input_data.used{ii}]);
            X{ii} = XY.X;
            Y{ii} = XY.Y;
            Z{ii} = wldep('read',[input_data.path{ii},input_data.depth{ii}],XY);
            %Z{ii}(Z{ii}==NANvalue) = replaceNAN;
            xv = [X{ii}(1,1:end)';X{ii}(1:end,end);X{ii}(end,end:-1:1)';X{ii}(end:-1:1,1)];
            yv = [Y{ii}(1,1:end)';Y{ii}(1:end,end);Y{ii}(end,end:-1:1)';Y{ii}(end:-1:1,1)];
            figure;plot(xv,yv,'b-');hold on;
            for jj=1:length(rays)
                IN1{ii}(jj,1) = inpolygon([rays(jj).x(1)],[rays(jj).y(1)],xv,yv);
                IN2{ii}(jj,1) = inpolygon([rays(jj).x(2)],[rays(jj).y(2)],xv,yv);
                plot([rays(jj).x(1)],[rays(jj).y(1)],'g*') 
                plot([rays(jj).x(2)],[rays(jj).y(2)],'m*')
            end
            % one of both points should be within wavm-file boundaries
            wavm_grid_no(wavm_grid_no==0 & (IN1{ii}==1 | IN2{ii}==1))=ii;
            % both points should be within wavm-file boundaries
            %wavm_grid_no(wavm_grid_no==0 & IN1{ii}==1 & IN2{ii}==1)=ii;
        end
    elseif isfield(input_data,'wavm')
        % check which wavm file covers the output location (stored in wavm_select)
        input_data.used = input_data.wavm;
        if isstr(input_data.used)
            input_data.used={input_data.used};
        end
        if isstr('input_data.path')
            input_data.path=num2cell(repmat(input_data.path,[length(input_data.used),1]),2);
        end
        for ii=1:length(input_data.used)
            wavm=[input_data.path{ii},input_data.used{ii}];
            vs_use(wavm);
            X{ii} = vs_get('map-series',{1},'XP');
            Y{ii} = vs_get('map-series',{1},'YP');
            Z{ii} = vs_get('map-series',{1},'DEPTH');
            Z{ii}(Z{ii}==NANvalue) = replaceNAN;
            xv = [X{ii}(1,1:end)';X{ii}(1:end,end);X{ii}(end,end:-1:1)';X{ii}(end:-1:1,1)];
            yv = [Y{ii}(1,1:end)';Y{ii}(1:end,end);Y{ii}(end,end:-1:1)';Y{ii}(end:-1:1,1)];
            for jj=1:length(rays)
                IN1{ii}(jj,1) = inpolygon([rays(jj).x(1)],[rays(jj).y(1)],xv,yv);
                IN2{ii}(jj,1) = inpolygon([rays(jj).x(2)],[rays(jj).y(2)],xv,yv);
                IN3{ii}(jj,1) = inpolygon([(rays(jj).x(1)+rays(jj).x(2))/2],[(rays(jj).y(1)+rays(jj).y(2))/2],xv,yv);
            end
            % one of both points should be within wavm-file boundaries
            wavm_grid_no(wavm_grid_no==0 & (IN1{ii}==1 | IN2{ii}==1))=ii;
            % both points should be within wavm-file boundaries
            %wavm_grid_no(wavm_grid_no==0 & IN1{ii}==1 & IN2{ii}==1)=ii;
        end
    end
    % force the use of the first wavm / depth model files if it is outside the grids
    wavm_grid_no(wavm_grid_no==0)=1;

    if ~exist(path_out.pro,'dir')
        mkdir(path_out.pro);
    end

    ray = struct;

    fid2 = fopen([path_out.pro,'ray_grids.txt'],'wt');
    fprintf('\nfinding nearest samplepoints\n');
    fprintf('----------------------------\n');
    fprintf(fid2,'\nray definition and grid used\n');
    fprintf(fid2,'----------------------------\n');
    %-----------------interpolate samples-----------------
    %-----------------------------------------------------
    for ray_no = 1 : length(rays)
        ii = wavm_grid_no(ray_no);
        clear unique_id
        ray.X0= rays(ray_no).x(1:2);
        ray.Y0 = rays(ray_no).y(1:2);
        xy0 = add_equidist_Points(max_distance_between_gridpoints,[ray.X0,ray.Y0]);
        xy0 = [xy0(2:end-1,1) , xy0(2:end-1,2)];
        ray.X1{ray_no} = xy0(:,1);
        ray.Y1{ray_no} = xy0(:,2);
        %figure;plot(ray.XI1,ray.YI1,'ro');hold on;plot(ray.XY2(:,1),ray.XY2(:,2),'b.-');
        %ZI = interp2(X{ii},Y{ii},Z{ii}(1:end-1,1:end-1),ray.X1,ray.Y1);

        %-------write used grid for each ray to screen--------
        %-----------------------------------------------------
        if wavm_grid_no(ray_no)~=0
            fprintf(' ray: %4.0f    grid:  %s\n',ray_no,input_data.used{wavm_grid_no(ray_no)});
            fprintf(fid2,' ray: %4.0f    grid:  %s\n',ray_no,input_data.used{wavm_grid_no(ray_no)});
        else
            fprintf(' ray: %4.0f    grid:  %s\n',ray_no,'outside domain');
            fprintf(fid2,' ray: %4.0f    grid:  %s\n',ray_no,'outside domain');
        end
        fprintf(' x= %10.3f, y= %10.3f\n',[ray.X0,ray.Y0]');
        fprintf(fid2,' x= %10.3f, y= %10.3f\n',[ray.X0,ray.Y0]');

        %--------get sample point for each grid point---------
        %-----------------------------------------------------
        for xloc = 1: size(ray.X1{ray_no},1)
            dx   = X{ii} - ray.X1{ray_no}(xloc);
            dy   = Y{ii} - ray.Y1{ray_no}(xloc);
            dist = sqrt(dx.^2+dy.^2);
            id2  = find(dist==min(min(dist)));
            idn  = ceil(id2/size(X{ii},1));
            idm  = mod(id2-1,size(X{ii},1))+1;

            ray.Z1{ray_no}(xloc)   = Z{ii}(idm,idn);
            ray.dist2sample1{ray_no}(xloc) = dist(idm,idn);
        end

        %----select only those depthsamples closest to ray----
        %-----------------------------------------------------
        for iii=1:size(ray.Z1{ray_no},2)
            id3 = find(ray.Z1{ray_no} == ray.Z1{ray_no}(iii));
            unique_id(iii) = find(ray.dist2sample1{ray_no} == min(ray.dist2sample1{ray_no}(id3)));
        end
        dist_offset = (unique_id(1)-1)*max_distance_between_gridpoints;
        ray.X2{ray_no}   = ray.X1{ray_no}(unique(unique_id));
        ray.Y2{ray_no}   = ray.Y1{ray_no}(unique(unique_id));
        ray.Z2{ray_no}   = ray.Z1{ray_no}(unique(unique_id))';
        ray.dist2sample2{ray_no} = ray.dist2sample1{ray_no}(unique(unique_id));

        %------remove sample points far away from line--------
        %-----------------------------------------------------
        max_distance_from_line{ii} = max_dist_from_line_factor * sqrt( (X{ii}(2,2)-X{ii}(1,1)).^2 + (Y{ii}(2,2)-Y{ii}(1,1)).^2);

        if exist('max_distance_from_line','var')
            id4      = find(ray.dist2sample2{ray_no} < max_distance_from_line{ii});
            ray.X2{ray_no}    = ray.X2{ray_no}(id4);
            ray.Y2{ray_no}    = ray.Y2{ray_no}(id4);
            ray.Z2{ray_no}    = ray.Z2{ray_no}(id4)';
            ray.dist2sample2{ray_no} = ray.dist2sample2{ray_no}(id4);
        end

        %--------determine sample size for each grid----------
        %-----------------------------------------------------
        samplesize{ray_no} = size(ray.Z2{ray_no},2);

        %------------Compute cross-shore distance-------------
        %-----------------------------------------------------
        ray.distcross2{ray_no}=[];
        ray.distcross3{ray_no}=[];
        ray.distcross3B{ray_no}=[];
        ray.Z3{ray_no} = [];
        ray.Z3B{ray_no} = [];
        [ray.distcross1{ray_no}]=distXY(ray.X1{ray_no},ray.Y1{ray_no});
        if size(ray.Z2{ray_no},2)>1
            [ray.distcross2{ray_no}]=distXY(ray.X2{ray_no},ray.Y2{ray_no},dist_offset);

            %-----------------Schematise profile------------------
            %-----------------------------------------------------
            id_deep = find(ray.Z2{ray_no}==max(ray.Z2{ray_no}));
            id_land = find(ray.Z2{ray_no}==min(ray.Z2{ray_no}));
            %if id1(1)>id_land(1)
            %id3 = find(ray.Z2{ray_no}<truncation_depth);
            %id_sorted=sort( ismember([id3(1),id2(1)],[id1(1),id2(1)]));
            id_sorted=sort([id_deep;id_land]);

            xdata  = ray.distcross2{ray_no}(id_sorted(1):id_sorted(2));
            zdata  = ray.Z2{ray_no}(id_sorted(1):id_sorted(2));

%             if ~isempty(z_limits) & length(xdata)>minimum_no_points_truncation
%                 id_truncate = find(zdata < -z_limits(1) & zdata > -z_limits(2));
%                 xdata = xdata(id_truncate);
%                 zdata = zdata(id_truncate);
%             end

            % ------ pre-processing with fine resolution ----
            xnew                       = [min(xdata):round((max(xdata)-min(xdata))/no_samples):max(xdata)];
            znew                       = [min(zdata):z_stepsize/resample_refine_factor:max(zdata)];
            if length(zdata)>1
                xnew                   = sort(interp1(zdata,xdata,znew,'cubic'));
            end
            if ~isempty(xnew)
                id_truncate = find(znew < -z_limits(1) & znew > -z_limits(2));
                xnew = xnew(id_truncate);
                znew = znew(id_truncate);
            end
            
            % ------ step 1, horizontal interpolation ----
            ray.distcross3{ray_no}     = xnew;
            ray.Z3{ray_no}             = interp1(xdata,zdata,xnew,'cubic');
            % ------ step 2, vertical interpolation ----            
            znew                       = sort(ray.Z3{ray_no});
            znew                       = [min(znew):z_stepsize:max(znew)];
            xnew                       = sort(interp1(zdata,xdata,znew,'cubic'));
            xdata                      = ray.distcross3{ray_no};
            zdata                      = ray.Z3{ray_no};
            ray.Z3B{ray_no}            = interp1(xdata,zdata,xnew,'cubic'); 
            ray.distcross3B{ray_no}    = xnew;

            %-----------------plot cross-section------------------
            %-----------------------------------------------------
            figure;
            zsamples_1  = -1*ray.Z1{ray_no};
            zsamples_2  = -1*ray.Z2{ray_no};
            zsamples_3  = -1*ray.Z3{ray_no};
            zsamples_3B = -1*ray.Z3B{ray_no};
            id = find(~isnan(zsamples_1));
            if isempty(id); id=find(zsamples_1~=-NANvalue); end
            plot(ray.distcross1{ray_no}(id),zsamples_1(id),'k.');hold on;
            plot(ray.distcross2{ray_no},zsamples_2,'b-');
            plot(ray.distcross3{ray_no},zsamples_3,'r-.');
            plot(ray.distcross3B{ray_no},zsamples_3B,'g--');

            h_title = title(['grid: ',input_data.used{ii},', ray: ',num2str(ray_no,'%4.0f')]);
            set(h_title,'interpreter','none');
            h_leg = legend(legendtext{1:min(length(get(gca,'Children')),length(legendtext))});
            set(h_leg,'FontSize',7);

            if ~exist(path_out.png,'dir')
                mkdir(path_out.png);
            end
            print('-dpng','-r150','-zbuffer',[path_out.png,pro_file,num2str(ray_no,'%02.0f'),'.png'])

            %-----------------save cross-section------------------
            %-----------------------------------------------------
            if ~isempty(ray.Z3B{ray_no})
                gridnumber   = wavm_grid_no(ray_no);
                x1           = ray.distcross1{ray_no}';
                y1           = ray.Z1{ray_no}; 
                x1s          = ray.distcross3{ray_no}; %ray.distcross3B{ray_no};
                y1s          = ray.Z3{ray_no};   % <-- using thinned version 1 (.Z3) and not number 2 (.Z3B)
                id           = find(y1~=NANvalue); x1=x1(id); y1=y1(id);
                idx1         = find(x1>x_limits(1) & x1<x_limits(2));%plot(x1(idx1),-y1(idx1),'r')
                idx2         = find(x1s>x_limits(1) & x1s<x_limits(2));%plot(x1s(idx2),-y1s(idx2),'r')
                filename1    = [path_out.pro,pro_file,num2str(ray_no,'%02.0f'),'_orig.pro'];
                filename2    = [path_out.pro,pro_file,num2str(ray_no,'%02.0f'),'.pro'];
                err_message1 = writePRO(x1(idx1),y1(idx1),z_dynbound(ray_no), filename1, ref_level);
                err_message2 = writePRO(x1s(idx2),y1s(idx2),z_dynbound(ray_no), filename2, ref_level);
                if ~isempty(err_message1);fprintf(fid2,'%s\n',err_message1);end
                if ~isempty(err_message2);fprintf(fid2,'%s\n',err_message2);end
            end
            close all
        end
    end
    ray = orderfields(ray, {'X0', 'Y0', 'X1', 'Y1', 'Z1', 'distcross1', 'dist2sample1', 'X2', 'Y2', 'Z2', 'distcross2', 'dist2sample2', 'Z3', 'distcross3', 'Z3B', 'distcross3B'});
end