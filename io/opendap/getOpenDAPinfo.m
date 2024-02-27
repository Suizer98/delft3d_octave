function OPeNDAPlinks = getOpenDAPinfo(varargin) 
%GETOPENDAPINFO  Routine returns a struct of all datafiles available from an OpenDAP url.
%
%   The routine returns a cell array containing all information about a user
%   specified OpenDAP url based on parsing the information contained in
%   catalog.xml. The url entered is expected to refer to a location that
%   includes catalog.xml information.  The routine should work starting at
%   any level.
%
%   Syntax:
%       OPeNDAPlinks = getOpenDAPinfo(varargin)
%
%   Input:
%       For the following keywords, values are accepted (values indicated are the current default settings):
%           'url', 'http://opendap.deltares.nl/thredds/catalog/opendap/catalog.xml' % default is OpenDAP test server url
%
%   Output:
%       OpenDAPinfo = cell array with info about the user specified url
%
%   Example:
%       url     = 'http://opendap.deltares.nl/thredds/catalog/opendap/catalog.xml'; % base url to use
%       OpenDAPinfo = getOpenDAPinfo_new('url', url);
% 
%       url     = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/catalog.xml'; % base url to use
%       OpenDAPinfo = getOpenDAPinfo_new('url', url);
% 
%       url     = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml'; % base url to use
%       OpenDAPinfo = getOpenDAPinfo_new('url', url);
% 
%       url     = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/catalog.xml'; % base url to use
%       OpenDAPinfo = getOpenDAPinfo_new('url', url);
%
%   See also getOpenDAPlinks

warning('getOpenDAPinfo is deprecated, use opendap_catalog instead')

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% Created: 26 Apr 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: getOpenDAPinfo.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/opendap/getOpenDAPinfo.m $
% $Keywords: $

%%  TODO: make routine more generic
%        - should also work if you start at a level where there are only datafiles
%        - should also be possible to choose only to find the institute and datasets levels (find datafiles only on demand to save time)

%%
OPT = struct(...
    'url',    'http://opendap.deltares.nl:8080/thredds/catalog/opendap/catalog.xml', ... % default is OpenDAP test server url
    'catpat', 'catalog.xml' ...                                                          % catalog string pattern to use
    );

OPT = setproperty(OPT, varargin{:});

%% initialise
url1     = OPT.url;

%% print start message
clc
disp(['Analysing OpenDAP url: ' OPT.url])
disp(' ')
disp('This may take several seconds depending on:')
disp('... the speed of your internet connection')
disp('... the depth of your request')

%% start
tic
datacell = {[]};
tst      = [];
i        = 1;
% datacell must be a cellarray where each row ends with .nc
while ~isempty(i)
    %% construct initial add2cell
    if ~isempty(datacell{i})
        newurl       = [url1(1:strfind(url1, 'catalog.xml')-1) datacell{i} '/' OPT.catpat];
        add2cell     = [];
    else
        newurl       = url1;
        add2cell     = [];
    end
    
    %% add datafiles
    Datafiles    = getOpenDAPlinks('url', newurl, 'pattern', 'dataset name="');
    Datafiles    = Datafiles(~cellfun(@isempty, strfind(Datafiles,'.nc')));
    if ~isempty(Datafiles)
        for j = 1:length(Datafiles)
            startid = strfind(url1,OPT.catpat);
            stopid  = strfind(newurl,OPT.catpat)-2;
            pathstr = newurl(startid:stopid);
            if ~isempty(pathstr)
                add2cell{length(add2cell)+1, 1} = [pathstr '/' Datafiles{j}]; %#ok<*AGROW>
            else % which will happen when data files are found at the root search level
                add2cell{length(add2cell)+1, 1} = [Datafiles{j}]; %#ok<*AGROW>
            end
        end
    end
    
    %% add deeper levels
    Deeperlevels = getOpenDAPlinks('url', newurl, 'pattern', ' xlink:title="');
    if ~isempty(Deeperlevels)
        for j = 1:length(Deeperlevels)
            try
                if ~strcmp(Deeperlevels{j}, 'KMLpreview')
                    startid = strfind(url1,OPT.catpat);
                    stopid  = strfind(newurl,OPT.catpat)-2;
                    pathstr = newurl(startid:stopid);
                    if ~isempty(pathstr)
                        add2cell{length(add2cell)+1, 1}= [pathstr '/' Deeperlevels{j}];
                    else % which will happen when data files are found at the root search level
                        add2cell{length(add2cell)+1, 1}= [Deeperlevels{j}];
                    end
                end
            catch
                xx = 0
            end
        end
    end
    
    %% Create new add2cell
    if i==1
        datacell = {add2cell{:} datacell{i+1:end}}';
    elseif i == length(datacell)
        datacell = {datacell{1:i-1}  add2cell{:}}';
    else
        datacell = {datacell{1:i-1}  add2cell{:} datacell{i+1:end}}';
    end
    
    clear add2cell
    tst = cellfun(@strfind, datacell, repmat({'.nc'}, size(datacell)), 'UniformOutput', 0);
    tst = cellfun(@isempty, tst, 'UniformOutput', 0);
    tst = vertcat(tst{:});
    i = find(tst, 1, 'first');
    if ~isempty(i)
        disp(['Expanding entry ' num2str(i) ' of ' num2str(length(datacell))])
    else
        disp([' '])
        disp(['Information from OpenDAP url complete. A total of ' num2str(length(datacell)) ' datafiles was found.'])
    end
end

%% create output OPeNDAPlinks (this is a cell array of urls to all available nc files)
roots   = repmat([fileparts(strrep(OPT.url,'catalog','dodsC')) '/'], size(datacell));
ncfiles = char(datacell);
OPeNDAPlinks = cellstr([roots ncfiles]);

disp(['Analysis finished in ' num2str(toc) ' seconds'])