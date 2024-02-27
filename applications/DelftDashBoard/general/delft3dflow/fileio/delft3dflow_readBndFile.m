function openBoundaries = delft3dflow_readBndFile(fname)
%DELFT3DFLOW_READBNDFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   openBoundaries = delft3dflow_readBndFile(fname)
%
%   Input:
%   fname          =
%
%   Output:
%   openBoundaries =
%
%   Example
%   delft3dflow_readBndFile
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

% $Id: delft3dflow_readBndFile.m 5562 2011-12-02 12:20:46Z boer_we $
% $Date: 2011-12-02 20:20:46 +0800 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5562 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/fileio/delft3dflow_readBndFile.m $
% $Keywords: $

%%
fid=fopen(fname);

n=0;
openBoundaries=[];

for i=1:1000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        n=n+1;
        
        % Defaults
        openBoundaries(n).compA='unnamed';
        openBoundaries(n).compB='unnamed';
        openBoundaries(n).profile='Uniform';
        
        v=strread(tx0(22:end),'%q');
        openBoundaries(n).M1=str2double(v{3});
        openBoundaries(n).N1=str2double(v{4});
        openBoundaries(n).M2=str2double(v{5});
        openBoundaries(n).N2=str2double(v{6});
        openBoundaries(n).name=deblank(tx0(1:21));
        openBoundaries(n).type=v{1};
        openBoundaries(n).forcing=v{2};
        openBoundaries(n).alpha=str2double(v{7});
        ii=8;
        switch openBoundaries(n).type
            case{'C','Q','T','R'}
                openBoundaries(n).profile=v{8};
                ii=9;
            otherwise
                openBoundaries(n).profile='Uniform';
        end
        switch openBoundaries(n).forcing
            case{'A'}
                openBoundaries(n).compA=v{ii};
                openBoundaries(n).compB=v{ii+1};
        end
    end
end

fclose(fid);

