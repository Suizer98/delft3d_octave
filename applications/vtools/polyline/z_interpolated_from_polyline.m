%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18458 $
%$Date: 2022-10-18 18:26:40 +0800 (Tue, 18 Oct 2022) $
%$Author: chavarri $
%$Id: z_interpolated_from_polyline.m 18458 2022-10-18 10:26:40Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/z_interpolated_from_polyline.m $
%
%Given a polyline <[x_s,y_s]> with values <[z_s]>, it finds
%the value <z> associated to the point <[x,y]>.
%
function [z,idx_c,min_dist]=z_interpolated_from_polyline(x,y,x_s,y_s,z_s,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'method','linear');

parse(parin,varargin{:});

method=parin.Results.method;

%%

if numel(x_s) ~=numel(y_s)
    error('number of points in x and y must be the same')
end
if numel(x_s)~=size(z_s,1)
    error('number of points in z must be the same as in x and y')
end

%%
    
[min_dist,x_d_min,y_d_min,~,idx_c,~,~,~,~]=p_poly_dist(x,y,x_s,y_s); %the order of output seems wrong, but it is correct. 
idx_c=max([ones(size(idx_c)),idx_c],[],2);
dist_p2o=sqrt((x_d_min  -x_s(idx_c)).^2+(y_d_min  -y_s(idx_c)).^2);
dist_p2p=sqrt((x_s(idx_c+1)-x_s(idx_c)).^2+(y_s(idx_c+1)-y_s(idx_c)).^2);
frac=dist_p2o./dist_p2p;
switch method
    case 'linear'
        z=z_s(idx_c,:)+frac.*(z_s(idx_c+1,:)-z_s(idx_c,:));
    case 'closest'
        z=z_s(idx_c,:); %all are equal to the first point in the segment
        bol_m=frac>0.5; %the ones which are closest to the second point in the segment
        z_aux=z_s(idx_c+1,:); %are assigned the value of the second point in the segment
        z(bol_m,:)=z_aux(bol_m,:);
    otherwise
        error('No <method> called %s',method)
end

