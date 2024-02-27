function ddb_DFlowFM_saveBCfile(forcingfile,boundaries,refdate)
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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

% $Id: ddb_DFlowFM_writeComponentsFile.m 9233 2013-09-19 09:19:19Z ormondt $
% $Date: 2013-09-19 11:19:19 +0200 (Thu, 19 Sep 2013) $
% $Author: ormondt $
% $Revision: 9233 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/fileio/ddb_DFlowFM_writeComponentsFile.m $
% $Keywords: $

% Get boundary name

%fid=fopen(forcingfile,'wt');

% First delete existing forcing files
for ii = 1:length(boundaries)
    fil=boundaries(ii).forcingfile;
    if exist(fil,'file')
        delete(fil);
    end
end


for ii = 1:length(boundaries)
    
    fid=fopen(boundaries(ii).forcingfile,'a');
    
    for jj = 1:length(boundaries(ii).nodenames)
        
        switch lower(boundaries(ii).nodes(jj).bc.Function)
            
            case{'astronomic'}
                
                % Header
                fprintf(fid,'%s\n',['[forcing]']);
                fprintf(fid,'%s\n',['Name                            = ' boundaries(ii).nodes(jj).name]);
                fprintf(fid,'%s\n',['Function                        = ' boundaries(ii).nodes(jj).bc.Function]);
                fprintf(fid,'%s\n',['Quantity                        = ',boundaries(ii).nodes(jj).bc.Quantity1]);
                fprintf(fid,'%s\n',['Unit                            = ',boundaries(ii).nodes(jj).bc.Unit1]);
                fprintf(fid,'%s\n',['Quantity                        = ',boundaries(ii).nodes(jj).bc.Quantity2]);
                fprintf(fid,'%s\n',['Unit                            = ',boundaries(ii).nodes(jj).bc.Unit2]);
                fprintf(fid,'%s\n',['Quantity                        = ',boundaries(ii).nodes(jj).bc.Quantity3]);
                fprintf(fid,'%s\n',['Unit                            = ',boundaries(ii).nodes(jj).bc.Unit3]);
                
                % Values
                for kk = 1 : size(boundaries(ii).nodes(jj).astronomiccomponents,2)
                    name = boundaries(ii).nodes(jj).astronomiccomponents(kk).component;
                    name = [name repmat(' ',1,6-length(name))];
                    amp = boundaries(ii).nodes(jj).astronomiccomponents(kk).amplitude;
                    phi = boundaries(ii).nodes(jj).astronomiccomponents(kk).phase;
                    fprintf(fid,'%s %8.5f %7.2f\n',name,amp,phi);
                end
                fprintf(fid,'%s\n',[]);

            case{'timeseries'}
                
                % Header
                fprintf(fid,'%s\n',['[forcing]']);
                fprintf(fid,'%s\n',['Name                            = ' boundaries(ii).nodes(jj).name]);
                fprintf(fid,'%s\n',['Function                        = ' boundaries(ii).nodes(jj).bc.Function]);
                fprintf(fid,'%s\n','Time-interpolation              = linear');
                fprintf(fid,'%s\n',['Quantity                        = time']);
                fprintf(fid,'%s\n',['Unit                            = ','seconds since ' datestr(refdate,'yyyy-mm-dd HH:MM:SS')]);
                fprintf(fid,'%s\n',['Quantity                        = waterlevelbnd']);
                fprintf(fid,'%s\n','Unit                            = m');
                % Values
                    fprintf(fid,'%12.2f %8.4f\n',0,0);
                    fprintf(fid,'%12.2f %8.4f\n',43200,8);
                    fprintf(fid,'%12.2f %8.4f\n',86400,0);
%                 for it=1:length(boundaries(ii).nodes(jj).timeseries.time)
%                     t=1440*(boundaries(ii).nodes(jj).timeseries.time(it)-refdate);
%                     v=boundaries(ii).nodes(jj).timeseries.value(it);
%                     fprintf(fid,'%12.2f %8.4f\n',t,v);
%                 end
                
        end
        
    end

fclose(fid);
end

%fclose(fid);
