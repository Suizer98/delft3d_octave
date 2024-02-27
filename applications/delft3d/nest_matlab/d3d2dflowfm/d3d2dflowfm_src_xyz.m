function varargout = d3d2dflowfm_src_xyz(varargin)

% d3d2dflowfm_thd_xyz generate and write write D-Flow FM thin dams and dry points file
%                           from d3d files
%
%
%                          Iput arguments 1) Delft3D-Flow grid file (*.grd)
%                                         2) Delft3D-Flow sources file (*.src)
%                                         3) Delft3D-Flow discharge files (*.dis)
%                                         4) Delft3D-Flow depth file (*.dep)
%                                         5) Path of the location where to store the resuling pli and tim files
%
% First beta release, still to do:
% - Momentum and coupled intakes/outfalls
% - Block interpolation (in stead of linear)

%% Define files
filgrd     = varargin{1};
filsrc_d3d = varargin{2};
fildis     = varargin{3};
fildep     = varargin{4};
pathdis    = varargin{5};

%% Additional parameters (NOT USED YET!)
OPT.thick  = 100.0;
OPT.zmodel = 'n';
OPT.ztop   = NaN;
OPT.zbot   = NaN;
OPT        = setproperty(OPT,varargin{6:end});
OPT.thick  = OPT.thick/100.;
kmax       = length(OPT.thick);

%% get necessary grid related information
grid = delft3d_io_grd('read',filgrd);
xcoor = grid.cend.x';
ycoor = grid.cend.y';
mmax  = size(xcoor,1);
nmax  = size(xcoor,2);

%% get discharge point related information
src    = delft3d_io_src('read',filsrc_d3d);
m_src  = cell2mat({src.DATA.m});
n_src  = cell2mat({src.DATA.n});
k_src  = cell2mat({src.DATA.k});
type   = {src.DATA.type};
intp   = {src.DATA.interpolation};
names  = {src.DATA.name};

%% read discharge information
dis      = ddb_bct_io('read',fildis);
location = {dis.Table.Location};
for i_loc = 1: length(location) location{i_loc} = location{i_loc}(1:min(length(location{i_loc}),20)); end

%% read the depth information (for determining the height of a discharge point
dep   = wldep('read',fildep,[mmax nmax]);

for i_src = 1: length(m_src)
    i_table = strmatch(strtrim(names{i_src}),location,'exact');


    %% Depthaveraged discharge?
    dav = true; if kmax > 1 && k_src(i_src) > 0 dav = false; end

    %% File the line struct with x an y coordinates (TODO: z-coordinate!)
    LINE.Blckname  = 'L1';
    LINE.DATA{1,1} = -999.999;
    LINE.DATA{1,2} = -999.999;
    LINE.DATA{2,1} = xcoor(m_src(i_src),n_src(i_src));
    LINE.DATA{2,2} = ycoor(m_src(i_src),n_src(i_src));
    if ~dav
        %% Determine height
        if strcmpi(OPT.zmodel,'y')
            height(1) = OPT.zbot + 0.5*OPT.thick(1)*(OPT.ztop - OPT.zbot);
            for i_lay = 2: kmax
                height(i_lay) = height(i_lay -1) + 0.5*(OPT.thick(i_lay) + OPT.thick(i_lay - 1))*(OPT.ztop - OPT.zbot);
            end
        else
            % Sigma model: assume mean water level of 0.0
            dep_src = -1.*dep(m_src(i_src),n_src(i_src));
            height(1) = 0.5*OPT.thick(1)*dep_src;
            for i_lay = 2: kmax
                height(i_lay) = height(i_lay -1) + 0.5*(OPT.thick(i_lay) + OPT.thick(i_lay - 1))*dep_src;
            end
        end
        LINE.DATA{1,3} = -999.999;
        LINE.DATA{2,3} = height(k_src(i_src));
    end

    %% Write to pli(z) file (name of the pli(z) file is the name  of the discharge point)
    names{i_src}     = simona2mdu_replacechar(names{i_src},'(','');
    names{i_src}     = simona2mdu_replacechar(names{i_src},')','');
    names{i_src}     = simona2mdu_replacechar(names{i_src},'%','');
    names{i_src}     = simona2mdu_replacechar(names{i_src},'/','');
    names{i_src}     = simona2mdu_replacechar(names{i_src},'+','');
    filsrc{i_src}    = [pathdis filesep simona2mdu_replacechar(strtrim(names{i_src}),' ','_') '.pli'];
    if ~dav filsrc{i_src} = [filsrc{i_src} 'z']; end
    dflowfm_io_xydata('write',filsrc{i_src},LINE);

    %% Generate the series (for now always including salinity and temperature, not sure if that is allowed)
%    i_table = strmatch(strtrim(names{i_src}),location,'exact');
    SERIES.Values(:,1)   = dis.Table(i_table).Data(:,1); % times
    SERIES.Values(:,2)   = dis.Table(i_table).Data(:,2); % Flux/discharge rate

    nr_sal               = 0;
    nr_temp              = 0;
    params               = {dis.Table(i_table).Parameter.Name};
    %% Salinity (if present)
    nr_col               = strmatch('salinity',lower(params));
    if ~isempty(nr_col)
         nr_sal                      = nr_col;
         SERIES.Comments{nr_col + 1} = ['* COLUMN' num2str(nr_col,'%1i') '=Salinity (psu)'];
         SERIES.Values(:,nr_col)     = dis.Table(i_table).Data(:,nr_col);
    end

    %% Temperature (if present)
    nr_col               = strmatch('temperature',lower(params));
    if ~isempty(nr_col)
        nr_temp                     = nr_col;
        SERIES.Comments{nr_col + 1} = ['* COLUMN' num2str(nr_col,'%1i') '=Temperature (oC)'];
        SERIES.Values(:,nr_col)     = dis.Table(i_table).Data(:,nr_col);
    end
    SERIES.Comments{1} = ['* COLUMNN=' num2str(max(2,max(nr_sal,nr_temp)),'%1i')];
    SERIES.Comments{2} = '* COLUMN1=Time (min) since the reference date';
    SERIES.Comments{3} = '* COLUMN2=Discharge (m3/s), positive in';


    %% write to file
    SERIES.Values        = num2cell(SERIES.Values);
    if dav
        dflowfm_io_series( 'write',[filsrc{i_src}(1:end-3) 'tim'],SERIES);
    else
        dflowfm_io_series( 'write',[filsrc{i_src}(1:end-4) 'tim'],SERIES);
    end
    clear SERIES
end

varargout = {filsrc};
