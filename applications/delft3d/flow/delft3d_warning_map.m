function delft3d_warning_map(varargin)
%DELFT3D_WARNING_MAP generates maps with warnings from a Delft3D-Flow
%computation based on warning messages within tri-diag files.
%
%The function requires a *.mdf within the folder where the Delft3D-Flow
%model was executed (can be a running model, both sequential or parallel).
%Simply supply the *.mdf as an input variable (text string, with or without
%location), or just call the function to be prompted for a *.mdf.
%
%Syntax example:
%   delft3d_warning_map;
%   delft3d_warning_map('D:/my_delft3d_flow_model/flow_model.mdf');
%
%See also: delft3d_io_grd, delft3d_io_mdf

%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Freek Scheel
%
%       <Freek.Scheel@deltares.nl>
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
if length(varargin)>0
    if ischar(varargin{1})
        if exist(varargin{1},'file') ~= 2
            error(['The file ' varargin{1} ' does not exist'])
        end
    else
        error('Please specify a location/name of the mdf as a string');
    end
    if length(varargin)>1
        disp(['Too much input arguments (' num2str(length(varargin)) '), please supply only the location/name of the *.mdf as a string']);
    end
    [~,mdfName,mdfExt] =  fileparts(varargin{1});
    ft_1 = [mdfName,mdfExt];
else
    [ft_1,ft_2] = uigetfile({'*.mdf','*.mdf files'},'Pick a *.mdf');
    if ischar(ft_1) && ischar(ft_2)
        varargin{1} = [ft_2 ft_1];
    else
        disp('No file selected, aborted by user');
        return
    end
end

mdf_file = varargin{1};

if isempty(strfind(mdf_file,filesep))
    mdf_file = [pwd filesep mdf_file];
end

disp(' ');
disp('Initializing script...');
disp(' ');

[mdf_folder,mdf_filename,mdfExt] = fileparts(mdf_file);
mdf_filename = [mdf_filename,mdfExt];

mdf_data = delft3d_io_mdf('read',mdf_file);

if mdf_data.iostat == -1
    error(['Unable to successfully load the mdf: ' mdf_file]);
end

disp('Loading grid...');
disp(' ');

grd = delft3d_io_grd('read',[mdf_folder filesep mdf_data.keywords.filcco]);

% only select tri-diag files for chosen mdf
tri_diag_files = dir([mdf_folder filesep 'tri-diag.' ft_1(1:end-4),'*']);

if length(tri_diag_files)>0
    for tri_file_ind = 1:size(tri_diag_files,1)
        size_of_file(tri_file_ind,:) = [(ceil(tri_diag_files(tri_file_ind).bytes/(10^5))/10) tri_file_ind];
    end
else
    error(['No tri-diag file(s) found in the folder, did the model (started to) run in same the folder of the ' mdf_filename ' yet?']);
end

% if more than 1 tri-diag file is found, the simulation is run in parallel mode (in that case this function should cater for the local M,N reference used for each partition)
if length(tri_diag_files)>1
    parallelMode = 1;
else
    parallelMode = 0;
end
    
size_of_file_s = sortrows(size_of_file,1);

tri_files_text = {};

for loop_ind = 1:size(tri_diag_files,1)
    tri_file_ind = size_of_file_s(loop_ind,2);
    size_of_file_str           = [num2str(size_of_file(tri_file_ind,1),'%9.1f') ' MB'];
    if size_of_file(tri_file_ind) > 50
        size_of_file_str = [size_of_file_str ' - may take some time'];
    end
    disp(['Cashing tri-diag file ' num2str(loop_ind) ' out of ' num2str(size(tri_diag_files,1)) ' (' size_of_file_str ')']);

    fid = fopen([mdf_folder filesep tri_diag_files(tri_file_ind).name],'r');

    tmp = textscan(fid,'%s','Delimiter','\n');
    tri_files_text = [tri_files_text; tmp{:}];

    fclose all;
end
disp(' ');

MN_courant   = zeros(size(tri_files_text,1),2);
MN_vel_chan  = zeros(size(tri_files_text,1),2);
MN_wl_chan  = zeros(size(tri_files_text,1),2);
vel_chan_tel = 0;
wl_chan_tel = 0;
courant_tel  = 0;

tic;

disp('Searching for all locations where messages were thrown');

dialog_h = warndlg({['Progress = 0 %'];' ';['To only continue with the current'];['progress, press Cancel below']},'Searching locations');
set(findobj(get(dialog_h,'children'),'type','uicontrol'),'string','Cancel','enable','off');
button_enabled = 0;

vel_chan = 0;
wl_chan = 0;
MLocalRef = 1;
NLocalRef = 1;
for ii=1:size(tri_files_text,1)
    % update local reference for each partition (if Delft3D has run in parallel mode)
    if parallelMode
        if ~isempty(strfind(tri_files_text{ii,1},'mfg                  :'))
            [~,line2] = strtok(tri_files_text{ii,1},':');
            MLocalRef = str2num(line2(2:end));            
        end
        if ~isempty(strfind(tri_files_text{ii,1},'nfg                  :'))
            [~,line2] = strtok(tri_files_text{ii,1},':');
            NLocalRef = str2num(line2(2:end));            
        end
    end
    
    if (round(ii/max([1 floor(size(tri_files_text,1)/100)]))*max([1 floor(size(tri_files_text,1)/100)])) == ii
        if ishandle(dialog_h)==0
            break
        end
        if button_enabled == 0 && toc > 5
            set(findobj(get(dialog_h,'children'),'type','uicontrol'),'enable','on');
        end
        set(findobj(dialog_h,'type','text'),'string',{['Progress = ' num2str(round(100*ii/size(tri_files_text,1))) '% (E.T.A. = ' num2str(ceil((1-(ii/size(tri_files_text,1))) .* (toc / (ii/size(tri_files_text,1)))),'%9.0f') ' sec.)'];' ';['To only continue with the current'];['progress, press Cancel below']}); drawnow;
    end
    
    % store location where velocity change was too high (as reported in previous line)
    if vel_chan == 1
        if ~isempty(strfind(tri_files_text{ii,1},'(m,n,k) = (')) && ~isempty(strfind(tri_files_text{ii,1},', abs')) && isempty(strfind(tri_files_text{ii,1},'***'))
            comma_inds   = strfind(tri_files_text{ii,1},',');
            vel_chan_tel = vel_chan_tel + 1;
            MN_vel_chan(vel_chan_tel,:) = eval(['[' tri_files_text{ii,1}(1,12:comma_inds(4)-1) ']+[MLocalRef-1 NLocalRef-1]']);
        else
            vel_chan = 0;
        end
    end
    
    % store location where water level change was too high (as reported in previous line)
    if wl_chan == 1
        if ~isempty(strfind(tri_files_text{ii,1},'(m,n) = (')) && ~isempty(strfind(tri_files_text{ii,1},', abs')) && isempty(strfind(tri_files_text{ii,1},'***'))
            comma_inds   = strfind(tri_files_text{ii,1},',');
            wl_chan_tel = wl_chan_tel + 1;
            MN_wl_chan(wl_chan_tel,:) = eval(['[' tri_files_text{ii,1}(1,10:comma_inds(3)-2) ']+[MLocalRef-1 NLocalRef-1]']);
        else
            wl_chan = 0;
        end
    end
    
    % If Velocity change too high is reported, check on next line for the M,N location
    if ~isempty(strfind(tri_files_text{ii,1},'*** WARNING Velocity change too high'))
        vel_chan = 1;
    end
    
    % If waterlevel change too high is reported, check on next line for the M,N location
    if ~isempty(strfind(tri_files_text{ii,1},'*** ERROR Water level change too high'))
        wl_chan = 1;
    end
    
    % check if Courant number warning is reported and get the M,N location
    if ~isempty(strfind(tri_files_text{ii,1},'*** MESSAGE Courant number for'))
        comma_inds  = strfind(tri_files_text{ii,1},',');
        courant_tel = courant_tel + 1;
        MN_courant(courant_tel,:) = eval(['[' tri_files_text{ii,1}(1,strfind(tri_files_text{ii,1},'(m,n,k) = (')+11:comma_inds(4)-1) ']+[MLocalRef-1 NLocalRef-1]']);
    end
end

if ii == size(tri_files_text,1)
    try; close(dialog_h); end
end

disp(' ');
disp('Processing all obtained data to unique grid-points...');

% remove trailing zeros:
MN_courant  = MN_courant(find(MN_courant(:,1) ~= 0),:);
MN_vel_chan = MN_vel_chan(find(MN_vel_chan(:,1) ~= 0),:);
MN_wl_chan = MN_wl_chan(find(MN_wl_chan(:,1) ~= 0),:);

% Only get the unique m,n indices:
MN_vel_chan = unique(MN_vel_chan,'rows');
MN_courant = unique(MN_courant,'rows');
MN_wl_chan = unique(MN_wl_chan,'rows');

%% get overview of partitioned grid for visualisation
if  parallelMode
    try        
       trim = qpfopen([mdf_folder filesep 'trim-' mdf_filename(1:end-4) '.dat']); 
       partitions = qpread(trim,'parallel partition numbers','griddata');
       partitions.Val = partitions.Val+1; % to match the partitions numbers with the numbers in the tri-diag filenames
       NrPartitions = nanmax(nanmax(partitions.Val));
       colormap = repmat([0.9 0.9 0.9; 0.7 0.7 0.7],100,1);
       colormap = colormap(1:NrPartitions,:);
    end
end

%% plotting
disp(' ');
if ~isempty(MN_courant)
    disp('Plotting image with Courant criteria warnings');
    fig = figure; set(fig,'color','w','inverthardcopy','off','name','Courant criteria warning locations')
    hold on
    if exist('partitions','var')        
        pcolorcorcen(partitions.X,partitions.Y,partitions.Val); hold on;
        set(gcf,'Colormap',colormap);
        caxis([1 nanmax(nanmax(partitions.Val))])
        shading interp
    end
    pcolor(grd.cor.x,grd.cor.y,nan(size(grd.cor.x))); hold on;
    for ii=1:size(MN_courant,1)
        % grd.cen.x & grd.cen.y - 1
        plot(grd.cen.x(MN_courant(ii,2)-1,MN_courant(ii,1)-1),grd.cen.y(MN_courant(ii,2)-1,MN_courant(ii,1)-1),'r.','markersize',20);
    end
    axis equal; grid on; box on; set(gca,'layer','top','color',[191 239 255]/255);
    xlabel(['X-direction [' grd.CoordinateSystem ' Coordinates]']);
    ylabel(['Y-direction [' grd.CoordinateSystem ' Coordinates]']);
    title(['Locations where Courant criteria > 1 have occured']);
    makedir([mdf_folder,filesep,'Warning_locations'])
    print(gcf,'-dpng','-r300',[mdf_folder,filesep,'Warning_locations',filesep,'Courant_criteria_warnings.png'])
    saveas(gcf,[mdf_folder,filesep,'Warning_locations',filesep,'Courant_criteria_warnings.fig'],'fig')
end

if ~isempty(MN_vel_chan)
    disp('Plotting image with velocity change warnings');
    fig = figure; set(fig,'color','w','inverthardcopy','off','name','Velocity change warning locations')
    hold on
    if exist('partitions','var')        
        pcolorcorcen(partitions.X,partitions.Y,partitions.Val); hold on;
        set(gcf,'Colormap',colormap);
        caxis([1 nanmax(nanmax(partitions.Val))])
        shading interp
    end
    pcolor(grd.cor.x,grd.cor.y,nan(size(grd.cor.x))); hold on;
    for ii=1:size(MN_vel_chan,1)
        % grd.cen.x & grd.cen.y - 2
        plot(grd.cen.x(MN_vel_chan(ii,2)-1,MN_vel_chan(ii,1)-1),grd.cen.y(MN_vel_chan(ii,2)-1,MN_vel_chan(ii,1)-1),'r.','markersize',20);
    end
    axis equal; grid on; box on; set(gca,'layer','top','color',[191 239 255]/255);
    xlabel(['X-direction [' grd.CoordinateSystem ' Coordinates]']);
    ylabel(['Y-direction [' grd.CoordinateSystem ' Coordinates]']);
    title(['Locations where velocity changes > 5 m/s after 0.5 timesteps have occured']);
    makedir([mdf_folder,filesep,'Warning_locations'])
    print(gcf,'-dpng','-r300',[mdf_folder,filesep,'Warning_locations',filesep,'velocity_change_warnings.png'])
    saveas(gcf,[mdf_folder,filesep,'Warning_locations',filesep,'velocity_change_warnings.fig'],'fig')
end

if ~isempty(MN_wl_chan)
    disp('Plotting image with water level change errors');
    fig = figure; set(fig,'color','w','inverthardcopy','off','name','Water level error locations')
    hold on
    if exist('partitions','var')        
        pcolorcorcen(partitions.X,partitions.Y,partitions.Val); hold on;
        set(gcf,'Colormap',colormap);
        caxis([1 nanmax(nanmax(partitions.Val))])
        shading interp
    end
    pcolor(grd.cor.x,grd.cor.y,nan(size(grd.cor.x))); hold on;
    for ii=1:size(MN_wl_chan,1)
        % grd.cen.x & grd.cen.y - 1
        plot(grd.cen.x(MN_wl_chan(ii,2)-1,MN_wl_chan(ii,1)-1),grd.cen.y(MN_wl_chan(ii,2)-1,MN_wl_chan(ii,1)-1),'r.','markersize',20);
    end
    axis equal; grid on; box on; set(gca,'layer','top','color',[191 239 255]/255);
    xlabel(['X-direction [' grd.CoordinateSystem ' Coordinates]']);
    ylabel(['Y-direction [' grd.CoordinateSystem ' Coordinates]']);
    title(['Locations where water level changes > 20 m have occured']);
    makedir([mdf_folder,filesep,'Warning_locations'])
    print(gcf,'-dpng','-r300',[mdf_folder,filesep,'Warning_locations',filesep,'water_level_change_warnings.png'])
    saveas(gcf,[mdf_folder,filesep,'Warning_locations',filesep,'water_level_change_warnings.fig'],'fig')
end

if isempty(MN_courant) && isempty(MN_vel_chan)
    disp('No warning messages were found, what a clean model you have there');
else
    disp(' ');
    disp('Script completed succesfully');
end

end

















