function mdu = d3d2dflowfm_initial_xyz(varargin)

% d3d2dflowfm_initial_xyz : Writes dinitial conditions for waterlevel and salinity to D-Flow FM input files
%
%         input arguments 1) Delft3D-Flow grid file                          ("*.grd")
%                         2) Delft3D-Flow initial condition file             ("*.ini")
%                         3) Dflowfm initial condition file for water levels ("*.xyz")
%              (optional) 4) Dflowfm initial condition for salinity          ("*.xyz")
%              (optional) 5) Dflowfm initial condition for temperature       ("*.xyz")
%
%         WARNING: It is assumed that the Delft3D-Flow simulation is depth averaged and the last
%                  Field in the initial condition file represents salinity

OPT.filic_sal     = '';
OPT.filic_tem     = '';
OPT.kmax          =  1;
OPT.type          = 'initial';
OPT               = setproperty(OPT,varargin{4:end});

filgrd    = varargin{1};
filic     = varargin{2};
filic_wl  = varargin{3};

%% Get grid related information
grid  = delft3d_io_grd('read',filgrd);
mmax  = grid.mmax;
nmax  = grid.nmax;
xcoor = grid.cend.x';
ycoor = grid.cend.y';

%% Read initial condition file
if strcmpi(OPT.type,'initial');
    ic    = wldep ('read',filic,[mmax nmax],'multiple');
elseif strcmpi(OPT.type,'rst');
    ic    = trirst('read',filic,[mmax nmax],'all'     );
end

%% Get initial conditions for water level
tmp(:,1) = reshape(xcoor'     ,mmax*nmax,1);
tmp(:,2) = reshape(ycoor'     ,mmax*nmax,1);
tmp(:,3) = reshape(ic(1).Data',mmax*nmax,1);

%% fill the LINE structure with initial conditions for water levels
nonan     = ~isnan  (tmp(:,1));
tmp2      = d3d2dflowfm_addsquare(tmp(nonan,:));
LINE.DATA = num2cell(tmp2);

%% Write inial water level data to unstruc xyz file
dflowfm_io_xydata('write',filic_wl,LINE);

%% Salinity
if ~isempty(OPT.filic_sal)
    i_start = 2*OPT.kmax + 2;
    i_stop  = 3*OPT.kmax + 1;
    values(1:mmax,1:nmax) = 0.;
    for i_lay = i_start:i_stop
        values = values + ic(i_lay).Data;
    end
    values = values/OPT.kmax;

    tmp(:,3) = reshape(values',mmax*nmax,1);

    %% Fill line structure with salinity values
    tmp2      = d3d2dflowfm_addsquare(tmp(nonan,:));
    LINE.DATA = num2cell(tmp2);

    %% Write inial salinity data to unstruc xyz file
    dflowfm_io_xydata('write',OPT.filic_sal,LINE);
end

%% Temperature
if ~isempty(OPT.filic_tem)
    if ~isempty(OPT.filic_sal)
       i_start = 3*OPT.kmax + 2;
    else
       i_start = 2*OPT.kmax + 2;
    end
    i_stop = i_start + OPT.kmax - 1;

    values(1:mmax,1:nmax) = 0.;
    for i_lay = i_start:i_stop
        values = values + ic(i_lay).Data;
    end
    values = values/OPT.kmax;

    tmp(:,3) = reshape(values',mmax*nmax,1);

    %% Fill line structure with salinity values
    tmp2      = d3d2dflowfm_addsquare(tmp(nonan,:));
    LINE.DATA = num2cell(tmp2);

    %% Write inial salinity data to unstruc xyz file
    dflowfm_io_xydata('write',OPT.filic_tem,LINE);
end
