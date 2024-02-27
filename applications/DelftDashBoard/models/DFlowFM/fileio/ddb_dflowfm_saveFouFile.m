function ddb_dflowfm_saveFouFile(handles, id)
%DDB_SAVEFOUFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveFouFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%
%
%
%   Example
%   ddb_saveFouFile
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

% $Id: ddb_saveFouFile.m 12596 2016-03-17 10:04:25Z ormondt $
% $Date: 2016-03-17 11:04:25 +0100 (Thu, 17 Mar 2016) $
% $Author: ormondt $
% $Revision: 12596 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/dflowfm/fileio/ddb_saveFouFile.m $
% $Keywords: $

%%
tab=handles.model.dflowfm.domain(id).fourier.editTable;
fid=fopen(handles.model.dflowfm.domain(id).foufile,'wt');
plist=handles.model.dflowfm.domain(ad).fourier.pList;
for i=1:length(tab.parameterNumber)
    par=plist{tab.parameterNumber(i)};
    parstr=par;
    if strcmpi(par,'wl')
        lstr='';
    else
        lstr=num2str(tab.layer(i));
    end
    switch tab.option(i)
        case 1
            optstr='';
        case 2
            optstr='max';
        case 3
            optstr='min';
        case 4
            optstr='y';
    end
    
    tunit=handles.model.dflowfm.domain(id).tunit;
    switch lower(tunit)
        case{'m'}
            tfac=1440;
        case{'s'}
            tfac=86400;
    end
    
    t0str=num2str((tab.startTime(i)-handles.model.dflowfm.domain(id).refdate)*tfac,'%10.2f');
    t0str=[repmat(' ',1,12-length(t0str)) t0str];
    t1str=num2str((tab.stopTime(i)-handles.model.dflowfm.domain(id).refdate)*tfac,'%10.2f');
    t1str=[repmat(' ',1,12-length(t1str)) t1str];
    nrstr=num2str(tab.nrCycles(i));
    nrstr=[repmat(' ',1,6-length(nrstr)) nrstr];
    ampstr=num2str(tab.nodalAmplificationFactor(i),'%10.5f');
    ampstr=[repmat(' ',1,12-length(ampstr)) ampstr];
    argstr=num2str(tab.astronomicalArgument(i),'%10.5f');
    argstr=[repmat(' ',1,12-length(argstr)) argstr];
    
    lstr=[repmat(' ',1,5-length(lstr)) lstr];
    lstr=deblank(lstr);
    optstr=[repmat(' ',1,5-length(optstr)) optstr];
    
    str=[parstr ' ' t0str t1str nrstr ampstr argstr lstr optstr];
    str=deblank(str);
    fprintf(fid,'%s\n',str);
    
end
fclose(fid);

