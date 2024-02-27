function varargout=d3d2dflowfm_weirs_xyz(varargin)

% d3d2dflowfm_weirs_xyz generates and writes D-Flow FM weirs polyline file
%                           from d3d files
%
%
%                          Iput arguments 1) Delft3D-Flow grid file (*.grd)
%                                         2) Delft3D-Flow weirs file (*.2dw)
%                                         3) Name of the Dflowfm weirs file (*_tdk.pli)
%
% See also: dflowfm_io_mdu dflowfm_io_xydata
%

filgrd = varargin{1};
filwei = varargin{2};
weifil = varargin{3};

% Initialize
weirs  = [];
LINE   = [];

% Open and read the D3D Files
grid   = delft3d_io_grd('read',filgrd);
xcoor  = grid.cor.x';
ycoor  = grid.cor.y';

% Read weirs
weirs  = delft3d_io_2dw('read',filwei);

%
% Fill the LINE struct for dry points
%

iline = 0;
if ~isempty(weirs)
    for i_2dw = 1 : length(weirs.DATA)
        type   = weirs.DATA(i_2dw).direction;
        height = weirs.DATA(i_2dw).height;
        m(1)   = weirs.DATA(i_2dw).mn(1);
        n(1)   = weirs.DATA(i_2dw).mn(2);
        m(2)   = weirs.DATA(i_2dw).mn(3);
        n(2)   = weirs.DATA(i_2dw).mn(4);
        if strcmpi(type,'u')
            n = sort (n);
            for idam = n(1):n(2)
                if ~isnan(xcoor(m(1),idam - 1)) && ~isnan(xcoor(m(1),idam))
                    iline = iline + 1;
                    LINE(iline).Blckname  = ['L' num2str(iline,'%5.5i')];
                    LINE(iline).DATA{1,1} = xcoor(m(1)       ,idam - 1);
                    LINE(iline).DATA{1,2} = ycoor(m(1)       ,idam - 1);
                    LINE(iline).DATA{1,3} = -height;
                    LINE(iline).DATA{2,1} = xcoor(m(1)       ,idam    );
                    LINE(iline).DATA{2,2} = ycoor(m(1)       ,idam    );
                    LINE(iline).DATA{2,3} = -height;
                end
            end
        else
            m = sort(m);
            for idam = m(1):m(2)
                if ~isnan(xcoor(idam - 1,n(1))) && ~isnan(xcoor(idam,n(1)))
                    iline = iline + 1;
                    LINE(iline).Blckname  = ['L' num2str(iline,'%5.5i')];
                    LINE(iline).DATA{1,1} = xcoor(idam - 1   ,n(1)    );
                    LINE(iline).DATA{1,2} = ycoor(idam - 1   ,n(1)    );
                    LINE(iline).DATA{1,3} = -height;
                    LINE(iline).DATA{2,1} = xcoor(idam       ,n(1)    );
                    LINE(iline).DATA{2,2} = ycoor(idam       ,n(1)    );
                    LINE(iline).DATA{2,3} = -height;
                end
            end
        end
    end
end

% write viscosity to file
dflowfm_io_xydata('write',weifil,LINE);