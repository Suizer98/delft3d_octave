%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_convert_thd.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/convert_d3d_fm/D3D_convert_thd.m $
%

% paths_grd_in=paths.paths_grd_in;
% paths_thd_in=paths.paths_thd_in;
% paths_thd_out=paths.paths_thd_out;

function LINE=D3D_convert_thd(paths_grd_in,paths_thd_in,paths_thd_out)

nd=numel(paths_thd_in);

aux_t=[];

thdfil   = paths_thd_out;

for kd=1:nd
    
filgrd   = paths_grd_in{kd,1};
fildry   = '';
filthd   = paths_thd_in{kd,1};

% Initialise
m        = [];
n        = [];
dams     = [];
LINE     = [];

% Open the Delft3D grid file
grid     = delft3d_io_grd('read',filgrd);
xcoor    = grid.cor.x';
ycoor    = grid.cor.y';

% if ~isempty(varargin{2}) && ~isempty(varargin{3})    
%     % Open the Delft3D dry point file
%     MNdry    = delft3d_io_dry('read',fildry);
%     m        = MNdry.m;
%     n        = MNdry.n;
%     % Fill the line struct for thin dams file
%     MNthd    = delft3d_io_thd('read',filthd);
%     dams     = MNthd.DATA;
% elseif isempty(varargin{2})
    % Fill the line struct for thin dams file
    MNthd    = delft3d_io_thd('read',filthd);
    dams     = MNthd.DATA;
% elseif isempty(varargin{3})
%     % Open the Delft3D dry point file
%     MNdry    = delft3d_io_dry('read',fildry);
%     m        = MNdry.m;
%     n        = MNdry.n;
% end

    iline    = 0;
    % Fill the LINE struct for dry points
%     for idry = 1 : length(m);
%         if ~isnan(xcoor(m(idry)  ,n(idry)  )) && ~isnan(xcoor(m(idry)-1,n(idry)  )) && ...
%                 ~isnan(xcoor(m(idry)  ,n(idry)-1)) && ~isnan(xcoor(m(idry)-1,n(idry)-1))
%             
%             iline = iline + 1;
%             LINE(iline).Blckname  = 'Line';
%             LINE(iline).DATA{1,1} = xcoor(m(idry) - 1,n(idry) - 1);
%             LINE(iline).DATA{1,2} = ycoor(m(idry) - 1,n(idry) - 1);
%             LINE(iline).DATA{2,1} = xcoor(m(idry) - 1,n(idry)    );
%             LINE(iline).DATA{2,2} = ycoor(m(idry) - 1,n(idry)    );
%             
%             iline = iline + 1;
%             LINE(iline).Blckname  = 'Line';
%             LINE(iline).DATA{1,1} = xcoor(m(idry) - 1,n(idry)    );
%             LINE(iline).DATA{1,2} = ycoor(m(idry) - 1,n(idry)    );
%             LINE(iline).DATA{2,1} = xcoor(m(idry)    ,n(idry)    );
%             LINE(iline).DATA{2,2} = ycoor(m(idry)    ,n(idry)    );
%             
%             iline = iline + 1;
%             LINE(iline).Blckname  = 'Line';
%             LINE(iline).DATA{1,1} = xcoor(m(idry)    ,n(idry)    );
%             LINE(iline).DATA{1,2} = ycoor(m(idry)    ,n(idry)    );
%             LINE(iline).DATA{2,1} = xcoor(m(idry)    ,n(idry) - 1);
%             LINE(iline).DATA{2,2} = ycoor(m(idry)    ,n(idry) - 1);
%             
%             iline = iline + 1;
%             LINE(iline).Blckname  = 'Line';
%             LINE(iline).DATA{1,1} = xcoor(m(idry)    ,n(idry) - 1);
%             LINE(iline).DATA{1,2} = ycoor(m(idry)    ,n(idry) - 1);
%             LINE(iline).DATA{2,1} = xcoor(m(idry) - 1,n(idry) - 1);
%             LINE(iline).DATA{2,2} = ycoor(m(idry) - 1,n(idry) - 1);
%         end
%     end
%     clear m n
    
    % Fill the LINE struct for thin dams
    aux=[];
    for ipnt = 1 : length(dams)
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
%                     LINE(iline).Blckname  = 'Line';
%                     LINE(iline).DATA{1,1} = xcoor(m(1)       ,idam - 1);
%                     LINE(iline).DATA{1,2} = ycoor(m(1)       ,idam - 1);
%                     LINE(iline).DATA{2,1} = xcoor(m(1)       ,idam    );
%                     LINE(iline).DATA{2,2} = ycoor(m(1)       ,idam    );
                    aux(iline,1)= xcoor(m(1)       ,idam - 1);
                    aux(iline,2)= ycoor(m(1)       ,idam - 1);
                    aux(iline,3)= xcoor(m(1)       ,idam    );
                    aux(iline,4)= ycoor(m(1)       ,idam    );
                end
            end
        else
            m = sort(m);
            for idam = m(1):m(2)
                if ~isnan(xcoor(idam - 1,n(1))) && ~isnan(xcoor(idam,n(1)))
                    iline = iline + 1;
%                     LINE(iline).Blckname  = 'Line';
%                     LINE(iline).DATA{1,1} = xcoor(idam - 1   ,n(1)    );
%                     LINE(iline).DATA{1,2} = ycoor(idam - 1   ,n(1)    );
%                     LINE(iline).DATA{2,1} = xcoor(idam       ,n(1)    );
%                     LINE(iline).DATA{2,2} = ycoor(idam       ,n(1)    );
                    aux(iline,1)= xcoor(idam - 1   ,n(1)    );
                    aux(iline,2)= ycoor(idam - 1   ,n(1)    );
                    aux(iline,3)= xcoor(idam       ,n(1)    );
                    aux(iline,4)= ycoor(idam       ,n(1)    );
                end
            end
        end
    end

    %combine
    aux_t=[aux_t;aux];
    
end %kd

%create structure
nth=size(aux_t,1);
for kth=1:nth
    LINE(kth).Blckname  = 'Line';
    LINE(kth).DATA{1,1} = aux_t(kth,1);
    LINE(kth).DATA{1,2} = aux_t(kth,2);
    LINE(kth).DATA{2,1} = aux_t(kth,3);
    LINE(kth).DATA{2,2} = aux_t(kth,4);
end

% Write the thin dam information (note: dry points do not exist anymore, they have become thin dams)
if ~isnan(thdfil)
dflowfm_io_xydata('write',thdfil,LINE);
end



end %function