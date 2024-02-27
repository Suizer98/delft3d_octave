function h = plottable(table,varargin)
%PLOTTABLE plots a table in the current figure
%
%   Plots a table with or without an optional header in the
%   current figure and returns a handle to it. The numbers are right
%   aligned. Optional header text is centered.
%
%   Syntax:
%   h = plottable(table,varargin)
%
%   Input:
%   table  = array of strings (use sprintf for numbers)
%
%   Optional arguments:
%   fontsize = fontsize used for the table (default is 10)
%   firstrowheader = logical (true or false) denoting whether the first row
%                    is used as a header (default) or not
%   firstcolumnheader = logical (true or false) denoting whether first row
%                    is used as a header or not (default is not)
%
%   Output:
%   h = handle to the table, e.g. to reposition it in the current figure
%
%   Example:
%   clear table;
%   series = rand(6,8);
%   for i = 1:6
%     for j = 1:8
%        table{i+1,j} = sprintf('%5.2f',series(i,j));
%     end
%   end
%   table{1,2} = 'column 2';
%   table{1,3} = 'column 3';
%   table{1,4} = 'column 4';
%   table{1,5} = 'column 5';
%   table{1,6} = 'column 6';
%   table{1,7} = 'column 7';
%   table{1,8} = 'column 8';
% 
%   table{2,1} = 'row 2';
%   table{3,1} = 'row 3';
%   table{4,1} = 'row 4';
%   table{5,1} = 'row 5';
%   table{6,1} = 'row 6';
%   table{7,1} = 'row 7';  
%   
%   axes('position',[.1  .14  .8  .5]);
%   h = plottable_v02(table,'fontsize',7,'firstrowheader',true,'firstcolumnheader',true);
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Alkyon Hydraulic Consultancy & Research
%       grasmeijerb
%
%       bart.grasmeijer@alkyon.nl
%
%       P.O. Box 248
%       8300 AE Emmeloord
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 01 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id: plottable.m 912 2009-09-03 08:04:08Z b.t.grasmeijer@arcadis.nl $
% $Date: 2009-09-03 16:04:08 +0800 (Thu, 03 Sep 2009) $
% $Author: b.t.grasmeijer@arcadis.nl $
% $Revision: 912 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/plottable.m $
% $Keywords: $

%%

fontsize = 10;                                                              % default values for optional arguments
firstrowheader = true;
firstcolumnheader = false;

optvals = varargin;                                                         % read the optional arguments and their values
if 2*round(length(optvals)/2)~=length(optvals),
    error('Invalid option-value pair');
else
    optvals=reshape(optvals,[2 length(optvals)/2]);
end;
OptionUsed=false(1,size(optvals,2));
for i=1:size(optvals,2),
    if ~ischar(optvals{1,i}),
        error('Invalid option'),
    end;
    switch lower(optvals{1,i}),
        case 'fontsize',
            fontsize = optvals{2,i};
            OptionUsed(i)=1;
        case 'firstrowheader',
            firstrowheader = optvals{2,i};
            OptionUsed(i)=1;
        case 'firstcolumnheader',
            firstcolumnheader = optvals{2,i};
            OptionUsed(i)=1;
    end
end;
optvals(:,OptionUsed)=[];                                                   % delete used options

ncols = length(table(1,:));
nrows = length(table(:,1));

x = 0:2:2*ncols;
y = 0:2:2*nrows;

h = newplot;
[XI,YI] = meshgrid(x,y);
ZI = ones(size(XI));
if firstrowheader
    ZI(1,:) = 0.8;                                                          % first row background grey
end
if firstcolumnheader
    ZI(:,1) = 0.8;                                                          % first column background grey
end
pcolor(XI,YI,ZI);
set(gca,'YDir','reverse');
colormap(bone(10));
caxis([0 1]);
ypos = 1;
for i = 1:nrows
    xpos = 1;
    for j = 1:ncols
        if i == 1 && firstrowheader
            text(xpos,ypos,table(i,j),'horizontalalignment','center','fontsize',fontsize);
        end
        if j == 1 && firstcolumnheader
            text(xpos,ypos,table(i,j),'horizontalalignment','center','fontsize',fontsize);
        end
        if i==1 && j==1 && firstrowheader && firstcolumnheader
            text(xpos,ypos,table(i,j),'horizontalalignment','center','fontsize',fontsize);
        end
        if i~=1 && j~=1
            text(xpos+0.25,ypos,table(i,j),'horizontalalignment','right','fontsize',fontsize);
        end
        xpos = xpos+2;
    end
    ypos = ypos+2;
end
set(gca,'xticklabel',[],'yticklabel',[]);

