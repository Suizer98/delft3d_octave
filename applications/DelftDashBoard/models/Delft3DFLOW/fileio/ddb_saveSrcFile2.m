function ddb_saveSrcFile2(discharges,fname)
%DDB_SAVESRCFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveSrcFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%
%
%
%   Example
%   ddb_saveSrcFile
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

% $Id: ddb_saveSrcFile2.m 7299 2012-09-26 16:04:59Z ormondt $
% $Date: 2012-09-27 00:04:59 +0800 (Thu, 27 Sep 2012) $
% $Author: ormondt $
% $Revision: 7299 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/fileio/ddb_saveSrcFile2.m $
% $Keywords: $

%%
fid=fopen(fname,'w');

nr=length(discharges);

for i=1:nr
    
    name=deblank(discharges(i).name);
    if strcmpi(discharges(i).interpolation,'linear')
        cinterp='Y';
    else
        cinterp='N';
    end
    
    m=num2str(discharges(i).M);
    n=num2str(discharges(i).N);
    k=num2str(discharges(i).K);
    
    m=[repmat(' ',1,4-length(m)) m];
    n=[repmat(' ',1,4-length(n)) n];
    k=[repmat(' ',1,4-length(k)) k];
    
    ctype='';
    cmout='';
    cnout='';
    ckout='';
    
    switch lower(discharges(i).type)
        case{'walking'}
            ctype=' W';
        case{'inout'}
            ctype=' P';
            cmout=num2str(discharges(i).mOut);
            cnout=num2str(discharges(i).nOut);
            ckout=num2str(discharges(i).kOut);
            cmout=[repmat(' ',1,4-length(cmout)) cmout];
            cnout=[repmat(' ',1,4-length(cnout)) cnout];
            ckout=[repmat(' ',1,4-length(ckout)) ckout];
    end
    
    fprintf(fid,'%s\n',[name repmat(' ',1,21-length(name)) cinterp m n k ctype ' ' cmout ' ' cnout ' ' ckout]);
    
end

fclose(fid);



