function varargout = csw(varargin)
warning('Work In Progress')
%csw construct and validate OGC csw request from Catalogue Service for the Web (CS-W)
%
%  [url,OPT,lims] = csw(<keyword,value>)
%  [url,OPT,lims] = csw(OPT)
%
% where
% url  - is valid csw request constructed from user-keywords 
%        and (cached) getcapabilities request.
% lims - are the available options per keyword.
% OPT  - contains as input the user-keywords and as output valid
%        values for the keywords, as first valid value from getcapabilities
%        or interactive selection from UI pop-up with available options, or
%        simply returns validated values unaltered.
%
% Example: NGR
%
%   [url,OPT] = csw('server','http://geoport.whoi.edu/thredds/wms/bathy/smith_sandwell_v11?','colorscalerange',[-2e3 2e3]);
%
%See also: wms, wcs, wfs, WMS_IMAGE_PLOT, arcgis, netcdf, opendap, postgresql, xml_read
%          KMLimage (wrap WMS in KML)
%          http://publicwiki.deltares.nl/display/OET/CSW+primer
%          https://pypi.python.org/pypi/OWSLib
%          http://nbviewer.ipython.org/urls/raw.github.com/Unidata/tds-python-workshop/master/wms_sample.ipynb
%          http://disc.sci.gsfc.nasa.gov/services/ogc_wms

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares - gerben.deboer@deltares.nl
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
% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

lim.service = 'CSW';
lim.version = {''}; % union of those offered by server and those implemented here

% standard
OPT.server          = 'http://www.dummy.yz';
OPT.version         = '1.3.0';       % or 1.1.1
OPT.request         = 'DescribeRecord';
OPT.sections        = '';            % from getCapabilities, coverage in CSW
OPT.AcceptVersions  = [];            % check for bounds from getCapabilities
OPT.AcceptFormats   = '';            % check order for lat-lon vs. lon-lat

OPT.updateSequence  = '';            % default; from getCapabilities [optional] for getcapabilities

OPT.NAMESPACE       = '';            % default; from getCapabilities [optional] for DescribeRecord
OPT.TypeName        = '';            % default; from getCapabilities [optional] for DescribeRecord
OPT.outputFormat    = '';            % default; from getCapabilities [optional] for DescribeRecord
OPT.schemaLanguage  = '';            % default; from getCapabilities [optional] for DescribeRecord


OPT.disp            = 0;             % write screen logs
OPT.cachedir        = [tempdir,'matlab.ows',filesep]; % store cache of xml (and later png)

%% non-standard

   OPT.colorscalerange = [];
   
   if nargin==0
       varargout = {[OPT]};
       return
   end
   
   OPT = setproperty(OPT,varargin);

%% get_capabilities

   xml = wxs_url_cache(OPT.server,['service=',service,'&version=',OPT.version,'&request=GetCapabilities'],OPT.cachedir);

%% check available version

   if strcmpi(xml.ATTRIBUTE.version,'2.0.2')
      OPT.version = '2.0.2';
   else
       error([lim.service,' not 2.0.2'])
   end

%% construct url: standard keywords
%  Note that the parameter names in all KVP encodings shall be handled
%  in a case insensitive manner while parameter values shall be handled in a case sensitive
%  manner. [csw 2.0.2 p 128]

   url = [OPT.server,'&service=',lim.service,...
   '&version='    ,         OPT.version,...
   '&request='    ,         OPT.request,...
   '&sections='   ,         OPT.sections,...
   '&AcceptVersions=',      OPT.AcceptVersions,...
   '&AcceptFormats=',       OPT.AcceptFormats];

%% construct url: standard options or non-standard extensions

   if ~isempty(OPT.updateSequence)
      if ischar(OPT.updateSequence)
         url = [url, '&updateSequence=',OPT.updateSequence];
      else
         error('updateSequence should be character')
      end
   end   
   
   varargout = {url,OPT,lim};
   
function c = ensure_cell(c)

   if ischar(c);c = cellstr(c);end
