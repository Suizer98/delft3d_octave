function M = matroos_noos_header(header)
%matroos_noos_header   write <-> parse NOOS time series header enriched by MATROOS
%
% headerlines  = matroos_noos_header(headerstruct)
% headerstruct = matroos_noos_header(headerlines ) where noos_write()
%
% [time, values, headerlines] = noos_read(...)
% noos_write(time, values, headerlines)
%
% The NOOS format looks like this the lines with # are the Matroos header
%
% #------------------------------------------------------
% # Timeseries retrieved from the MATROOS maps1d database
% # Created at Tue Oct 28 20:33:51 CET 2008
% #------------------------------------------------------
% # Location    : MAMO001_0
% # Position    : (64040,444970) % (lon,lat)
% # Source      : sobek_hmr
% # Unit        : waterlevel
% # Analyse time: 200709020100
% # Timezone    : MET
% #------------------------------------------------------
% 200709010000   -0.387653201818466
% 200709010010   -0.395031750202179
% 200709010020   -0.407451331615448
% 200709010030   -0.414252400398254
% 200709010040   -0.425763547420502
% 200709010050   -0.43956795334816
% 200709010100   -0.309808939695358
% 200709010110   -0.297703713178635
% 200709010120   -0.289261430501938
% 200709010130   -0.256232291460037
%
%See also: MATROOS_GET_SERIES, NOOS_READ, NOOS_WRITE

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Rijkswaterstaat
%       Gerben de Boer
%
%       g.j.deboer@deltares.nl	
%
%       Deltares
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id: matroos_noos_header.m 11618 2015-01-09 09:53:00Z gerben.deboer.x $
% $Date: 2015-01-09 17:53:00 +0800 (Fri, 09 Jan 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11618 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/matroos/matroos_noos_header.m $
% $Keywords: $

%% defaults
M.loc              = [];
M.latlonstr        = [];
M.lon              = [];
M.lat              = [];
M.tanalysis        = [];
M.datenumanalysis  = [];
M.unit             = [];
M.timezone         = [];
M.source           = [];

if isstr(header)
    header = {header};
end

if isempty(header)
    return
end

if iscellstr(header)
    for i=1:length(header)

       if any(strfind(header{i},'Location'    )); 
       index              = strfind(header{i},':');
       M.loc              =        (header{i}(index+1:end));
       end

       if any(strfind(header{i},'Position'    )); 
       index1             = strfind(header{i},'(');
       index2             = strfind(header{i},',');
       index3             = strfind(header{i},')');
       M.latlonstr        =    ['(',header{i}(index1+1:index2-1),'°E,',...
                                    header{i}(index2+1:index3-1),'°N)'];
       M.lon              = str2num(header{i}(index1+1:index2-1));
       M.lat              = str2num(header{i}(index2+1:index3-1));
       end

       if any(strfind(header{i},'Source'      )); 
       index              = strfind(header{i},':');
       M.source           = strtok(header{i}(index+1:end));
       end

       if any(strfind(header{i},'Unit'        )); 
       index              = strfind(header{i},':');
       M.unit             = strtok(header{i}(index+1:end));
       end

       if any(strfind(header{i},'Analyse time'));
       if any(strfind(header{i},'*** no data found ***'))
       M.tanalysis        = [];
       M.datenumanalysis  = [];
       else
       index              = strfind(header{i},':');
       M.tanalysis        = strtok(header{i}(index+1:end));
       M.datenumanalysis  = datenum(M.tanalysis,'yyyymmddHHMM');
       end
       end

       if any(strfind(header{i},'Timezone'    )); 
       index              = strfind(header{i},':');
       M.timezone         = strtok(header{i}(index+1:end));
       end

       if any(strfind(header{i},' Created at'    )); 
       index              = strfind(header{i},'Created at');
       M.tretrieved       = header{i}(index+11:end);
      %M.datenumretrieved = 
       end

    end
elseif isstruct(header) 

    M        =  {'#------------------------------------------------------'};
    M{end+1} =  ['# Location    : ',char(header.loc)];
    M{end+1} =  ['# Position    : (',num2str(header.lon),',',num2str(header.lat),')'];
    M{end+1} =  ['# Source      : ',header.source];
    M{end+1} =  ['# Unit        : ',header.unit];
    M{end+1} =  ['# Analyse time: ',datestr(header.datenumanalysis,'yyyymmddHHMM')];
    M{end+1} =  ['# Timezone    : ',char(header.timezone)];
    M{end+1} =  ['#------------------------------------------------------'];
    

end