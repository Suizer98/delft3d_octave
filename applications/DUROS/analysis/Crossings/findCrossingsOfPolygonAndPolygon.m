function [xcr, zcr] = findCrossingsOfPolygonAndPolygon(x1,z1,x2,z2)
% FINDCROSSINGSOFPOLYGONANDPOLYGON  determines the crossings of an arbitrary polygon with another arbitrary polygon!!
%
% Some typical things to know about this function are:
% 	- the first line can be an arbitrary polygon
% 	- the second line can be an arbitrary polygon
% 	- the function uses findCrossings.m to see if there is a crossing between a line and each segment of the polygon
%   - for each section of polygon 1 the crosings with polygon 2 are calculated
% 	- using matrix math helps to keep the process very speedy (line crossed with polygon of app. 90000 points takes 0.1 seconds)
% 	- by default the flag 'keeporiginalgrid' add crossings only is used
%
% Syntax:       [xcr, zcr] = findCrossingsOfLineAndPolygon(x1,z1,x2,z2)
%
% Input:
%               x1   = array of x-values profile 1
%               z1	 = array of corresponding z-values (same size as x1)
%               x2	 = array of x-values profile 2
%               z2	 = array of corresponding z-values (same size as x2)
%
% Output:
%               xcr  = array of x-values crossings found
%               zcr	 = array of corresponding z-values of crossings found (same size as xcr)
%
%   See also addXvaluesExactCrossings, findCrossings, POLYINTERSECT

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:      Version 1.0, June 2008 (Version 1.0, June 2008)
%     Mark van Koningsveld
%
%     m.vankoningsveld@tudelft.nl
%
%     Hydraulic Engineering Section
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% --------------------------------------------------------------------

% $Id: findCrossingsOfPolygonAndPolygon.m 501 2009-06-08 06:15:42Z boer_g $
% $Date: 2009-06-08 14:15:42 +0800 (Mon, 08 Jun 2009) $
% $Author: boer_g $
% $Revision: 501 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/analysis/Crossings/findCrossingsOfPolygonAndPolygon.m $
% $Keywords: $

getdefaults(...
    'x1',[427668 427801 427926 428208 428489 428637 428725 428740 428703 428548 428333 428008 427719 427697 427527 427549 427845 428045 428356 428503]',0,...
    'z1',[5.09376e+006 5.09371e+006 5.09368e+006 5.09365e+006 5.09363e+006 5.09365e+006 5.09371e+006 5.09376e+006 5.09392e+006 5.09395e+006 5.09398e+006 5.09396e+006 5.09404e+006 5.09408e+006 5.09431e+006 5.09444e+006 5.09451e+006 5.09452e+006 5.09442e+006 5.09437e+006]',0,...
    'x2',[427037 427318 427948 428801 429595 429906 429586 428898 428025 427531 427337 427424 427987 428607 429208 429440 429150 428617 428074 427715 427754 428151 428578 428810 428675 428239 427880 427909 428132 428316 428423 428432 428297]',0,...
    'z2',[5.09383e+006 5.09322e+006 5.09292e+006 5.09274e+006 5.09309e+006 5.09403e+006 5.09473e+006 5.09525e+006 5.09527e+006 5.09485e+006 5.0943e+006 5.09376e+006 5.09333e+006 5.09331e+006 5.09348e+006 5.09412e+006 5.09474e+006 5.09496e+006 5.09477e+006 5.09426e+006 5.09382e+006 5.09358e+006 5.09356e+006 5.09401e+006 5.09444e+006 5.09451e+006 5.09418e+006 5.09388e+006 5.09373e+006 5.09371e+006 5.09382e+006 5.09403e+006 5.09413e+006]',0);

[xcr_store, zcr_store] = deal([]);

%% if dbstate on generate a plot to see end result
if dbstate
    figure(1111);clf;hold on;
    ph(1)     = plot(x1,z1,'-or','markerfacecolor','r');
    ph(2)     = plot(x2,z2,'-ob','markerfacecolor','b');
end

%% get dimensions of input; for colums, dim = 1; for rows, dim = 2;
dim1 = find(size(x1)~=1);
dim2 = find(size(x2)~=1);
if dim1 == 2 % in case of rows, transpose
    x1 = x1';
    z1 = z1';
end;
if dim2 == 2 % in case of rows, transpose
    x2 = x2';
    z2 = z2';
end;

%% locate relevant sections where you might find crossings potentially (use matrix math for speed)
data1 = [x1(1:end-1) x1(2:end) z1(1:end-1) z1(2:end)];
data2 = [x2(1:end-1) x2(2:end) z2(1:end-1) z2(2:end)];

for i = 1:size(data1,1)
    %% create a mask identifying the relevant line segments
    mask = ~(...
        (data2(:,1)<=min(data1(i,1:2)) & data2(:,2)<=min(data1(i,1:2))) | ...  % both x values of segment are smaller than first x of line
        (data2(:,1)>=max(data1(i,1:2)) & data2(:,2)>=max(data1(i,1:2))) | ...  % both x values of segment are greater than second x of line
        (data2(:,3)<=min(data1(i,3:4)) & data2(:,4)<=min(data1(i,3:4))) | ...  % both y values of segment are smaller than first y of line
        (data2(:,3)>=max(data1(i,3:4)) & data2(:,4)>=max(data1(i,3:4)))) ...   % both y values of segment are greater than second y of line
        & ~( ...
        isnan(data2(:,1)) | ...
        isnan(data2(:,2)) | ...
        isnan(data2(:,3)) | ...
        isnan(data2(:,4)));                                                    % not one of the entries should be nan

    %% filter data for relevant sections where you might find crossings potentially
    data = data2(mask,:);

    if dbstate
        for k = 1:size(data,1)
            ph(3) = plot(data(k,1:2),data(k,3:4),'-ok','markerfacecolor','k');
        end
    end

    %% for each section of the polygon perform findCrossings
    for j = 1 : size(data,1)
        try
            if data1(i,1) == data1(i,2) % catch situations where a vertical segment from x1 and z1 is considered
                p = polyfit(data(j,1:2)',data(j,3:4)',1);
                xcr = data1(i, 1);
                zcr = polyval(p, xcr);
                if ~( min(data1(i,3:4)) <= zcr & max(data1(i,3:4)) >= zcr ) %#ok<*AND2>
                    [xcr, zcr] = deal([]);
                end
                
            elseif data(j,1) == data(j,2) % catch situations where a vertical segment from x2 and z2 is considered
                p = polyfit(data1(i,1:2),data1(i,3:4),1);
                xcr = data(j, 1);
                zcr = polyval(p, xcr);
                if ~( min(data(j,3:4)) <= zcr & max(data(j,3:4)) >= zcr )
                    [xcr, zcr] = deal([]);
                end

            else % otherwise perform findCrossings
                [xcr, zcr] = findCrossings(data1(i,1:2),data1(i,3:4),data(j,1:2)',data(j,3:4)','keeporiginalgrid');
            
            end
        catch %#ok<*CTCH>
            [xcr, zcr] = deal([]);
        end
        
        if ~isempty(xcr)
            xcr_store = [xcr_store xcr]; %#ok<*AGROW>
            zcr_store = [zcr_store zcr];
        end
    end
end

%% prepare output
xcr = xcr_store';
zcr = zcr_store';

if dbstate
    ph(4)     = plot(xcr,zcr,'oy','markerfacecolor','y');

    legendtxt = {'polygon 1','polygon 2','relevant poly2-sections','crossing(s)'};
    legend(ph,legendtxt,'FontWeight','bold','FontSize',8);
    legend('boxoff')

    axis equal; box on
    title('Testcase: findCrossingsOfPolygonAndPolygon')
    xlabel('x-values')
    ylabel('y-values', 'Rotation', 270, 'VerticalAlignment', 'top')
end