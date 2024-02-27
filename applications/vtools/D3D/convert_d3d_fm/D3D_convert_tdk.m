%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_convert_tdk.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/convert_d3d_fm/D3D_convert_tdk.m $
%

% paths=generate_paths_delft3d_4rijn2017v1;
% paths_grd_in=paths.paths_grd_in;
% paths_wr_in=paths.paths_wr_in;
% paths_tdk_out=paths.paths_tdk_out;

%%

function LINE=D3D_convert_tdk(paths_grd_in,paths_wr_in,paths_tdk_out)

nd=numel(paths_wr_in);

aux_t=[];

weifil = paths_tdk_out;

for kd=1:nd

filgrd = paths_grd_in{kd,1};
filwei = paths_wr_in{kd,1};

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
aux=[];

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
%                     LINE(iline).Blckname  = ['L' num2str(iline,'%5.5i')];
%                     LINE(iline).DATA{1,1} = xcoor(m(1)       ,idam - 1);
%                     LINE(iline).DATA{1,2} = ycoor(m(1)       ,idam - 1);
%                     LINE(iline).DATA{1,3} = -height;
%                     LINE(iline).DATA{2,1} = xcoor(m(1)       ,idam    );
%                     LINE(iline).DATA{2,2} = ycoor(m(1)       ,idam    );
%                     LINE(iline).DATA{2,3} = -height;

                    aux(iline,1) = xcoor(m(1)       ,idam - 1);
                    aux(iline,2) = ycoor(m(1)       ,idam - 1);
                    aux(iline,3) = -height;
                    aux(iline,4) = xcoor(m(1)       ,idam    );
                    aux(iline,5) = ycoor(m(1)       ,idam    );
                    aux(iline,6) = -height;
                end
            end
        else
            m = sort(m);
            for idam = m(1):m(2)
                if ~isnan(xcoor(idam - 1,n(1))) && ~isnan(xcoor(idam,n(1)))
                    iline = iline + 1;
%                     LINE(iline).Blckname  = ['L' num2str(iline,'%5.5i')];
%                     LINE(iline).DATA{1,1} = xcoor(idam - 1   ,n(1)    );
%                     LINE(iline).DATA{1,2} = ycoor(idam - 1   ,n(1)    );
%                     LINE(iline).DATA{1,3} = -height;
%                     LINE(iline).DATA{2,1} = xcoor(idam       ,n(1)    );
%                     LINE(iline).DATA{2,2} = ycoor(idam       ,n(1)    );
%                     LINE(iline).DATA{2,3} = -height;

                    aux(iline,1) = xcoor(idam - 1   ,n(1)    );
                    aux(iline,2) = ycoor(idam - 1   ,n(1)    );
                    aux(iline,3) = -height;
                    aux(iline,4) = xcoor(idam       ,n(1)    );
                    aux(iline,5) = ycoor(idam       ,n(1)    );
                    aux(iline,6) = -height;
                end
            end
        end
    end
end

%combine data from each domina
aux_t=[aux_t;aux];

end %kd

%add dummy (subgrid approach)
aux_t(:,7:10)=-999;


%create structure
nth=size(aux_t,1);
for kth=1:nth
        %point 1
    LINE(kth).Blckname  = ['L' num2str(kth,'%5.5i')];
    LINE(kth).DATA{1,1} = aux_t(kth,1);
    LINE(kth).DATA{1,2} = aux_t(kth,2);
    LINE(kth).DATA{1,3} = aux_t(kth,3);
    LINE(kth).DATA{1,4} = aux_t(kth,7); %dummy
    LINE(kth).DATA{1,5} = aux_t(kth,8); %dummy
        %point 2
    LINE(kth).DATA{2,1} = aux_t(kth,4); 
    LINE(kth).DATA{2,2} = aux_t(kth,5);
    LINE(kth).DATA{2,3} = aux_t(kth,6);
    LINE(kth).DATA{2,4} = aux_t(kth,9); %dummy
    LINE(kth).DATA{2,5} = aux_t(kth,10); %dummy 
end

% write file
if ~isnan(weifil)
D3D_io_xydata_adapted('write',weifil,LINE);
end