function ddb_saveDDBoundFile(bndind, fname)
%DDB_SAVEDDBOUNDFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveDDBoundFile(bndind, fname)
%
%   Input:
%   bndind =
%   fname  =
%
%
%
%
%   Example
%   ddb_saveDDBoundFile
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
nddb=length(bndind);
if nddb>0
    % Write DDBOUND file
    fid = fopen(fname,'wt');
    for i=1:nddb
        runid1=bndind(i).runid1;
        runid2=bndind(i).runid2;
        r1str=[runid1 '.mdf' repmat(' ',1,10-length(runid1))];
        r2str=[runid2 '.mdf' repmat(' ',1,10-length(runid2))];
        fprintf(fid,'%s %8i %8i %8i %8i %s %8i %8i %8i %8i\n',r1str,bndind(i).m1a,bndind(i).n1a,bndind(i).m1b,bndind(i).n1b,r2str,bndind(i).m2a,bndind(i).n2a,bndind(i).m2b,bndind(i).n2b);
    end
    fclose(fid);
end

