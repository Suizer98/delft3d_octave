function [q1 q2 q3] = freeBoxPlot(data0, lineWidth, width, dir)
%FREEBOXPLOT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [q1 q2 q3] = freeBoxPlot(data0, lineWidth, width, dir)
%
%   Input:
%   data0     =
%   lineWidth =
%   width     =
%   dir       =
%
%   Output:
%   q1        =
%   q2        =
%   q3        =
%
%   Example
%   freeBoxPlot
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
% [lowerQuartile,median,upperQuartile]=freeBoxPlot(data0) - plot box-whiskers diagram, accept multiple columns
% Arguments: data0 -  unsorted data, mxn, m samples, n columns
%            lineWidth -  line thickness in the plot default = 1;
%            width -  the width of the box, default = 1;
%            dir - specify if directional data is used, default = 0; NB:
%            if data is directional, specify it in degrees!!
% Returns:
% Notes: each column is considered as a single set

if(nargin < 4)
    dir = 0;
end
if(nargin < 3)
    width = 1;
end;
if(nargin < 2)
    lineWidth = 1;
end;


[m n] = size(data0);

% account for nan's
if ~dir
    data = sort(data0, 1); % ascend
    data2=mat2cell(data,size(data,1),repmat(1,1,size(data,2)));
    data3=cellfun(@(x) x(~isnan(x)),data2,'UniformOutput',false);
    q2=cell2mat(cellfun(@median,data3,'UniformOutput',false));
else
    data = sort(data0, 1); % ascend
    data0x = sort(cos(deg2rad(data0)),1);
    data0y = sort(sin(deg2rad(data0)),1);
    data2x=mat2cell(data0x,size(data0x,1),repmat(1,1,size(data0x,2)));
    data3x=cellfun(@(x) x(~isnan(x)),data2x,'UniformOutput',false);
    q2x=cell2mat(cellfun(@median,data3x,'UniformOutput',false));
    data2y=mat2cell(data0y,size(data0y,1),repmat(1,1,size(data0y,2)));
    data3y=cellfun(@(x) x(~isnan(x)),data2y,'UniformOutput',false);
    q2y=cell2mat(cellfun(@median,data3y,'UniformOutput',false));
    q2=mod(rad2deg(atan2(q2y,q2x)),360);
end
%     q2 = median(data, 1);

%     if(rem(m,2) == 0)
%
% %         upperA = data(1:m/2,:);
% %         lowA =  data(m/2+1:end,:);
%
%         upperA = cellfun(@(x) x(1:m/2),data3,'UniformOutput',false);
%         lowerA = cellfun(@(x) x(m/2+1:end),data3,'UniformOutput',false);
%     else

%         upperA = data(1:round(m/2), :);
%         lowA =  data(round(m/2):end, :);
if dir
    upperA = data;
    upperA(upperA>repmat(q2,size(upperA,1),1))=upperA(upperA>repmat(q2,size(upperA,1),1))-360;
    upperA = sort(upperA,1);
    upperA = mat2cell(upperA,size(upperA,1),repmat(1,1,size(upperA,2)));
    upperA = cellfun(@(x) x(~isnan(x)),upperA,'UniformOutput',false);
    upperA = cellfun(@(x) x(round(length(x)/2):end),upperA,'UniformOutput',false);
    lowA = data;
    lowA(lowA<repmat(q2,size(lowA,1),1))=lowA(lowA<repmat(q2,size(lowA,1),1))+360;
    lowA = sort(lowA,1);
    lowA = mat2cell(lowA,size(lowA,1),repmat(1,1,size(lowA,2)));
    lowA = cellfun(@(x) x(~isnan(x)),lowA,'UniformOutput',false);
    lowA = cellfun(@(x) x(1:round(length(x)/2)),lowA,'UniformOutput',false);
else
    upperA = cellfun(@(x) x(1:round(length(x)/2)),data3,'UniformOutput',false);
    lowA   = cellfun(@(x) x(round(length(x)/2)+1:end),data3,'UniformOutput',false);
end
%     end;

%     q1 = median(upperA, 1);
%     q3 = median(lowA, 1);

q1=cell2mat(cellfun(@median,upperA,'UniformOutput',false));
q3=cell2mat(cellfun(@median,lowA,'UniformOutput',false));

%     min_v = data(1,:);
%     max_v = data(end,:);

if dir
    min_v = repmat(nan,size(q1));
    max_v = repmat(nan,size(q1));
else
    min_v = cellfun(@(x) x(1),data3);
    max_v = cellfun(@(x) x(end),data3);
end
draw_data = [max_v; q3; q2; q1; min_v];

% adjust the width
drawBox(draw_data, lineWidth, width, dir);


return;


function drawBox(draw_data, lineWidth, width, dir)

n = size(draw_data, 2);

unit = (1-1/(1+n))/(1+9/(width+3));

f1=gcf;
hold on;
for i = 1:n
    
    v = draw_data(:,i);
    
    % draw the min line
    plot([i-unit, i+unit], [v(5), v(5)], 'LineWidth', lineWidth,'color','k');
    % draw the max line
    plot([i-unit, i+unit], [v(1), v(1)], 'LineWidth', lineWidth,'color','k');
    % draw middle line
    plot([i-unit, i+unit], [v(3), v(3)], 'LineWidth', lineWidth,'color','r');
    % draw vertical line
    plot([i, i], [v(5), v(4)], 'LineWidth', lineWidth,'color','k','linestyle',':');
    plot([i, i], [v(2), v(1)], 'LineWidth', lineWidth,'color','k','linestyle',':');
    
    % draw box
    if dir
        if v(2)>360
            plot([i+unit, i+unit, i-unit, i-unit], [360, v(4), v(4), 360], 'LineWidth', lineWidth,'color','b');
            plot([i+unit, i+unit, i-unit, i-unit], [0, mod(v(2),360),mod(v(2),360),0], 'LineWidth', lineWidth,'color','b');
        elseif v(4)<0
            plot([i-unit, i-unit, i+unit, i+unit], [0, v(2), v(2), 0], 'LineWidth', lineWidth,'color','b');
            plot([i-unit, i-unit, i+unit, i+unit], [360, v(4)+360, v(4)+360, 360], 'LineWidth', lineWidth,'color','b');
        else
            plot([i-unit, i+unit, i+unit, i-unit, i-unit], [v(2), v(2), v(4), v(4), v(2)], 'LineWidth', lineWidth,'color','b');
        end
    else
        plot([i-unit, i+unit, i+unit, i-unit, i-unit], [v(2), v(2), v(4), v(4), v(2)], 'LineWidth', lineWidth,'color','b');
    end
end;

return;

