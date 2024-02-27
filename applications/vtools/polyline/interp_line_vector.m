%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17878 $
%$Date: 2022-03-31 19:06:48 +0800 (Thu, 31 Mar 2022) $
%$Author: chavarri $
%$Id: interp_line_vector.m 17878 2022-03-31 11:06:48Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/interp_line_vector.m $
%

function [y,idx_1,idx_2]=interp_line_vector(xv_all,yv_all,x,x_thres,varargin)

np=numel(x);
y=NaN(np,1);
idx_1=NaN(np,1);
idx_2=NaN(np,1);
for kp=1:np
    [y(kp),idx_1(kp),idx_2(kp)]=interp_line_closest(xv_all,yv_all,x(kp),x_thres,varargin{:});
end %kp

end %function