function handles = ddb_readTsunamiFile(handles, filename)
%DDB_READTSUNAMIFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readTsunamiFile(handles, filename)
%
%   Input:
%   handles  =
%   filename =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_readTsunamiFile
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
txt=ReadTextFile(filename);
nseg=0;
nvert=0;
for i=1:length(txt)
    switch(lower(txt{i})),
        case{'magnitude'}
            handles.toolbox.tsunami.Magnitude=str2num(txt{i+1});
        case{'depthfromtop'}
            handles.toolbox.tsunami.DepthFromTop=str2num(txt{i+1});
        case{'relatedtoepicentre'}
            if strcmp(lower(txt{i+1}(1)),'y')
                handles.toolbox.tsunami.RelatedToEpicentre=1;
            else
                handles.toolbox.tsunami.RelatedToEpicentre=0;
            end
        case{'latitude'}
            handles.toolbox.tsunami.Latitude=str2num(txt{i+1});
        case{'longitude'}
            handles.toolbox.tsunami.Longitude=str2num(txt{i+1});
        case{'nrsegments'}
            handles.toolbox.tsunami.NrSegments=str2num(txt{i+1});
        case{'segment'}
            nseg=nseg+1;
            handles.toolbox.tsunami.Dip(nseg)=str2num(txt{i+1});
            handles.toolbox.tsunami.SlipRake(nseg)=str2num(txt{i+2});
        case{'vertex'}
            nvert=nvert+1;
            handles.toolbox.tsunami.FaultX(nvert)=str2num(txt{i+1});
            handles.toolbox.tsunami.FaultY(nvert)=str2num(txt{i+2});
    end
end

