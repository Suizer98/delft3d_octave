function varargout = d3d2dflowfm_dry_xyz(varargin);

% d3d2dflowfm_thd_xyz generate and write write D-Flow FM dry points file
%                           from d3d files
%
%
%                          Iput arguments 1) Delft3D-Flow grid file (*.grd)
%                                         2) Name of the D-Flow FM dry file (*.dry)
%                                         3) Name of the D-Flow FM dry file (*_dry.xyz)

filgrd   = varargin{1};
fildry   = varargin{2};
dryfil   = varargin{3};

% Initialise
m        = [];
n        = [];
LINE     = [];

% Open the Delft3D grid file
grid     = delft3d_io_grd('read',filgrd);
xcoor    = grid.cend.x';
ycoor    = grid.cend.y';
mmax     = size(xcoor,1);
nmax     = size(xcoor,2);

if ~isempty (fildry)
    MNdry    = delft3d_io_dry('read',fildry);
    m        = MNdry.m;
    n        = MNdry.n;

    % Fill the LINE struct for dry points
    i_pnt    = 0;
    for i_dry = 1 : length(m);
        if m(i_dry) <= mmax && n(i_dry) <= nmax
            if ~isnan(xcoor(m(i_dry)  ,n(i_dry)  ))
                i_pnt              = i_pnt + 1;
                LINE.DATA{i_pnt,1} = xcoor(m(i_dry),n(i_dry));
                LINE.DATA{i_pnt,2} = ycoor(m(i_dry),n(i_dry));
                LINE.DATA{i_pnt,3} = 0.;
            end
        end
    end

    % Write the thin dam information
    dflowfm_io_xydata('write',dryfil,LINE);
end
