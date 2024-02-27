%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17867 $
%$Date: 2022-03-29 14:02:08 +0800 (Tue, 29 Mar 2022) $
%$Author: chavarri $
%$Id: interp_line_closest.m 17867 2022-03-29 06:02:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/interp_line_closest.m $
%

function [y,idx_1,idx_2]=interp_line_closest(xv_all,yv_all,x,x_thres,varargin)

%% PARSE

switch numel(varargin)
    case 0
        is_dtime=isdatetime(xv_all); %it is somehow expensive, we can pass it from outside for performance
    case 1
        is_dtime=varargin{1};
end

%% CALC

idx_1=NaN;
idx_2=find(xv_all>x,1,'first');
% xv_all(idx_2)-x
if isempty(idx_2)
    idx_2=find(xv_all==x,1,'first');
    if isempty(idx_2)
        y=NaN;
        idx_2=NaN;
    else
        idx_1=idx_2;
        y=yv_all(idx_2);
    end
else
%     idx_1=find(xv_all<x,1,'last'); 
    idx_1=idx_2-1;
%     xv_all(idx_1)
    if idx_1==0
        y=NaN;
    else
        if isnan(x_thres) %looks cumbersome but it is the fastest way to get it 
            if is_dtime
                y=interp_line_dtime(xv_all([idx_1,idx_2]),yv_all([idx_1,idx_2]),x);
            else
                y=interp_line_double(xv_all([idx_1,idx_2]),yv_all([idx_1,idx_2]),x);
            end
        else
            if x+x_thres>xv_all(idx_2) && x-x_thres<xv_all(idx_1) %good (it appears to be quite expensive)
                if is_dtime
                    y=interp_line_dtime(xv_all([idx_1,idx_2]),yv_all([idx_1,idx_2]),x);
                else
                    y=interp_line_double(xv_all([idx_1,idx_2]),yv_all([idx_1,idx_2]),x);
                end
            else
                y=NaN;
            end
        end
    end
end

end