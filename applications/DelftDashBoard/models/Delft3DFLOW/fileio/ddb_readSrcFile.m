function handles = ddb_readSrcFile(handles, id)
%DDB_READSRCFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readSrcFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readSrcFile
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
handles.model.delft3dflow.domain(id).nrDischarges=0;
handles.model.delft3dflow.domain(id).discharges=[];

fid=fopen(handles.model.delft3dflow.domain(id).srcFile,'r');

nr=0;
tx0='a';
while ~isempty(tx0)
    v=fgets(fid);
    if ischar(v)
        tx0=deblank(v);
    else
        tx0=[];
    end
    if and(ischar(tx0), size(tx0>0))
        nr=nr+1;
        handles.model.delft3dflow.domain(id).discharges(nr).name=deblank(tx0(1:20));
        handles.model.delft3dflow.domain(id).dischargeNames{nr}=deblank(tx0(1:20));
        handles.model.delft3dflow.domain(id).discharges(nr).type='normal';
        handles.model.delft3dflow.domain(id).discharges(nr).mOut=0;
        handles.model.delft3dflow.domain(id).discharges(nr).nOut=0;
        handles.model.delft3dflow.domain(id).discharges(nr).kOut=0;
        v0=strread(tx0(21:end),'%q');
        if strcmpi(v0{1},'y')
            handles.model.delft3dflow.domain(id).discharges(nr).interpolation='linear';
        else
            handles.model.delft3dflow.domain(id).discharges(nr).interpolation='block';
        end
        handles.model.delft3dflow.domain(id).discharges(nr).M=str2double(v0{2});
        handles.model.delft3dflow.domain(id).discharges(nr).N=str2double(v0{3});
        handles.model.delft3dflow.domain(id).discharges(nr).K=str2double(v0{4});
        if length(v0)>4
            switch lower(v0{5})
                case{'p'}
                    handles.model.delft3dflow.domain(id).discharges(nr).type='inout';
                    handles.model.delft3dflow.domain(id).discharges(nr).mOut=str2double(v0{6});
                    handles.model.delft3dflow.domain(id).discharges(nr).nOut=str2double(v0{7});
                    handles.model.delft3dflow.domain(id).discharges(nr).kOut=str2double(v0{8});
                case{'w'}
                    handles.model.delft3dflow.domain(id).discharges(nr).type='walking';
            end
        end
    else
        tx0=[];
    end
end

handles.model.delft3dflow.domain(id).nrDischarges=nr;

fclose(fid);


