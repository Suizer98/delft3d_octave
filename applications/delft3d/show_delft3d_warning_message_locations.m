function show_delft3d_warning_message_locations(varargin)

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
else
    [ft_1,ft_2] = uigetfile({'*.mdf','*.mdf files'},'Pick a *.mdf');
    if ischar(ft_1) && ischar(ft_2)
        vargarin{1} = [ft_2 ft_1];
    else
        disp('No file selected, aborted by user');
        return
    end
end

mdf_file = varargin{1};

if isempty(strfind(mdf_file,filesep))
    mdf_file = [pwd filesep mdf_file];
end

disp('Initializing...');
disp(' ');

mdf_folder   = mdf_file(1,1:(max(strfind(mdf_file,filesep))-1));
mdf_filename = mdf_file(1,(max(strfind(mdf_file,filesep))+1):end);

mdf_data = delft3d_io_mdf('read',mdf_file);

if mdf_data.iostat == -1
    error(['Unable to successfully load the mdf: ' mdf_file]);
end

grd = delft3d_io_grd('read',[mdf_folder filesep mdf_data.keywords.filcco]);

tri_diag_files = dir([mdf_folder filesep 'tri-diag.*']);

tri_files_text = {};
if length(tri_diag_files)>0
    if length(tri_diag_files)>1
        disp('Cashing contents of all tri-diag files:');
        disp(' ');
    else
        disp('Cashing contents of tri-diag file...');
    end
    for tri_file_ind = 1:size(tri_diag_files,1)
        if length(tri_diag_files)>0
            size_of_file(tri_file_ind) = ceil(tri_diag_files(tri_file_ind).bytes/(10^6));
            size_of_file_str           = [num2str(size_of_file(tri_file_ind)) ' MB'];
            if size_of_file(tri_file_ind) > 50
                size_of_file_str = [size_of_file_str '! (may take a while)'];
            end
            disp(['Cashing tri-diag file ' num2str(tri_file_ind) ' out of ' num2str(size(tri_diag_files,1)) ' (' size_of_file_str ')']);
        end
        
        fid = fopen([mdf_folder filesep tri_diag_files(tri_file_ind).name],'r');

        tmp = textscan(fid,'%s','Delimiter','\n');
        tri_files_text = [tri_files_text; tmp{:}];
        
        fclose all;
    end
    disp(' ');
else
    error(['No tri-diag file(s) found in the folder, did the model (started to) run in same the folder of the ' mdf_filename ' yet?']);
end

MN_courant   = zeros(size(tri_files_text,1),2);
MN_vel_chan  = zeros(size(tri_files_text,1),2);
MN_bed_chan  = zeros(size(tri_files_text,1),2);
MN_wl_chan   = zeros(size(tri_files_text,1),2);
MN_source_sink = zeros(size(tri_files_text,1),2);
T_vel_chan   = zeros(size(tri_files_text,1),1);
vel_chan_tel = 0;
courant_tel  = 0;
bed_chan_tel = 0;
wl_chan_tel  = 0;
source_sink_tel = 0;

if sum(size_of_file) > 100
    disp('Quite big files were loaded, this may take a while to analyse...');
    disp(' ');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% Scan text for messages %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vel_chan = 0;
wl_chan  = 0;
for ii=1:size(tri_files_text,1)
    if (round(ii/max([1 floor(size(tri_files_text,1)/100)]))*max([1 floor(size(tri_files_text,1)/100)])) == ii
        disp(['Progress = ' num2str(round(100*ii/size(tri_files_text,1))) '%'])
    end
    if ~isempty(strfind(tri_files_text{ii,1},'*** WARNING Velocity change too high'))
       ind1 = strfind(tri_files_text{ii,1},'after');
       ind2 = strfind(tri_files_text{ii,1},'timesteps');
       T_vel_chan(ii) = str2double(strtrim(tri_files_text{ii,1}(ind1+5:ind2-1))); 
    end
    % Velocity change WARNINGS
    if vel_chan == 1
        if ~isempty(strfind(tri_files_text{ii,1},'(m,n,k) = (')) && ~isempty(strfind(tri_files_text{ii,1},', abs')) && isempty(strfind(tri_files_text{ii,1},'***'))
            comma_inds   = strfind(tri_files_text{ii,1},',');
            vel_chan_tel = vel_chan_tel + 1;
            MN_vel_chan(vel_chan_tel,:) = eval(['[' tri_files_text{ii,1}(1,12:comma_inds(4)-1) ']']);
        else
            vel_chan = 0;
        end
    end
    if ~isempty(strfind(tri_files_text{ii,1},'*** WARNING Velocity change too high'))
        vel_chan = 1;
    end
    % Water level change ERRORS
    if wl_chan == 1
        if ~isempty(strfind(tri_files_text{ii,1},'(m,n) = (')) && ~isempty(strfind(tri_files_text{ii,1},', abs')) && isempty(strfind(tri_files_text{ii,1},'***'))
            comma_inds   = strfind(tri_files_text{ii,1},',');
            wl_chan_tel = wl_chan_tel + 1;
            MN_wl_chan(wl_chan_tel,:) = eval(['[' tri_files_text{ii,1}(1,10:comma_inds(3)-2) ']']);
        else
            wl_chan = 0;
        end
    end
    if ~isempty(strfind(tri_files_text{ii,1},'*** ERROR Water level change too high'))
        wl_chan = 1;
    end
    % Courant number MESSAGES
    if ~isempty(strfind(tri_files_text{ii,1},'*** MESSAGE Courant number for'))
        comma_inds  = strfind(tri_files_text{ii,1},',');
        courant_tel = courant_tel + 1;
        MN_courant(courant_tel,:) = eval(['[' tri_files_text{ii,1}(1,strfind(tri_files_text{ii,1},'(m,n,k) = (')+11:comma_inds(4)-1) ']']);
    end
    % Bed change WARNINGS
    if ~isempty(strfind(tri_files_text{ii,1},'*** WARNING Bed change exceeds'))
      close_bracket_inds  = strfind(tri_files_text{ii,1},')');
      bed_chan_tel = bed_chan_tel + 1;
      MN_bed_chan(bed_chan_tel,:) = eval(['[' tri_files_text{ii,1}(1,strfind(tri_files_text{ii,1},'(m,n) = (')+9:close_bracket_inds(2)-1) ']']);
    end
    % Source and sink term WARNINGS
    if ~isempty(strfind(tri_files_text{ii,1},'*** WARNING Source and sink term sediment'))
      comma_inds  = strfind(tri_files_text{ii,1},',');
      source_sink_tel = source_sink_tel + 1;
      MN_source_sink(source_sink_tel,:) = eval(['[' tri_files_text{ii,1}(1,strfind(tri_files_text{ii,1},'(m,n)=(')+7:comma_inds(3)-2) ']']);
    end
end

% remove trailing zeros:
MN_courant      = MN_courant(find(MN_courant(:,1) ~= 0),:);
MN_vel_chan     = MN_vel_chan(find(MN_vel_chan(:,1) ~= 0),:);
MN_bed_chan     = MN_bed_chan(find(MN_bed_chan(:,1) ~= 0),:);
MN_wl_chan      = MN_wl_chan(find(MN_wl_chan(:,1) ~= 0),:);
MN_source_sink  = MN_source_sink(find(MN_source_sink(:,1) ~= 0),:);
T_vel_chan      = sort(unique(T_vel_chan(find(T_vel_chan(:,1) ~= 0),:)));
T_vel_chan      = T_vel_chan(1:end-1);

% Only get the unique m,n indices:
if ~isempty(MN_vel_chan)
    % sort first row:
    MN_vel_chan = sortrows(MN_vel_chan,1);
    tel = 1;
    while tel < size(MN_vel_chan,1)
        MN_vel_chan(find(MN_vel_chan(:,1) == MN_vel_chan(tel,1)),:) = sortrows(MN_vel_chan(find(MN_vel_chan(:,1) == MN_vel_chan(tel,1)),:),2);
        tel = max(find(MN_vel_chan(:,1) == MN_vel_chan(tel,1)))+1;
    end
    tel_end   = size(MN_vel_chan,1);
    tel_start = size(MN_vel_chan,1)-1;
    while tel_start > 0
        while tel_start > 0 && (MN_vel_chan(tel_end,1) == MN_vel_chan(tel_start,1)) && (MN_vel_chan(tel_end,2) == MN_vel_chan(tel_start,2))
            tel_start = tel_start - 1;
        end
        if length(tel_start+1:tel_end)>1
            MN_vel_chan(tel_start+1:tel_end-1,:)=[];
        end
        tel_end = tel_start;
    end
end

if ~isempty(MN_courant)
    % sort first row:
    MN_courant = sortrows(MN_courant,1);
    tel = 1;
    while tel < size(MN_courant,1)
        MN_courant(find(MN_courant(:,1) == MN_courant(tel,1)),:) = sortrows(MN_courant(find(MN_courant(:,1) == MN_courant(tel,1)),:),2);
        tel = max(find(MN_courant(:,1) == MN_courant(tel,1)))+1;
    end
    tel_end   = size(MN_courant,1);
    tel_start = size(MN_courant,1)-1;
    while tel_start > 0
        while tel_start > 0 && (MN_courant(tel_end,1) == MN_courant(tel_start,1)) && (MN_courant(tel_end,2) == MN_courant(tel_start,2))
            tel_start = tel_start - 1;
        end
        if length(tel_start+1:tel_end)>1
            MN_courant(tel_start+1:tel_end-1,:)=[];
        end
        tel_end = tel_start;
    end
end

if ~isempty(MN_bed_chan)
    % sort first row:
    MN_bed_chan = sortrows(MN_bed_chan,1);
    tel = 1;
    while tel < size(MN_bed_chan,1)
        MN_bed_chan(find(MN_bed_chan(:,1) == MN_bed_chan(tel,1)),:) = sortrows(MN_bed_chan(find(MN_bed_chan(:,1) == MN_bed_chan(tel,1)),:),2);
        tel = max(find(MN_bed_chan(:,1) == MN_bed_chan(tel,1)))+1;
    end
    tel_end   = size(MN_bed_chan,1);
    tel_start = size(MN_bed_chan,1)-1;
    while tel_start > 0
        while tel_start > 0 && (MN_bed_chan(tel_end,1) == MN_bed_chan(tel_start,1)) && (MN_bed_chan(tel_end,2) == MN_bed_chan(tel_start,2))
            tel_start = tel_start - 1;
        end
        if length(tel_start+1:tel_end)>1
            MN_bed_chan(tel_start+1:tel_end-1,:)=[];
        end
        tel_end = tel_start;
    end
end

if ~isempty(MN_wl_chan)
    % sort first row:
    MN_wl_chan = sortrows(MN_wl_chan,1);
    tel = 1;
    while tel < size(MN_wl_chan,1)
        MN_wl_chan(find(MN_wl_chan(:,1) == MN_wl_chan(tel,1)),:) = sortrows(MN_wl_chan(find(MN_wl_chan(:,1) == MN_wl_chan(tel,1)),:),2);
        tel = max(find(MN_wl_chan(:,1) == MN_wl_chan(tel,1)))+1;
    end
    tel_end   = size(MN_wl_chan,1);
    tel_start = size(MN_wl_chan,1)-1;
    while tel_start > 0
        while tel_start > 0 && (MN_wl_chan(tel_end,1) == MN_wl_chan(tel_start,1)) && (MN_wl_chan(tel_end,2) == MN_wl_chan(tel_start,2))
            tel_start = tel_start - 1;
        end
        if length(tel_start+1:tel_end)>1
            MN_wl_chan(tel_start+1:tel_end-1,:)=[];
        end
        tel_end = tel_start;
    end
end

if ~isempty(MN_source_sink)
    % sort first row:
    MN_source_sink = sortrows(MN_source_sink,1);
    tel = 1;
    while tel < size(MN_source_sink,1)
        MN_source_sink(find(MN_source_sink(:,1) == MN_source_sink(tel,1)),:) = sortrows(MN_source_sink(find(MN_source_sink(:,1) == MN_source_sink(tel,1)),:),2);
        tel = max(find(MN_source_sink(:,1) == MN_source_sink(tel,1)))+1;
    end
    tel_end   = size(MN_source_sink,1);
    tel_start = size(MN_source_sink,1)-1;
    while tel_start > 0
        while tel_start > 0 && (MN_source_sink(tel_end,1) == MN_source_sink(tel_start,1)) && (MN_source_sink(tel_end,2) == MN_source_sink(tel_start,2))
            tel_start = tel_start - 1;
        end
        if length(tel_start+1:tel_end)>1
            MN_source_sink(tel_start+1:tel_end-1,:)=[];
        end
        tel_end = tel_start;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Create figures%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(MN_vel_chan)
    fig = figure(1); set(fig,'color','w','inverthardcopy','off','name','Velocity change warning locations')
    pcolor(grd.cor.x,grd.cor.y,nan(size(grd.cor.x))); hold on;
    for ii=1:size(MN_vel_chan,1)
        plot(grd.cor.x(MN_vel_chan(ii,2),MN_vel_chan(ii,1)),grd.cor.y(MN_vel_chan(ii,2),MN_vel_chan(ii,1)),'r.','markersize',20);
    end
    axis equal; grid on; box on; set(gca,'layer','top','color',[191 239 255]/255);
    xlabel(['X-direction [' grd.CoordinateSystem ' Coordinates]']);
    ylabel(['Y-direction [' grd.CoordinateSystem ' Coordinates]']);
    title(['Locations where velocity changes > 5 m/s after 0.5 timesteps have occured'],'FontSize',8);
    text(0.99,0.9,{['T_{first} = ' num2str(T_vel_chan(1)) ' timesteps'];['T_{first} = ' num2str(T_vel_chan(end)) ' timesteps']},...
        'Units','Normalized','HorizontalAlignment','right',...
        'EdgeColor','k','Backgroundcolor','w')
end

if ~isempty(MN_courant)
    fig = figure(2); set(fig,'color','w','inverthardcopy','off','name','Courant criteria warning locations')
    pcolor(grd.cor.x,grd.cor.y,nan(size(grd.cor.x))); hold on;
    for ii=1:size(MN_courant,1)
        plot(grd.cor.x(MN_courant(ii,2),MN_courant(ii,1)),grd.cor.y(MN_courant(ii,2),MN_courant(ii,1)),'r.','markersize',20);
    end
    axis equal; grid on; box on; set(gca,'layer','top','color',[191 239 255]/255);
    xlabel(['X-direction [' grd.CoordinateSystem ' Coordinates]']);
    ylabel(['Y-direction [' grd.CoordinateSystem ' Coordinates]']);
    title(['Locations where Courant criteria > 1 have occured'],'FontSize',8);
end

if ~isempty(MN_bed_chan)
    fig = figure(3); set(fig,'color','w','inverthardcopy','off','name','Bed change warning locations')
    pcolor(grd.cor.x,grd.cor.y,nan(size(grd.cor.x))); hold on;
    for ii=1:size(MN_bed_chan,1)
        plot(grd.cor.x(MN_bed_chan(ii,2),MN_bed_chan(ii,1)),grd.cor.y(MN_bed_chan(ii,2),MN_bed_chan(ii,1)),'r.','markersize',20);
    end
    axis equal; grid on; box on; set(gca,'layer','top','color',[191 239 255]/255);
    xlabel(['X-direction [' grd.CoordinateSystem ' Coordinates]']);
    ylabel(['Y-direction [' grd.CoordinateSystem ' Coordinates]']);
    title(['Locations where bed change exceeds 5.0 % of waterdepth have occured'],'FontSize',8);
end

if ~isempty(MN_wl_chan)
    fig = figure(4); set(fig,'color','w','inverthardcopy','off','name','Water level change error locations')
    pcolor(grd.cor.x,grd.cor.y,nan(size(grd.cor.x))); hold on;
    for ii=1:size(MN_wl_chan,1)
        plot(grd.cor.x(MN_wl_chan(ii,2),MN_wl_chan(ii,1)),grd.cor.y(MN_wl_chan(ii,2),MN_wl_chan(ii,1)),'r.','markersize',20);
    end
    axis equal; grid on; box on; set(gca,'layer','top','color',[191 239 255]/255);
    xlabel(['X-direction [' grd.CoordinateSystem ' Coordinates]']);
    ylabel(['Y-direction [' grd.CoordinateSystem ' Coordinates]']);
    title(['Locations where Water Level change too high > 25.00 m (per 0.5 DT) have occured'],'FontSize',8);
end

if ~isempty(MN_source_sink)
    fig = figure(5); set(fig,'color','w','inverthardcopy','off','name','Source and sink term warning locations')
    pcolor(grd.cor.x,grd.cor.y,nan(size(grd.cor.x))); hold on;
    for ii=1:size(MN_source_sink,1)
        plot(grd.cor.x(MN_source_sink(ii,2),MN_source_sink(ii,1)),grd.cor.y(MN_source_sink(ii,2),MN_source_sink(ii,1)),'r.','markersize',20);
    end
    axis equal; grid on; box on; set(gca,'layer','top','color',[191 239 255]/255);
    xlabel(['X-direction [' grd.CoordinateSystem ' Coordinates]']);
    ylabel(['Y-direction [' grd.CoordinateSystem ' Coordinates]']);
    title(['Locations where source and sink term sediment ** reduced with factor warnings ** have occured'],'FontSize',8);
end

end

















