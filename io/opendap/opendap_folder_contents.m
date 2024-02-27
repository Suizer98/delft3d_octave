function contents = opendap_folder_contents(url)
%OPENDAP_FOLDER_CONTENTS   get links to all *.nc files in a folder on OpenDap
%
%    C = opendap_folder_contents(url)
%
% url is the full path to a folder as copied from your web-browser. 
% Returns a structure C with all full links to *.nc files, which
% can be passed to SNCTOOLS
% Works urls on http://dtvirt5.deltares.nl:8080/ and
% http://opendap.deltares.nl 
%
% Example 1:
%
% url = 'http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/vaklodingen';
% url = 'http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/vaklodingen/contents.html';
% C   = opendap_folder_contents(url);
%
% Example 2:
%
% url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids';
% C   = opendap_folder_contents(url);
%
% See also: SNCTOOLS

warning('opendap_folder_contents is deprecated, use opendap_catalog instead')

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
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

% $Id: opendap_folder_contents.m 3467 2010-12-01 08:40:53Z geer $
% $Date: 2010-12-01 16:40:53 +0800 (Wed, 01 Dec 2010) $
% $Author: geer $
% $Revision: 3467 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/opendap/opendap_folder_contents.m $
% $Keywords: $

%% Define for each server

switch url(1:39)

    %% HYRAX
    case 'http://opendap.deltares.nl:8080/opendap'

        if ~strcmpi(url(end-13:end),'/contents.html')
        url = [url,'/contents.html']
        end

        string     = urlread([url]);
        startPos   = strfind(string, '.nc.html">');
        endPos     = strfind(string, '.nc</a>');
        for ii = 1 :length(endPos)
           contents{ii} = [url '/'   string(startPos(ii*2-1)+10:endPos(ii)+02)];
        end

        contents = strrep(contents,'contents.html/','');

    %% THREDDS
    case 'http://opendap.deltares.nl:8080/thredds'
    
        if ~strcmpi(url(end-12:end),'/catalog.html')
        url = [url,'/catalog.html']
        end

        string     = urlread([url]);
        startPos   = strfind(string, '.nc"><tt>');
        endPos     = strfind(string, '.nc</tt></a></td>');
        for ii = 1 :length(endPos)-2
           contents{ii} = [url '/'   string(startPos(ii)+09:endPos(ii)+2)];
        end
        contents = strrep(contents,'catalog.html/','');
        contents = strrep(contents,'/catalog/','/dodsC/');
        
    %% THREDDS
    case 'http://dtvirt5.deltares.nl:8080/thredds'
    
        if ~strcmpi(url(end-12:end),'/catalog.html')
        url = [url,'/catalog.html']
        end
        
        string     = urlread([url]);
        startPos   = cat(2,strfind(string, '.nc"><tt>'),strfind(string, '.nc''><tt>'),strfind(string, '.nc><tt>'));
        endPos     = strfind(string, '.nc</tt></a></td>');
        for ii = 1 :length(endPos)-2
           contents{ii} = [url '/'   string(startPos(ii)+09:endPos(ii)+2)];
        end
        contents = strrep(contents,'catalog.html/','');
        contents = strrep(contents,'/catalog/','/dodsC/');

end

