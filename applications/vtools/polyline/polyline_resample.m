%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18269 $
%$Date: 2022-08-01 12:31:19 +0800 (Mon, 01 Aug 2022) $
%$Author: chavarri $
%$Id: polyline_resample.m 18269 2022-08-01 04:31:19Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/polyline_resample.m $
%
%This does A and B
%
%INPUT:
%
%OUTPUT:
%

function xy_out=polyline_resample(xy_in,dist_o,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'idx_0',1);

parse(parin,varargin{:});

idx_0=parin.Results.idx_0;

%% CALC


xy_in_r=order_polyline(xy_in,idx_0);
dist_p=compute_distance_along_line(xy_in_r);
if numel(dist_o)==1 %dx is given
    dist_o=0:dist_o:dist_p(end);
end
xy_out=xy_in_r(1,:);
np=numel(dist_o);
for kp=1:np
    x_add=interp_line_closest(dist_p,xy_in_r(:,1),dist_o(kp),NaN);
    y_add=interp_line_closest(dist_p,xy_in_r(:,2),dist_o(kp),NaN);
    xy_out=cat(1,xy_out,[x_add,y_add]);
end


end %function