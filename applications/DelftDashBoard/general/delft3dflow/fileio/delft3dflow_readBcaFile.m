function astronomicComponentSets = delft3dflow_readBcaFile(fname)
%DELFT3DFLOW_READBCAFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   astronomicComponentSets = delft3dflow_readBcaFile(fname)
%
%   Input:
%   fname                   =
%
%   Output:
%   astronomicComponentSets =
%
%   Example
%   delft3dflow_readBcaFile
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

% $Id: delft3dflow_readBcaFile.m 10159 2014-02-06 16:42:25Z ormondt $
% $Date: 2014-02-07 00:42:25 +0800 (Fri, 07 Feb 2014) $
% $Author: ormondt $
% $Revision: 10159 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/fileio/delft3dflow_readBcaFile.m $
% $Keywords: $

%%
fid=fopen(fname);

k=0;
for i=1:10000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%q');
    else
        v0='';
    end
    if ~isempty(v0)
        if length(v0)==1
            k=k+1;
            j=1;
            astronomicComponentSets(k).name=v0{1};
        else
            astronomicComponentSets(k).component{j}=v0{1};
            astronomicComponentSets(k).amplitude(j)=str2double(v0{2});
            if length(v0)>2
                astronomicComponentSets(k).phase(j)=str2double(v0{3});
            else
                % Only amplitude given (A0 component)
                astronomicComponentSets(k).phase=0;
            end
            astronomicComponentSets(k).correction(j)=0;
            astronomicComponentSets(k).amplitudeCorrection(j)=1;
            astronomicComponentSets(k).phaseCorrection(j)=0;
            astronomicComponentSets(k).nr=j;
            j=j+1;
        end
    else
        fclose(fid);
        return
    end
end

fclose(fid);


