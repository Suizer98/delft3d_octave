function ddb_saveAllModelFiles
%ddb_saveAllModelFiles  Saves all files and attributes

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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

% $Id: ddb_saveAllModelFiles.m 6808 2012-07-06 17:02:39Z ormondt $
% $Date: 2012-07-07 01:02:39 +0800 (Sat, 07 Jul 2012) $
% $Author: ormondt $
% $Revision: 6808 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/operations/ddb_saveAllModelFiles.m $
% $Keywords: $

%%
handles=getHandles;

activeModel=md;
for im=1:length(handles.Model)
    switch lower(handles.Model(im).name)
        case{'delft3dflow'}
            if handles.Model(im).Input(1).MMax>0
                handles=getHandles;
                handles.activeModel.nr=im;
                setHandles(handles);
                ddb_saveDelft3DFLOW('saveall');
                handles=getHandles;
                handles.activeModel.nr=activeModel;
                setHandles(handles);
            end
        case{'delft3dwave'}
            if handles.Model(im).Input.domains(1).mmax>0
                handles=getHandles;
                handles.activeModel.nr=im;
                setHandles(handles);
                ddb_saveDelft3DWAVE('saveall');
                handles=getHandles;
                handles.activeModel.nr=activeModel;
                setHandles(handles);
            end
    end
end
