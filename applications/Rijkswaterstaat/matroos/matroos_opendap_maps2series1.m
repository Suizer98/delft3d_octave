function varargout = matroos_opendap_maps2series1(varargin)
%MATROOS_OPENDAP_MAPS2SERIES1  get meta-data cache to extract series from OPeNDAP maps (TEST!!!)
%
%   D = matroos_opendap_maps2series1('source',<...>,'basePath',<...>)
%
% This client side function has the same functionality as the server side
% matroos.deltares.nl/direct/get_map2series.php? functionality. This client
% side function is slower the 1st time because it needs to gather meta-data,
% but it can be much faster any subsequent time because it can cache some 
% part of the 'state' of the 'request', for instance the [m,n] mapping.
%
%See also: MATROOS_OPENDAP_MAPS2SERIES2, MATROOS_OPENDAP_MAPS2SERIES2MN, nc_harvest, 
%          matroos_get_series, matroos.deltares.nl/direct/get_map2series.php?

warning('very preliminary test version')

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012
%       Dr.ir. Gerben J. de Boer, Deltares
%
%       gerben.deboer@deltares.nl
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: matroos_opendap_maps2series1.m 10039 2014-01-20 09:25:44Z boer_g $
% $Date: 2014-01-20 17:25:44 +0800 (Mon, 20 Jan 2014) $
% $Author: boer_g $
% $Revision: 10039 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/matroos/matroos_opendap_maps2series1.m $
% $Keywords: $

warning('data location changed: https://opendap-matroos.deltares.nl/thredds/catalog/archive/catalog.html')   
warning('https://opendap-matroos.deltares.nl/thredds/catalog/archive/maps2d/YYYY/',OPT.source,'/YYYYMM/history/catalog.html')

%% initialize

   OPT.basePath = 'http://opendap-matroos.deltares.nl/thredds/dodsC/'; % same server as catalog.xml
   OPT.source   = 'hmcn_kustfijn';
   
   if nargin==0
      varargout = {OPT};return
   end

   OPT = setproperty(OPT,varargin);

%% get file names
%  catalog needs to be downloaded locally, as
%  opendap_catalog cannot YET handle authentication

   D.basePath = OPT.basePath;
   D.relPath  = opendap_catalog([OPT.source,'.xml']);
   D.relPath  = sort(D.relPath); % make time ascending
   
   D.urlPath  = cellfun(@(x) [D.basePath x],D.relPath,'UniformOutput',0);

%% get aprox. times from file names

   D.datenum  = cell2mat(cellfun(@(x) datenum(filename(x),'yyyymmddHHMM'),D.relPath,'UniformOutput',0));

%% get coordinates

   [user,passwd]  = matroos_user_password;
   
   D.x  = nc_varget(['https://',user,':',passwd,'@',D.urlPath{1}(8:end)],'x');
   D.y  = nc_varget(['https://',user,':',passwd,'@',D.urlPath{1}(8:end)],'y');
   x2   = nc_varget(['https://',user,':',passwd,'@',D.urlPath{end}(8:end)],'x');
   y2   = nc_varget(['https://',user,':',passwd,'@',D.urlPath{end}(8:end)],'y');
   
   if ~isequalwithequalnans(D.x,x2) & ... % changed from (x,y) to (x2,y2)
      ~isequalwithequalnans(D.y,y2)
      error('This Matroos dataset does not have a persistent grid topology.')
   end

   save(OPT.source,'-struct','D')
   
   varargout = {D};

%% TO DO get exact times from subet of times
%  TO DO check time zone differences
%
%   n = length(D.datenum);
%   for j=n:-1:0 % start with slowest (largest arrays) first
%     disp([num2str(j,'%0.4d'),' / ',num2str(n,'%0.4d')])
%     D.t{j} = nc_cf_time(['https://',user,':',passwd,'@',D.urlPath{j}(8:end)]);
%     multiWaitbar( 'getting times', 'Value', (n-j)/n);
%   end

%% first nc node: 30 min
% 18-Jul-2008 07:30:00
% 18-Jul-2008 08:00:00
% 18-Jul-2008 08:30:00
% 18-Jul-2008 09:00:00
% 18-Jul-2008 09:30:00
% 18-Jul-2008 10:00:00
% 18-Jul-2008 10:30:00
% 18-Jul-2008 11:00:00
% 18-Jul-2008 11:30:00

%% last nc node: 10 min
% 15-Jun-2012 07:10:00
% 15-Jun-2012 07:20:00
% 15-Jun-2012 07:30:00
% 15-Jun-2012 07:40:00
% 15-Jun-2012 07:50:00
% 15-Jun-2012 08:00:00
% 15-Jun-2012 08:10:00
% 15-Jun-2012 08:20:00
% 15-Jun-2012 08:30:00
% 15-Jun-2012 08:40:00
% 15-Jun-2012 08:50:00
% 15-Jun-2012 09:00:00
% 15-Jun-2012 09:10:00
% 15-Jun-2012 09:20:00
% 15-Jun-2012 09:30:00
% 15-Jun-2012 09:40:00
% 15-Jun-2012 09:50:00
% 15-Jun-2012 10:00:00
% 15-Jun-2012 10:10:00
% 15-Jun-2012 10:20:00
% 15-Jun-2012 10:30:00
% 15-Jun-2012 10:40:00
% 15-Jun-2012 10:50:00
% 15-Jun-2012 11:00:00
% 15-Jun-2012 11:10:00
% 15-Jun-2012 11:20:00
% 15-Jun-2012 11:30:00
% 15-Jun-2012 11:40:00
% 15-Jun-2012 11:50:00
% 15-Jun-2012 12:00:00
% 15-Jun-2012 12:10:00
% 15-Jun-2012 12:20:00
% 15-Jun-2012 12:30:00
% 15-Jun-2012 12:40:00
% 15-Jun-2012 12:50:00
% 15-Jun-2012 13:00:00


