function fig = MakeNewWindow(Name, sz, varargin)
%MAKENEWWINDOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   fig = MakeNewWindow(Name, sz, varargin)
%
%   Input:
%   Name     =
%   sz       =
%   varargin =
%
%   Output:
%   fig      =
%
%   Example
%   MakeNewWindow
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
modal=0;

global figureiconfile

if ~isempty(figureiconfile)
    iconFile=figureiconfile;
end

if ~isempty(varargin)
    ii=strmatch('modal',varargin,'exact');
    if ~isempty(ii)
        modal=1;
    end
    for ij=1:length(varargin)
        if exist(varargin{ij},'file') && findstr(varargin{ij},'deltares.gif')
            iconFile=varargin{ij};
        end
    end
end


fig=figure;
set(fig,'Visible','off');

fh = get(fig,'JavaFrame'); % Get Java Frame
if exist('iconFile','var')
    fh.setFigureIcon(javax.swing.ImageIcon(iconFile));
end

set(fig,'menubar','none');
set(fig,'toolbar','none');
if modal
    set(fig,'windowstyle','modal');
end
set(fig,'Units','pixels');
set(fig,'Position',[0 0 sz(1) sz(2)]);
set(fig,'Name',Name,'NumberTitle','off');
set(fig,'Tag',Name);
%set(fig,'Resize','off');
PutInCentre(fig);

set(fig,'Visible','on');

