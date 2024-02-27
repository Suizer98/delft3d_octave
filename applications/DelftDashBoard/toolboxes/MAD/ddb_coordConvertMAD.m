function handles = ddb_coordConvertMAD(handles)
%DDB_COORDCONVERTMAD  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_coordConvertMAD(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_coordConvertMAD
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
ii=strmatch('MAD',{handles.Toolbox(:).Name},'exact');

h=findall(gcf,'Tag','MADModels');
if ~isempty(h)
    for i=1:length(handles.Toolbox(ii).Models)
        x(i,1)=handles.Toolbox(ii).Models(i).Longitude;
        y(i,1)=handles.Toolbox(ii).Models(i).Latitude;
    end
    cs.Name='WGS 84';
    cs.Type='Geographic';
    [x,y]=ddb_coordConvert(x,y,cs,handles.ScreenParameters.CoordinateSystem);
    z=zeros(size(x))+500;
    handles.Toolbox(ii).xy=[x y];
    set(h,'XData',x,'YData',y,'ZData',z);
end

h=findall(gca,'Tag','ActiveMADModel');
if ~isempty(h)
    n=handles.Toolbox(ii).ActiveMADModel;
    x=handles.Toolbox(ii).Models(n).Longitude;
    y=handles.Toolbox(ii).Models(n).Latitude;
    cs.Name='WGS 84';
    cs.Type='Geographic';
    [x,y]=ddb_coordConvert(x,y,cs,handles.ScreenParameters.CoordinateSystem);
    set(h,'XData',x,'YData',y);
end

