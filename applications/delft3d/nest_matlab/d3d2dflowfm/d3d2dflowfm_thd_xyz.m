function varargout = d3d2dflowfm_thd_xyz(varargin);

% d3d2dflowfm_thd_xyz generate and write write D-Flow FM thin dams and dry points file
%                           from d3d files
%
%
%                          Iput arguments 1) Delft3D-Flow grid file (*.grd)
%                                         2) Name of the D-Flow FM dry file (*.dry)
%                                         3) Name of the D-Flow FM dry file (*.thd)
%                                         4) Name of the D-Flow FM dry file (*_dry.xyz)
%                                         5) Name of the D-Flow FM thd file (*_thd.pli)

filgrd   = varargin{1};
fildry   = varargin{2};
filthd   = varargin{3};
thdfil   = varargin{4};

% Initialise
m        = [];
n        = [];
dams     = [];
LINE     = [];

% Open the Delft3D grid file
grid     = delft3d_io_grd('read',filgrd);
xcoor    = grid.cor.x';
ycoor    = grid.cor.y';

if ~isempty(varargin{2}) && ~isempty(varargin{3})    
    % Open the Delft3D dry point file
    MNdry    = delft3d_io_dry('read',fildry);
    m        = MNdry.m;
    n        = MNdry.n;
    % Fill the line struct for thin dams file
    MNthd    = delft3d_io_thd('read',filthd);
    dams     = MNthd.DATA;
elseif isempty(varargin{2})
    % Fill the line struct for thin dams file
    MNthd    = delft3d_io_thd('read',filthd);
    dams     = MNthd.DATA;
elseif isempty(varargin{3})
    % Open the Delft3D dry point file
    MNdry    = delft3d_io_dry('read',fildry);
    m        = MNdry.m;
    n        = MNdry.n;
end
    
    % Fill the LINE struct for dry points
    iline    = 0;
    for idry = 1 : length(m);
        if ~isnan(xcoor(m(idry)  ,n(idry)  )) && ~isnan(xcoor(m(idry)-1,n(idry)  )) && ...
                ~isnan(xcoor(m(idry)  ,n(idry)-1)) && ~isnan(xcoor(m(idry)-1,n(idry)-1))
            
            iline = iline + 1;
            LINE(iline).Blckname  = 'Line';
            LINE(iline).DATA{1,1} = xcoor(m(idry) - 1,n(idry) - 1);
            LINE(iline).DATA{1,2} = ycoor(m(idry) - 1,n(idry) - 1);
            LINE(iline).DATA{2,1} = xcoor(m(idry) - 1,n(idry)    );
            LINE(iline).DATA{2,2} = ycoor(m(idry) - 1,n(idry)    );
            
            iline = iline + 1;
            LINE(iline).Blckname  = 'Line';
            LINE(iline).DATA{1,1} = xcoor(m(idry) - 1,n(idry)    );
            LINE(iline).DATA{1,2} = ycoor(m(idry) - 1,n(idry)    );
            LINE(iline).DATA{2,1} = xcoor(m(idry)    ,n(idry)    );
            LINE(iline).DATA{2,2} = ycoor(m(idry)    ,n(idry)    );
            
            iline = iline + 1;
            LINE(iline).Blckname  = 'Line';
            LINE(iline).DATA{1,1} = xcoor(m(idry)    ,n(idry)    );
            LINE(iline).DATA{1,2} = ycoor(m(idry)    ,n(idry)    );
            LINE(iline).DATA{2,1} = xcoor(m(idry)    ,n(idry) - 1);
            LINE(iline).DATA{2,2} = ycoor(m(idry)    ,n(idry) - 1);
            
            iline = iline + 1;
            LINE(iline).Blckname  = 'Line';
            LINE(iline).DATA{1,1} = xcoor(m(idry)    ,n(idry) - 1);
            LINE(iline).DATA{1,2} = ycoor(m(idry)    ,n(idry) - 1);
            LINE(iline).DATA{2,1} = xcoor(m(idry) - 1,n(idry) - 1);
            LINE(iline).DATA{2,2} = ycoor(m(idry) - 1,n(idry) - 1);
        end
    end
    clear m n
    
    % Fill the LINE struct for dry points
    for ipnt = 1 : length(dams);
        m(1) = dams(ipnt).mn(1);
        n(1) = dams(ipnt).mn(2);
        m(2) = dams(ipnt).mn(3);
        n(2) = dams(ipnt).mn(4);
        type = dams(ipnt).direction;
        if strcmpi(type,'u')
            n = sort (n);
            for idam = n(1):n(2)
                if ~isnan(xcoor(m(1),idam - 1)) && ~isnan(xcoor(m(1),idam))
                    iline = iline + 1;
                    LINE(iline).Blckname  = 'Line';
                    LINE(iline).DATA{1,1} = xcoor(m(1)       ,idam - 1);
                    LINE(iline).DATA{1,2} = ycoor(m(1)       ,idam - 1);
                    LINE(iline).DATA{2,1} = xcoor(m(1)       ,idam    );
                    LINE(iline).DATA{2,2} = ycoor(m(1)       ,idam    );
                end
            end
        else
            m = sort(m);
            for idam = m(1):m(2)
                if ~isnan(xcoor(idam - 1,n(1))) && ~isnan(xcoor(idam,n(1)))
                    iline = iline + 1;
                    LINE(iline).Blckname  = 'Line';
                    LINE(iline).DATA{1,1} = xcoor(idam - 1   ,n(1)    );
                    LINE(iline).DATA{1,2} = ycoor(idam - 1   ,n(1)    );
                    LINE(iline).DATA{2,1} = xcoor(idam       ,n(1)    );
                    LINE(iline).DATA{2,2} = ycoor(idam       ,n(1)    );
                end
            end
        end
    end
    
    % Write the thin dam information (note: dry points do not exist anymore, they have become thin dams)
    dflowfm_io_xydata('write',thdfil,LINE);